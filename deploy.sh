#!/bin/bash
# Deployment script for ICP Nebula prototype canisters

set -e

echo "=========================================="
echo "ICP Nebula Prototype Deployment"
echo "=========================================="
echo ""

# Check if dfx is installed
if ! command -v dfx &> /dev/null; then
    echo "❌ Error: dfx is not installed"
    echo "Install with: sh -ci \"\$(curl -fsSL https://internetcomputer.org/install.sh)\""
    exit 1
fi

echo "✓ dfx version: $(dfx --version)"
echo ""

# Check if local replica is running
if ! dfx ping &> /dev/null; then
    echo "Starting local ICP replica..."
    dfx start --background --clean
    echo "✓ Local replica started"
else
    echo "✓ Local replica is already running"
fi

echo ""
echo "Building canisters..."
dfx build

echo ""
echo "Deploying canisters..."

# Deploy orchestrator canister
echo ""
echo "📦 Deploying Orchestrator canister..."
ORCHESTRATOR_ID=$(dfx deploy orchestrator 2>&1 | grep "Canister id" | awk '{print $4}')
echo "✓ Orchestrator deployed at: $ORCHESTRATOR_ID"

# Deploy file storage canister
echo ""
echo "📦 Deploying File Storage canister..."
FILE_STORAGE_ID=$(dfx deploy file_storage 2>&1 | grep "Canister id" | awk '{print $4}')
echo "✓ File Storage deployed at: $FILE_STORAGE_ID"

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Canister IDs:"
echo "  - Orchestrator: $ORCHESTRATOR_ID"
echo "  - File Storage: $FILE_STORAGE_ID"
echo ""
echo "Health Check Commands:"
echo "  dfx canister call orchestrator healthCheck"
echo "  dfx canister call file_storage healthCheck"
echo ""
echo "View canister status:"
echo "  dfx canister status orchestrator"
echo "  dfx canister status file_storage"
echo ""
echo "Stop replica:"
echo "  dfx stop"
echo ""
