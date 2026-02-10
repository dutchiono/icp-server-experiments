# ICP Development Environment Setup Guide

## Prerequisites Installation

### 1. Install DFX SDK (Internet Computer SDK)

```bash
# Install dfx (the DFINITY Canister SDK)
sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"

# Verify installation
dfx --version
# Expected: dfx 0.16.0 or higher
```

### 2. Install Node.js Dependencies

```bash
# Install Node.js (v18+ recommended)
# On macOS:
brew install node

# On Ubuntu/Debian:
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify
node --version
npm --version
```

### 3. Install Rust (for Rust canisters, optional for now)

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
rustup target add wasm32-unknown-unknown
```

## Quick Start Commands

### Initialize Local ICP Replica

```bash
# Start local Internet Computer replica
dfx start --background --clean

# Check status
dfx ping

# Stop when done
dfx stop
```

### Create New Project

```bash
# Create canister project
dfx new my_canister --type=motoko

# Or for Rust
dfx new my_canister --type=rust
```

### Deploy Canister Locally

```bash
# Deploy all canisters defined in dfx.json
dfx deploy

# Deploy specific canister
dfx deploy canister_name

# Deploy to mainnet (requires cycles)
dfx deploy --network ic
```

### Interact with Canister

```bash
# Call canister function
dfx canister call canister_name function_name '(arguments)'

# Get canister ID
dfx canister id canister_name

# Check canister status
dfx canister status canister_name
```

## Project Structure

```
icp-server-experiments/
├── dfx.json                    # Project configuration
├── src/
│   ├── orchestrator/          # Main orchestrator canister
│   │   ├── main.mo           # Motoko source
│   │   └── types.mo          # Type definitions
│   ├── file_storage/          # File storage canister
│   ├── conversation/          # Conversation history
│   └── treasury/              # Autonomous funding
├── test/                      # Integration tests
├── docs/                      # Documentation
└── scripts/                   # Deployment scripts
```

## Useful Commands Reference

```bash
# Get principal ID (your identity)
dfx identity get-principal

# Check cycles balance
dfx wallet balance

# Add cycles to canister
dfx canister deposit-cycles <amount> <canister-name>

# View canister logs
dfx canister logs <canister-name>

# Generate canister interface
dfx generate

# Build without deploying
dfx build
```

## Development Workflow

1. **Start local replica**: `dfx start --background`
2. **Write canister code**: Edit `.mo` or `.rs` files
3. **Deploy**: `dfx deploy`
4. **Test**: `dfx canister call ...` or integration tests
5. **Iterate**: Repeat steps 2-4
6. **Stop replica**: `dfx stop`

## Important Notes

- **Local development is free** - No cycles required for local replica
- **Mainnet deployment requires cycles** - Purchase via exchanges or faucet
- **State persists** - Use `--clean` flag to reset local state
- **HTTPS outcalls** - Require consensus, test carefully
- **Cycle costs** - Monitor with `dfx canister status`

## Next Steps

After environment setup:
1. Create orchestrator canister prototype
2. Implement HTTPS outcalls for LLM inference
3. Measure actual cycle costs
4. Validate cost estimates from migration analysis

## Resources

- Official Docs: https://internetcomputer.org/docs/
- Motoko Guide: https://internetcomputer.org/docs/motoko/
- Developer Forum: https://forum.dfinity.org/
- Cycle Costs: https://internetcomputer.org/docs/developer-docs/gas-cost