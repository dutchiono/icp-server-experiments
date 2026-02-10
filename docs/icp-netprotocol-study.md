# Internet Computer & Net Protocol: Infrastructure Study

**Date:** February 10, 2026  
**Purpose:** Evaluate ICP for server hosting and Net Protocol for EVM storage layer

---

## Executive Summary

### Internet Computer (ICP)
- **Cost Model:** Reverse gas model - developers pay upfront with "cycles"
- **Storage Cost:** ~$5.35/GB/year (~$0.45/GB/month)
- **Compute Cost:** Extremely cheap - queries are FREE, updates ~$0.0000068 USD
- **Use Case:** Full-stack decentralized applications, smart contracts with storage

### Net Protocol
- **Type:** Fully onchain messaging & storage protocol on EVM chains
- **Cost Model:** Standard blockchain gas fees (no additional protocol fees)
- **Architecture:** Pure onchain - no databases, no servers, just smart contracts
- **Use Case:** Permanent, censorship-resistant data storage on multiple EVM chains

---

## Part 1: Internet Computer (ICP)

### Overview
Internet Computer is a blockchain that can host full-stack applications including backend logic, frontend assets, and data storage. Unlike traditional blockchains focused on financial transactions, ICP is designed for general-purpose computing.

### Cost Structure

#### Cycle Economics
- **Exchange Rate:** 1 trillion cycles = 1 XDR (Special Drawing Rights)
- **Current Rate:** 1 XDR = ~$1.35 USD (May 2025)

#### Detailed Pricing (13-node subnets)

| Resource | Cost (Cycles) | USD Equivalent |
|----------|---------------|----------------|
| **Canister Creation** | 500 billion | ~$0.68 |
| **Storage (per GiB/year)** | ~4 trillion | ~$5.35 |
| **Storage (per GiB/month)** | ~333 billion | ~$0.45 |
| **Compute (1% allocation/sec)** | 10 million | ~$0.0000135 |
| **Query Calls** | 0 (FREE) | FREE |
| **Update Message** | 5 million | ~$0.0000068 |
| **1 Billion Instructions** | 1 billion | ~$0.00135 |
| **Ingress Message** | 1.2M + 2K/byte | ~$0.0000016+ |
| **HTTPS Outcall** | 49.14 million | ~$0.0000666 |

#### Scaling Considerations
- **13-node subnets:** Standard pricing (base replication)
- **34-node subnets:** Costs scale as `34 × (cost / 13)` due to higher replication factor
- Higher node counts provide more security but proportionally increase costs

### Key Features

#### Reverse Gas Model
- **Developers pay**, not users
- Users can interact with applications without wallets or tokens
- Eliminates user friction for Web2-like experience

#### Canister Smart Contracts
- **Canisters** are ICP's smart contracts
- Can serve web pages directly
- Can store data efficiently
- Can make HTTPS outcalls to external APIs

#### Performance Characteristics
- **Query calls are FREE** - Read operations cost nothing
- **Fast finality** - 1-2 second block times
- **Web-speed performance** - Can serve websites directly

### Cost Comparison Example

**Running a Simple Backend API Server:**
- **Storage:** 1 GB data = $5.35/year
- **Compute:** Assuming 1% CPU allocation = $4.26/year
- **Queries:** Unlimited reads = FREE
- **Updates:** 1M update calls = ~$6.80
- **Total:** ~$16.41/year for light usage

**Versus Traditional Cloud:**
- AWS t3.micro: ~$8.50/month = ~$102/year (compute only)
- Storage: S3 at $0.023/GB/month = $0.28/year for 1GB
- Bandwidth: Variable, typically $0.09/GB
- **Total:** ~$102+/year minimum

**ICP is 6-10x cheaper** for storage-heavy, read-heavy applications.

### Getting Started with ICP

#### Prerequisites
```bash
# Install DFX (DFINITY SDK)
sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"
```

#### Create Your First Canister
```bash
# Create new project
dfx new my_project
cd my_project

# Start local replica (development)
dfx start --background

# Deploy canister
dfx deploy
```

#### Cycle Management
```bash
# Check cycle balance
dfx canister status <canister-id>

# Add cycles to canister
dfx canister deposit-cycles <amount> <canister-id>
```

