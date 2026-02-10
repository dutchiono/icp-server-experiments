// File Storage Canister - Decentralized file storage for Nebula
// Handles file uploads, downloads, and metadata management

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";

actor FileStorage {
  
  // Types
  type FileId = Text;
  type UserId = Principal;
  
  type FileMetadata = {
    id: FileId;
    filename: Text;
    mimeType: Text;
    size: Nat;
    owner: UserId;
    createdAt: Time.Time;
    updatedAt: Time.Time;
    folder: Text;
    tags: [Text];
  };
  
  type FileChunk = {
    fileId: FileId;
    chunkIndex: Nat;
    totalChunks: Nat;
    data: Blob;
  };
  
  type UploadSession = {
    fileId: FileId;
    totalChunks: Nat;
    receivedChunks: [Nat];
    metadata: FileMetadata;
  };
  
  // Constants
  private let MAX_CHUNK_SIZE : Nat = 1_900_000; // ~1.9MB per chunk (under 2MB canister limit)
  private let MAX_FILE_SIZE : Nat = 100_000_000; // 100MB max file size
  
  // State
  private var files = HashMap.HashMap<FileId, FileMetadata>(100, Text.equal, Text.hash);
  private var fileContents = HashMap.HashMap<FileId, [Blob]>(100, Text.equal, Text.hash);
  private var uploadSessions = HashMap.HashMap<FileId, UploadSession>(10, Text.equal, Text.hash);
  
  // Statistics
  private stable var totalFilesStored: Nat = 0;
  private stable var totalBytesStored: Nat = 0;
  
  // Public API: Initialize file upload
  public shared(msg) func initUpload(
    filename: Text,
    mimeType: Text,
    size: Nat,
    folder: Text,
    tags: [Text]
  ) : async {
    fileId: FileId;
    totalChunks: Nat;
    maxChunkSize: Nat;
  } {
    
    // Validate file size
    if (size > MAX_FILE_SIZE) {
      throw Error.reject("File size exceeds maximum limit");
    };
    
    // Generate file ID
    let fileId = filename # "_" # Nat.toText(Time.now());
    
    // Calculate chunks needed
    let totalChunks = (size + MAX_CHUNK_SIZE - 1) / MAX_CHUNK_SIZE;
    
    // Create metadata
    let metadata : FileMetadata = {
      id = fileId;
      filename;
      mimeType;
      size;
      owner = msg.caller;
      createdAt = Time.now();
      updatedAt = Time.now();
      folder;
      tags;
    };
    
    // Initialize upload session
    let session : UploadSession = {
      fileId;
      totalChunks;
      receivedChunks = [];
      metadata;
    };
    
    uploadSessions.put(fileId, session);
    
    Debug.print("Upload initialized: " # fileId # " (" # Nat.toText(totalChunks) # " chunks)");
    
    {
      fileId;
      totalChunks;
      maxChunkSize = MAX_CHUNK_SIZE;
    }
  };
  
  // Public API: Upload file chunk
  public shared(msg) func uploadChunk(chunk: FileChunk) : async {
    success: Bool;
    receivedChunks: Nat;
    totalChunks: Nat;
  } {
    
    // Get upload session
    let session = switch (uploadSessions.get(chunk.fileId)) {
      case null { throw Error.reject("Upload session not found") };
      case (?s) { s };
    };
    
    // Validate chunk index
    if (chunk.chunkIndex >= chunk.totalChunks) {
      throw Error.reject("Invalid chunk index");
    };
    
    // Get existing chunks or create new array
    var chunks = switch (fileContents.get(chunk.fileId)) {
      case null { Array.tabulate<Blob>(chunk.totalChunks, func(i) { Blob.fromArray([]) }) };
      case (?existing) { existing };
    };
    
    // Store chunk
    chunks := Array.tabulate<Blob>(
      chunks.size(),
      func(i) {
        if (i == chunk.chunkIndex) { chunk.data } else { chunks[i] }
      }
    );
    
    fileContents.put(chunk.fileId, chunks);
    
    // Update session
    let updatedChunks = Array.append(session.receivedChunks, [chunk.chunkIndex]);
    let updatedSession : UploadSession = {
      fileId = session.fileId;
      totalChunks = session.totalChunks;
      receivedChunks = updatedChunks;
      metadata = session.metadata;
    };
    
    uploadSessions.put(chunk.fileId, updatedSession);
    
    // Check if upload is complete
    if (updatedChunks.size() == chunk.totalChunks) {
      // Finalize upload
      files.put(chunk.fileId, session.metadata);
      uploadSessions.delete(chunk.fileId);
      
      totalFilesStored += 1;
      totalBytesStored += session.metadata.size;
      
      Debug.print("Upload complete: " # chunk.fileId);
    };
    
    {
      success = true;
      receivedChunks = updatedChunks.size();
      totalChunks = chunk.totalChunks;
    }
  };
  
  // Public API: Download file
  public query func downloadFile(fileId: FileId) : async ?{
    metadata: FileMetadata;
    chunks: [Blob];
  } {
    
    let metadata = switch (files.get(fileId)) {
      case null { return null };
      case (?m) { m };
    };
    
    let chunks = switch (fileContents.get(fileId)) {
      case null { return null };
      case (?c) { c };
    };
    
    ?{
      metadata;
      chunks;
    }
  };
  
  // Public API: Get file metadata
  public query func getMetadata(fileId: FileId) : async ?FileMetadata {
    files.get(fileId)
  };
  
  // Public API: List files by folder
  public query func listFiles(folder: ?Text, limit: Nat) : async [FileMetadata] {
    let allFiles = Iter.toArray(files.vals());
    
    let filtered = switch (folder) {
      case null { allFiles };
      case (?f) {
        Array.filter<FileMetadata>(allFiles, func(file) { file.folder == f })
      };
    };
    
    let sorted = Array.sort<FileMetadata>(
      filtered,
      func(a, b) { Int.compare(b.createdAt, a.createdAt) }
    );
    
    if (sorted.size() <= limit) {
      sorted
    } else {
      Array.tabulate<FileMetadata>(limit, func(i) { sorted[i] })
    }
  };
  
  // Public API: Delete file
  public shared(msg) func deleteFile(fileId: FileId) : async Bool {
    
    // Check ownership
    let metadata = switch (files.get(fileId)) {
      case null { return false };
      case (?m) {
        if (m.owner != msg.caller) {
          throw Error.reject("Not authorized to delete this file");
        };
        m
      };
    };
    
    // Delete file
    files.delete(fileId);
    fileContents.delete(fileId);
    
    totalBytesStored -= metadata.size;
    totalFilesStored -= 1;
    
    Debug.print("File deleted: " # fileId);
    
    true
  };
  
  // Public API: Get storage statistics
  public query func getStats() : async {
    totalFiles: Nat;
    totalBytes: Nat;
    totalMB: Nat;
    averageFileSize: Nat;
  } {
    let avgSize = if (totalFilesStored > 0) { totalBytesStored / totalFilesStored } else { 0 };
    
    {
      totalFiles = totalFilesStored;
      totalBytes = totalBytesStored;
      totalMB = totalBytesStored / 1_000_000;
      averageFileSize = avgSize;
    }
  };
  
  // Public API: Health check
  public query func healthCheck() : async {
    status: Text;
    canisterId: Principal;
    storageUsed: Nat;
    fileCount: Nat;
  } {
    {
      status = "healthy";
      canisterId = Principal.fromActor(FileStorage);
      storageUsed = totalBytesStored;
      fileCount = totalFilesStored;
    }
  };
  
  // System hooks
  system func preupgrade() {
    Debug.print("FileStorage: Preupgrade");
  };
  
  system func postupgrade() {
    Debug.print("FileStorage: Postupgrade");
  };
}
