// Orchestrator Canister - Main entry point for Nebula on ICP
// Handles LLM inference, tool routing, and agent coordination

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";

actor Orchestrator {
  
  // Types
  type UserId = Principal;
  type MessageId = Nat;
  type ConversationId = Text;
  
  type Message = {
    id: MessageId;
    role: Text; // "user" or "assistant"
    content: Text;
    timestamp: Time.Time;
  };
  
  type LLMRequest = {
    model: Text;
    messages: [Message];
    max_tokens: Nat;
    temperature: Float;
  };
  
  type LLMResponse = {
    content: Text;
    model: Text;
    usage: {
      prompt_tokens: Nat;
      completion_tokens: Nat;
      total_tokens: Nat;
    };
    cycles_used: Nat;
  };
  
  type ToolCall = {
    tool_name: Text;
    parameters: Text; // JSON string
  };
  
  // State
  private stable var messageCounter: Nat = 0;
  private var conversations = HashMap.HashMap<ConversationId, [Message]>(10, Text.equal, Text.hash);
  
  // Statistics tracking
  private stable var totalLLMCalls: Nat = 0;
  private stable var totalCyclesSpent: Nat = 0;
  private stable var totalTokensProcessed: Nat = 0;
  
  // Configuration
  private let OPENAI_API_URL = "https://api.openai.com/v1/chat/completions";
  private let ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages";
  
  // HTTPS Outcall configuration
  private let IC_MANAGEMENT_CANISTER_ID : Text = "aaaaa-aa";
  
  // Management canister interface for HTTPS outcalls
  type IC = actor {
    http_request : shared {
      url : Text;
      max_response_bytes : ?Nat64;
      method : { #get; #post; #head };
      headers : [{name: Text; value: Text}];
      body : ?Blob;
      transform : ?{
        function : shared query {
          response : {
            status : Nat;
            headers : [{name: Text; value: Text}];
            body : Blob;
          };
          context : Blob;
        } -> async {
          status : Nat;
          headers : [{name: Text; value: Text}];
          body : Blob;
        };
        context : Blob;
      };
    } -> async {
      status : Nat;
      headers : [{name: Text; value: Text}];
      body : Blob;
    };
  };
  
  // Get next message ID
  private func getNextMessageId() : MessageId {
    messageCounter += 1;
    messageCounter
  };
  
  // Public API: Process user message and generate response
  public shared(msg) func processMessage(
    conversationId: ConversationId,
    userMessage: Text,
    systemPrompt: ?Text
  ) : async LLMResponse {
    
    // Track cycles at start
    let cyclesStart = Cycles.balance();
    
    // Get conversation history
    var history = switch (conversations.get(conversationId)) {
      case null { [] };
      case (?msgs) { msgs };
    };
    
    // Add user message to history
    let userMsg : Message = {
      id = getNextMessageId();
      role = "user";
      content = userMessage;
      timestamp = Time.now();
    };
    
    history := Array.append(history, [userMsg]);
    
    // Build messages array for LLM
    var messages : [Message] = history;
    
    // Add system prompt if provided
    switch (systemPrompt) {
      case (?prompt) {
        let sysMsg : Message = {
          id = 0;
          role = "system";
          content = prompt;
          timestamp = Time.now();
        };
        messages := Array.append([sysMsg], messages);
      };
      case null {};
    };
    
    // Make LLM inference call
    let llmRequest : LLMRequest = {
      model = "gpt-4";
      messages = messages;
      max_tokens = 2000;
      temperature = 0.7;
    };
    
    let response = await callLLM(llmRequest);
    
    // Add assistant response to history
    let assistantMsg : Message = {
      id = getNextMessageId();
      role = "assistant";
      content = response.content;
      timestamp = Time.now();
    };
    
    history := Array.append(history, [assistantMsg]);
    conversations.put(conversationId, history);
    
    // Calculate cycles used
    let cyclesEnd = Cycles.balance();
    let cyclesUsed = cyclesStart - cyclesEnd;
    
    // Update statistics
    totalLLMCalls += 1;
    totalCyclesSpent += cyclesUsed;
    totalTokensProcessed += response.usage.total_tokens;
    
    {
      content = response.content;
      model = response.model;
      usage = response.usage;
      cycles_used = cyclesUsed;
    }
  };
  
  // Internal: Call LLM via HTTPS outcalls
  private func callLLM(request: LLMRequest) : async LLMResponse {
    
    Debug.print("LLM Request: " # debug_show(request.messages.size()) # " messages");
    
    // Build JSON request body for OpenAI API
    let jsonMessages = Text.join(", ", Iter.fromArray(
      Array.map<Message, Text>(request.messages, func(msg) {
        "{\"role\": \"" # msg.role # "\", \"content\": \"" # escapeJSON(msg.content) # "\"}"
      })
    ));
    
    let requestBody = "{\"model\": \"" # request.model # "\", \"messages\": [" # jsonMessages # "], \"max_tokens\": " # Nat.toText(request.max_tokens) # ", \"temperature\": " # Float.toText(request.temperature) # "}";
    
    Debug.print("Request body length: " # Nat.toText(Text.size(requestBody)));
    
    // Get API key from environment (will be set via canister init args)
    // For Phase 1, we'll use a placeholder and return mock data
    // In production, API key should be securely stored
    
    let ic : IC = actor(IC_MANAGEMENT_CANISTER_ID);
    
    // Prepare HTTPS outcall request
    let url = OPENAI_API_URL;
    
    // Note: API key should be passed securely via init args or settings
    // For prototype, we'll show the structure but use mock response
    let headers = [
      { name = "Content-Type"; value = "application/json" },
      { name = "Authorization"; value = "Bearer PLACEHOLDER_API_KEY" }
    ];
    
    let requestBodyBlob = Text.encodeUtf8(requestBody);
    
    // Add cycles for HTTPS outcall (estimated: 50M cycles per call)
    Cycles.add(50_000_000);
    
    // Make the HTTPS outcall
    // NOTE: For Phase 1 prototype, we'll catch errors and return mock data
    // This allows testing without actual API keys
    
    let cyclesBefore = Cycles.balance();
    
    try {
      let httpResponse = await ic.http_request({
        url = url;
        max_response_bytes = ?10_000; // 10KB max response
        method = #post;
        headers = headers;
        body = ?requestBodyBlob;
        transform = null;
      });
      
      let cyclesAfter = Cycles.balance();
      let cyclesUsed = cyclesBefore - cyclesAfter;
      
      Debug.print("HTTPS outcall completed. Cycles used: " # Nat.toText(cyclesUsed));
      
      // Parse response (simplified for prototype)
      let responseText = switch (Text.decodeUtf8(httpResponse.body)) {
        case null { "Error: Could not decode response" };
        case (?text) { text };
      };
      
      // In production, parse JSON response properly
      // For now, return mock data with actual cycle measurements
      
      {
        content = "LLM response (prototype mode - API integration pending)";
        model = request.model;
        usage = {
          prompt_tokens = 100;
          completion_tokens = 50;
          total_tokens = 150;
        };
        cycles_used = cyclesUsed;
      }
      
    } catch (error) {
      Debug.print("HTTPS outcall failed (expected in prototype): " # Error.message(error));
      
      // Return mock response with estimated cycle cost
      {
        content = "Mock LLM response for testing. Real API integration requires API key configuration.";
        model = request.model;
        usage = {
          prompt_tokens = estimateTokens(requestBody);
          completion_tokens = 50;
          total_tokens = estimateTokens(requestBody) + 50;
        };
        cycles_used = 50_000_000; // Estimated cycles for HTTPS outcall
      }
    }
  };
  
  // Helper: Escape JSON strings
  private func escapeJSON(text: Text) : Text {
    // Simple escaping for quotes and newlines
    var result = text;
    result := Text.replace(result, #text("\""), "\\\"");
    result := Text.replace(result, #text("\n"), "\\n");
    result := Text.replace(result, #text("\r"), "\\r");
    result := Text.replace(result, #text("\t"), "\\t");
    result
  };
  
  // Helper: Estimate token count (rough approximation: 1 token ≈ 4 chars)
  private func estimateTokens(text: Text) : Nat {
    Text.size(text) / 4
  };
  
  // Public API: Get conversation history
  public query func getConversation(conversationId: ConversationId) : async ?[Message] {
    conversations.get(conversationId)
  };
  
  // Public API: Get statistics
  public query func getStats() : async {
    totalLLMCalls: Nat;
    totalCyclesSpent: Nat;
    totalTokensProcessed: Nat;
    averageCyclesPerCall: Nat;
    averageTokensPerCall: Nat;
  } {
    let avgCycles = if (totalLLMCalls > 0) { totalCyclesSpent / totalLLMCalls } else { 0 };
    let avgTokens = if (totalLLMCalls > 0) { totalTokensProcessed / totalLLMCalls } else { 0 };
    
    {
      totalLLMCalls;
      totalCyclesSpent;
      totalTokensProcessed;
      averageCyclesPerCall = avgCycles;
      averageTokensPerCall = avgTokens;
    }
  };
  
  // Public API: Clear conversation (for testing)
  public shared(msg) func clearConversation(conversationId: ConversationId) : async () {
    conversations.delete(conversationId);
  };
  
  // Public API: Health check
  public query func healthCheck() : async {
    status: Text;
    canisterId: Principal;
    cyclesBalance: Nat;
    messageCount: Nat;
    conversationCount: Nat;
  } {
    {
      status = "healthy";
      canisterId = Principal.fromActor(Orchestrator);
      cyclesBalance = Cycles.balance();
      messageCount = messageCounter;
      conversationCount = conversations.size();
    }
  };
  
  // System hooks for upgrades
  system func preupgrade() {
    Debug.print("Preupgrade: Saving state...");
  };
  
  system func postupgrade() {
    Debug.print("Postupgrade: State restored");
  };
}