#### Buy Cycles
- Convert ICP tokens to cycles via NNS (Network Nervous System)
- Use exchanges to buy ICP, then convert to cycles
- Cycles cannot be converted back to ICP (one-way by design)

### Development Resources
- **Official Docs:** https://internetcomputer.org/docs
- **Developer Portal:** https://internetcomputer.org/developers
- **Examples:** https://github.com/dfinity/examples
- **Forum:** https://forum.dfinity.org

### ICP Use Cases
1. **Decentralized backends** - APIs, business logic, data processing
2. **Full-stack dApps** - Frontend + backend in one canister
3. **NFT storage** - Store images/metadata directly onchain
4. **Social platforms** - DSCVR, OpenChat built on ICP
5. **DeFi protocols** - With native Bitcoin/Ethereum integration

---

## Part 2: Net Protocol (netprotocol.app)

### Overview
Net Protocol is a **fully onchain messaging and storage protocol** deployed on multiple EVM chains. Unlike traditional systems that rely on centralized databases, Net stores ALL data directly on the blockchain using smart contracts and SSTORE2 for gas-efficient storage.

**Contract Address (Universal):** `0x00000000B24D62781dB359b07880a105cD0b64e6`  
**Storage Contract:** `0x00000000DB40fcB9f4466330982372e27Fd7Bbf5`

### Supported Networks
- Base
- Hyperliquid EVM
- Ink Chain
- Ham Chain
- Plasma Chain
- Unichain
- Degen Chain

### Architecture

#### Core Components
1. **Net Protocol Contract** - Multi-dimensional message indexing system
2. **Net Storage** - Key-value storage using SSTORE2
3. **Net Gateway** - HTTP API for blockchain data access

#### Message Structure
```solidity
struct Message {
    address app;        // Contract that sent the message
    address sender;     // User who sent the message
    uint256 timestamp;  // Block timestamp
    bytes data;         // Binary data payload
    string text;        // Human-readable text
    string topic;       // Category/index for querying
}
```

#### Multi-Dimensional Indexing
Net creates 5 index types for each message:
1. **App Index** - All messages from specific app
2. **App + User Index** - User's messages in an app
3. **App + Topic Index** - App messages by topic
4. **App + User + Topic Index** - User's messages in app by topic
5. **Global Index** - All messages chronologically

This enables efficient querying across multiple dimensions simultaneously.

### Cost Model

#### No Protocol Fees
- Net Protocol charges **NO additional fees**
- You only pay standard blockchain gas fees for transactions
- Storage costs are determined by the underlying blockchain

#### Gas Costs (Approximate on Base)
- **Send Message:** ~200,000-300,000 gas (~$0.10-0.30 at 1 gwei)
- **Storage Write (SSTORE2):** Variable based on data size
- **Reads (View Calls):** FREE (view functions)

#### Storage Economics
Net uses **SSTORE2** for gas-efficient storage:
- Stores data as contract bytecode
- More gas-efficient than native SSTORE for large data
- Data is immutable once written
- ~24,000 gas per 32 bytes stored

**Example Storage Costs on Base:**
- 1 KB data: ~$0.15-0.25
- 10 KB data: ~$1.50-2.50
- 100 KB data: ~$15-25
- 1 MB data: ~$150-250

*Actual costs vary with gas prices*

### Key Features

#### Complete Decentralization
- **No central servers** - All data onchain
- **No databases** - Smart contracts only
- **Permissionless** - Anyone can read/write
- **Censorship-resistant** - Cannot be taken down

#### Permanent Storage
- Data stored permanently on blockchain
- Immutable once written
- Publicly verifiable
- Cross-chain compatible (same contracts, different chains)

#### Rich Ecosystem
Built on Net Protocol:
- **Storage** - Key-value onchain storage
- **Bazaar** - NFT/ERC20 marketplace (powered by Seaport)
- **Banger (Netr)** - Memecoin launcher with Uniswap V3 integration
- **Score Protocol** - Onchain scoring system with upvoting
- **$ALPHA** - Community memecoin (2M+ upvotes)

### Getting Started with Net Protocol

#### TypeScript/React SDK
```bash
npm install @net-protocol/core @net-protocol/react
```

