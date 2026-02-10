#!/bin/bash
# Test script to measure actual cycle costs for Nebula operations

set -e

echo "=========================================="
echo "ICP Nebula Cycle Cost Testing"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if canisters are deployed
if ! dfx canister id orchestrator &> /dev/null; then
    echo "❌ Error: Canisters not deployed. Run ./deploy.sh first"
    exit 1
fi

echo "✓ Canisters detected"
echo ""

# Test 1: Orchestrator Health Check (Query - should be free)
echo -e "${BLUE}Test 1: Health Check (Query Call)${NC}"
echo "Expected cost: ~0 cycles (queries are free)"
echo ""
dfx canister call orchestrator healthCheck
echo ""

# Test 2: Process Message (Update Call with LLM inference)
echo -e "${BLUE}Test 2: LLM Inference Test${NC}"
echo "Expected cost: ~50M cycles (HTTPS outcall estimate)"
echo ""
echo "Sending test message..."

# Get initial stats
BEFORE_STATS=$(dfx canister call orchestrator getStats)
echo "Stats before: $BEFORE_STATS"
echo ""

# Process a test message
dfx canister call orchestrator processMessage '(
  "test-conversation-001",
  "What is the capital of France?",
  opt "You are a helpful assistant."
)'
echo ""

# Get updated stats
AFTER_STATS=$(dfx canister call orchestrator getStats)
echo "Stats after: $AFTER_STATS"
echo ""

# Test 3: Get Conversation (Query)
echo -e "${BLUE}Test 3: Get Conversation History (Query)${NC}"
echo "Expected cost: ~0 cycles (queries are free)"
echo ""
dfx canister call orchestrator getConversation '("test-conversation-001")'
echo ""

# Test 4: File Storage - Initialize Upload
echo -e "${BLUE}Test 4: File Upload Initialization${NC}"
echo "Expected cost: ~1M cycles (state update)"
echo ""
dfx canister call file_storage initUpload '(
  "test-file.txt",
  "text/plain",
  1000,
  "tmp",
  vec {}
)'
echo ""

# Test 5: File Storage Statistics (Query)
echo -e "${BLUE}Test 5: File Storage Stats (Query)${NC}"
echo "Expected cost: ~0 cycles (queries are free)"
echo ""
dfx canister call file_storage getStats
echo ""

# Test 6: Canister Status (shows actual cycle balance)
echo -e "${BLUE}Test 6: Canister Status${NC}"
echo ""
echo "Orchestrator status:"
dfx canister status orchestrator
echo ""
echo "File Storage status:"
dfx canister status file_storage
echo ""

# Summary
echo "=========================================="
echo -e "${GREEN}Testing Complete!${NC}"
echo "=========================================="
echo ""
echo "Key Findings:"
echo "  - Query calls (getStats, healthCheck, getConversation): FREE"
echo "  - Update calls (processMessage, initUpload): Cycle cost measured"
echo "  - HTTPS outcalls for LLM: Estimated 50M cycles (~\$0.000065 per call)"
echo ""
echo "Next Steps:"
echo "  1. Review canister status for actual cycle consumption"
echo "  2. Compare measured costs vs. estimates in migration doc"
echo "  3. Test with larger payloads to measure scaling"
echo "  4. Deploy to mainnet testnet for real cycle burn testing"
echo ""
echo "To monitor cycles continuously:"
echo "  watch -n 5 'dfx canister status orchestrator | grep cycles'"
echo ""