#### Basic Usage
```typescript
import { Net } from '@net-protocol/core';

// Initialize
const net = new Net({
  chainId: 8453, // Base
  provider: yourProvider
});

// Send message
await net.sendMessage({
  text: "Hello Net!",
  topic: "greetings",
  data: "0x" // binary data (optional)
});

// Query messages by topic
const messages = await net.getMessagesForTopic("greetings");
```

#### Net Storage Usage
```typescript
import { Storage } from '@net-protocol/storage';

// Store data
await storage.put(
  key,        // bytes32 key
  operator,   // your contract address
  data        // bytes data
);

// Retrieve data
const data = await storage.get(key, operator);
```

### Net Protocol Use Cases

#### Current Applications
1. **Onchain Social** - Messaging, comments, feeds
2. **NFT Marketplaces** - Order books fully onchain (Bazaar)
3. **Token Launches** - Memecoin deployment tracking (Banger)
4. **Reputation Systems** - Upvoting, scoring (Score Protocol)
5. **Content Storage** - Permanent hosting of HTML/images/data

#### Potential Use Cases for Your Org
1. **Permanent Documentation** - Store critical docs onchain
2. **Audit Trails** - Immutable logs of system events
3. **Decentralized Registry** - Public record of projects/contracts
4. **Cross-chain Messaging** - Communicate between EVM chains
5. **Token Metadata** - Store NFT/token data permanently

---

## Part 3: Comparison & Recommendations

### When to Use Internet Computer (ICP)

**Best For:**
- Full-stack decentralized applications
- Compute-heavy backends with lots of logic
- Applications requiring low-latency reads (queries are free!)
- Projects needing HTTPS outcalls to Web2 APIs
- Storage-heavy applications (cheaper than traditional cloud)

**Advantages:**
- Extremely cheap storage ($5.35/GB/year)
- Free query calls (unlimited reads)
- Can serve web pages directly from canisters
- Reverse gas model (better UX for users)
- Native Bitcoin/Ethereum integration

**Disadvantages:**
- Not EVM-compatible (new development paradigm)
- Smaller ecosystem than Ethereum
- Must manage cycles (prepaid model)
- Less battle-tested than Ethereum

### When to Use Net Protocol

**Best For:**
- Permanent, immutable data storage on EVM chains
- Applications needing multi-chain presence (same contracts everywhere)
- Building on existing EVM infrastructure
- Onchain messaging and indexing
- Projects requiring full transparency (all data public)

**Advantages:**
- Fully EVM-compatible (deploy on Base, Hyperliquid, etc.)
- No protocol fees (only gas)
- Multi-chain by default
- Rich ecosystem (Bazaar, Banger, Score)
- Permissionless and censorship-resistant

**Disadvantages:**
- More expensive storage than ICP (~$15-25 per MB vs $5 per GB)
- Read operations cost gas (though view calls are free)
- Limited to EVM chains only
- Storage costs scale with gas prices

### Cost Comparison

| Use Case | ICP Cost (Annual) | Net Protocol (Base) | Winner |
|----------|-------------------|---------------------|--------|
| **1 GB Storage** | ~$5.35 | ~$150,000 | **ICP** (28,000x cheaper) |
| **1 MB Storage** | ~$0.005 | ~$150-250 | **ICP** (50,000x cheaper) |
| **100 KB Storage** | ~$0.0005 | ~$15-25 | **ICP** (50,000x cheaper) |
| **1M Read Operations** | $0 (FREE) | $0 (view calls) | **Tie** |
| **1M Write Operations** | ~$6.80 | ~$50,000-150,000 | **ICP** (10,000x cheaper) |
| **Backend API** | ~$16/year | N/A (no compute model) | **ICP** |

**Clear Winner for Storage:** ICP is dramatically cheaper for any significant amount of data.

**Net Protocol's Value:** Not in cost efficiency, but in **EVM compatibility**, **multi-chain presence**, and **public verifiability** on established chains.

### Hybrid Approach

**Optimal Strategy:**
1. **Use ICP for:** Heavy computation, large data storage, backend APIs
2. **Use Net Protocol for:** 
   - Public announcements/logs on EVM chains
   - Cross-chain coordination messages
   - Small, critical data that must be on Ethereum ecosystem
   - Integration with existing EVM dApps

**Example Architecture:**
```
┌─────────────────┐
│   ICP Canister  │ ← Main application logic & storage
│   (Backend)     │ ← User data, files, databases
└────────┬────────┘
         │
         │ HTTPS Outcalls
         │
         ▼
┌─────────────────┐
│  Net Protocol   │ ← Public events & cross-chain messages
│  (Base Chain)   │ ← Announcements, proofs, coordination
└─────────────────┘
```

---

## Part 4: Implementation Roadmap

### Phase 1: ICP Experimentation (Week 1-2)

**Setup:**
1. Install DFX SDK
2. Create test canister
3. Deploy "Hello World" backend
4. Test cycle management

**Learning Objectives:**
- Understand canister lifecycle
- Practice cycle deposits
- Build simple CRUD API
- Measure actual costs

**Deliverables:**
- Working canister on testnet
- Cost analysis document
- Basic API implementation

### Phase 2: Net Protocol Integration (Week 2-3)

**Setup:**
1. Install Net Protocol SDK
2. Connect to Base testnet
3. Send test messages
4. Query message history

**Learning Objectives:**
- Understand Net's indexing system
- Practice SSTORE2 storage patterns
- Build onchain message board
- Test multi-dimensional queries

**Deliverables:**
- Test messages on Base testnet
- Storage cost measurements
- Query performance analysis

### Phase 3: Production Decision (Week 4)

**Evaluation Criteria:**
- Storage requirements (GB/month)
- Read/write operation frequency
- Required blockchain presence (ICP only vs EVM multi-chain)
- Budget constraints
- Development team familiarity

**Decision Matrix:**
| Factor | Weight | ICP Score | Net Protocol Score |
|--------|--------|-----------|-------------------|
| Storage Cost | 30% | 10/10 | 2/10 |
| Compute Cost | 20% | 10/10 | N/A |
| EVM Compatibility | 20% | 2/10 | 10/10 |
| Multi-chain | 15% | 3/10 | 10/10 |
| Developer Experience | 15% | 6/10 | 9/10 |

---

## Part 5: Resources & Next Steps

### Internet Computer Resources
- **Main Site:** https://internetcomputer.org
- **Documentation:** https://internetcomputer.org/docs
- **GitHub Examples:** https://github.com/dfinity/examples
- **Developer Forum:** https://forum.dfinity.org
- **Cycle Faucet (Testnet):** https://faucet.dfinity.org

### Net Protocol Resources
- **Documentation:** https://docs.netprotocol.app
- **GitHub SDK:** https://github.com/stuckinaboot/net-public
- **Net Website:** https://www.netprotocol.app
- **Contract Explorer:** View on Basescan/other explorers
- **Discord/Community:** Check website for links

### Recommended Next Actions

1. **Create GitHub Repository** ✓ (Next task)
   - Organize ICP experiments
   - Document learnings
   - Track cost measurements

2. **Set Up Development Environment**
   - Install DFX for ICP
   - Install Net Protocol SDK
   - Configure testnets

3. **Build Proof of Concept**
   - Simple backend on ICP
   - Message board on Net Protocol
   - Compare user experience

4. **Cost Analysis**
   - Run both systems for 1 week
   - Measure actual gas/cycle costs
   - Project to production scale

5. **Team Decision**
   - Present findings
   - Choose primary infrastructure
   - Plan migration/integration path

---

## Conclusion

**For Server/Backend Infrastructure:** **Internet Computer (ICP)** is the clear winner due to:
- Dramatically lower storage costs (~$5/GB/year vs ~$150,000/GB)
- Free read operations (queries)
- Reverse gas model (better UX)
- Designed for full-stack applications

**For EVM Storage Layer:** **Net Protocol** excels when you need:
- Multi-chain EVM presence (Base, Hyperliquid, etc.)
- Integration with existing Ethereum ecosystem
- Public verifiability on established chains
- Small amounts of critical data (~KB range)

**Recommendation:** Start with ICP for your server experiments given your goal of cost-effective hosting. Use Net Protocol as a complementary layer for cross-chain coordination or public announcements if needed.

The cost difference is simply too significant to ignore: ICP is **28,000x cheaper** for storage and **10,000x cheaper** for compute operations.

---

**Document Version:** 1.0  
**Last Updated:** February 10, 2026  
**Next Review:** After Phase 1 completion
