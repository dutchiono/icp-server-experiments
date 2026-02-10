# Net Protocol (netprotocol.app) - Technical Study

**Date:** February 10, 2026  
**Purpose:** Understanding Net Protocol as an EVM-based storage and messaging layer  
**Official Docs:** https://docs.netprotocol.app/

---

## Executive Summary

Net Protocol is a **fully onchain messaging protocol** deployed across multiple EVM Layer 2 and Layer 3 chains. Unlike traditional storage layers, Net Protocol focuses on **decentralized, censorship-resistant communication** with all data stored directly on blockchain via smart contracts.

**Key Distinction:** Net Protocol is NOT primarily a storage layer like Arweave or Filecoin. It's a **messaging and communication protocol** that happens to store all message data onchain.

---

## Architecture Overview

### Core Characteristics

1. **Fully Onchain**
   - All core data stored directly on blockchain via smart contracts
   - Zero centralized servers or databases
   - No off-chain indexing dependencies
   - Complete transparency and censorship resistance

2. **Multi-Chain Deployment**
   - Same contract address across all chains: `0x00000000B24D62781dB359b07880a105cD0b64e6`
   - Deployed on:
     - Base (Coinbase L2)
     - Hyperliquid EVM
     - Ink Chain
     - Ham Chain
     - Plasma Chain
     - Unichain
     - Degen Chain

3. **Cost Efficiency Strategy**
   - Leverages Layer 2 and Layer 3 blockchains for reduced gas costs
   - L2/L3 chains offer 10-100x cheaper transaction costs vs Ethereum mainnet
   - Storage costs scale with chain-specific gas pricing

---

## Technical Features

### Multi-Dimensional Indexing

Net Protocol provides flexible querying patterns:

```
Query Patterns:
├── App + User + Topic (most specific)
├── Topic only
├── User only
└── App only
```

This enables:
- Application-specific message streams
- User-centric message history
- Topic-based discovery
- Cross-application data portability

### Smart Contract Interface

**Contract Address (all chains):** `0x00000000B24D62781dB359b07880a105cD0b64e6`

Key functions (from documentation):
- Message posting
- Topic management
- User indexing
- App registration

### Developer Tooling

1. **TypeScript SDK**
   - Full SDK for interacting with Net Protocol contracts
   - Available via npm/yarn
   - Documentation: https://docs.netprotocol.app/

2. **Smart Contract Reference**
   - Public contract source code
   - Function documentation
   - Event specifications

---

## Ecosystem & Use Cases

### Built-in Applications

Net Protocol provides a **complete suite of applications**:

1. **Storage** - Onchain file/data storage
2. **NFT Bazaar** - NFT marketplace functionality
3. **Token Launcher** - Token deployment tools
4. **Gated Chat** - Access-controlled messaging
5. **Reputation Systems** - Onchain reputation tracking
6. **Scoring Protocols** - Gamification and metrics

### Primary Use Cases

✅ **Decentralized Messaging**
- Chat applications
- Social media platforms
- Notification systems

✅ **Transparent Communication**
- Public forums
- DAO governance discussions
- Community coordination

✅ **Censorship-Resistant Publishing**
- News platforms
- Content publishing
- Whistleblowing systems

✅ **Cross-Chain Identity**
- Unified messaging across multiple chains
- Portable user history
- Multi-chain reputation

---

## Cost Structure (Estimated)

### Pricing Model

**Net Protocol does not have published pricing tiers** - costs are determined by underlying blockchain gas fees.

### Cost Factors

1. **Message Storage Cost**
   - Determined by chain-specific gas prices
   - Message size (bytes) × gas price
   - Permanent storage on blockchain

2. **Chain-Specific Costs (Estimated)**

| Chain | Relative Cost | Best For |
|-------|---------------|----------|
| Base | Low | General messaging |
| Degen Chain | Very Low | High-frequency apps |
| Hyperliquid EVM | Low-Medium | Trading-related messaging |
| Unichain | Low | DeFi-related communication |
| Ham Chain | Very Low | Experimental/testnet |
| Plasma Chain | Very Low | High-volume messaging |
| Ink Chain | Low | NFT/creator messaging |

3. **Cost Comparison with Alternatives**

| Protocol | Type | Cost Model |
|----------|------|------------|
| **Net Protocol** | Onchain messaging | Pay per message (gas) |
| **XMTP** | Off-chain messaging | Free (subsidized nodes) |
| **Arweave** | Storage layer | Pay once, store forever |
| **IPFS** | Distributed storage | Free (pinning services vary) |
| **Farcaster** | Hybrid social | Yearly rent for storage |

### Estimated Costs (Base Chain Example)

Assuming Base gas prices (~0.001 gwei) and average message size (1KB):

```
Cost per message: ~$0.0001 - $0.001 USD
Cost for 1,000 messages: ~$0.10 - $1.00 USD
Cost for 100KB storage: ~$0.01 - $0.10 USD
```

**Note:** These are rough estimates. Actual costs vary with:
- Network congestion
- Message payload size
- Chain selection
- Smart contract optimization

---

## Integration Guide

### Quick Start

1. **Install TypeScript SDK**
```bash
npm install @netprotocol/sdk
# or
yarn add @netprotocol/sdk
```

2. **Initialize Client**
```typescript
import { NetProtocol } from '@netprotocol/sdk';

const net = new NetProtocol({
  chain: 'base', // or 'degen', 'hyperliquid', etc.
  privateKey: process.env.PRIVATE_KEY
});
```

3. **Post a Message**
```typescript
const tx = await net.postMessage({
  app: 'my-app',
  topic: 'general',
  content: 'Hello, Net Protocol!'
});
```

4. **Query Messages**
```typescript
const messages = await net.getMessages({
  app: 'my-app',
  topic: 'general',
  limit: 100
});
```

### Best Practices

✅ **Choose the right chain** - Balance cost vs. security/decentralization  
✅ **Optimize message size** - Smaller payloads = lower gas costs  
✅ **Batch operations** - Group multiple messages when possible  
✅ **Index strategically** - Use App + Topic + User combinations effectively  
✅ **Monitor gas prices** - Deploy during low-congestion periods  

---

## Comparison: Net Protocol vs. Traditional Storage

### Net Protocol Strengths

✅ **Censorship Resistance** - Fully onchain, no single point of failure  
✅ **Transparency** - All data publicly verifiable  
✅ **Multi-Chain** - Deploy once, access everywhere  
✅ **No Backend Needed** - Smart contracts handle all logic  
✅ **Composability** - Other dApps can read/build on your messages  

### Net Protocol Limitations

❌ **Cost at Scale** - Gas fees accumulate for high-volume applications  
❌ **Size Constraints** - Blockchain storage expensive for large files  
❌ **Performance** - Block times limit real-time messaging  
❌ **Privacy** - All data public by default (no encryption built-in)  
❌ **Immutability** - Cannot delete or edit messages once posted  

### When to Use Net Protocol

**Good Fit:**
- Public messaging platforms
- Social media dApps
- DAO governance forums
- Transparent logging systems
- Cross-chain communication needs

**Poor Fit:**
- Private messaging (unless encrypted client-side)
- Large file storage (videos, images)
- High-frequency trading bots (gas costs)
- Real-time gaming chat (latency)
- Applications requiring message deletion

---

## Net Protocol vs. ICP Comparison

| Feature | Net Protocol | Internet Computer (ICP) |
|---------|--------------|-------------------------|
| **Architecture** | EVM smart contracts | Canister smart contracts |
| **Storage Model** | Onchain per-message | Bundled in canister cycles |
| **Cost Model** | Pay per message (gas) | Pay upfront (cycles) |
| **Query Costs** | Gas fees per read | Free (queries don't use cycles) |
| **Speed** | Block time dependent (~2s) | Sub-second finality |
| **Multi-Chain** | Yes (multiple EVM chains) | Single network (ICP) |
| **Privacy** | Public by default | Can be private (developer choice) |
| **Mutability** | Immutable (blockchain) | Mutable (canister upgrades) |
| **Scalability** | Limited by gas/block size | Scales with subnet capacity |
| **Best For** | Transparent messaging | General computation + storage |

---

## Security Considerations

### Smart Contract Security

✅ **Contract Audits** - Verify contract has been audited  
✅ **Upgrade Mechanisms** - Understand if contracts are upgradeable  
✅ **Access Controls** - Review who can modify protocol parameters  

### Data Privacy

⚠️ **All messages are public** - Anyone can read onchain data  
⚠️ **No built-in encryption** - Implement client-side encryption if needed  
⚠️ **Wallet addresses exposed** - Posting reveals your wallet identity  

### Operational Security

✅ **Key Management** - Secure private keys for message signing  
✅ **Gas Management** - Monitor wallet balance for transaction fees  
✅ **Rate Limiting** - Implement client-side limits to prevent spam  

---

## Resources & Documentation

### Official Links

- **Documentation Portal:** https://docs.netprotocol.app/
- **Introduction Guide:** https://docs.netprotocol.app/docs/intro
- **Contract Address:** `0x00000000B24D62781dB359b07880a105cD0b64e6` (all chains)

### Developer Resources

- TypeScript SDK documentation
- Smart contract reference
- API examples
- Integration guides

### Community & Support

- Check official documentation for Discord/Telegram links
- GitHub repository (if public)
- Developer forums

---

## Next Steps for Experimentation

### Phase 1: Basic Testing
1. Deploy a simple messaging dApp on Base (cheapest L2)
2. Post test messages across different topics
3. Measure gas costs per message
4. Test multi-dimensional queries

### Phase 2: Performance Testing
1. Benchmark message posting speed
2. Test query performance with large datasets
3. Measure costs at different network congestion levels
4. Compare performance across different chains

### Phase 3: Integration Patterns
1. Build a simple chat interface
2. Implement client-side encryption
3. Create cross-chain message aggregator
4. Test integration with existing dApp

### Phase 4: Cost Optimization
1. Batch message posting
2. Optimize message payload sizes
3. Compare costs across different chains
4. Implement message compression strategies

---

## Conclusion

**Net Protocol is best suited for:**
- Public, transparent messaging applications
- Decentralized social platforms requiring censorship resistance
- Cross-chain communication needs
- Applications where data immutability is an asset

**Consider alternatives if you need:**
- Private messaging (use XMTP or Signal)
- Large file storage (use Arweave, IPFS, or Filecoin)
- High-frequency messaging (use centralized or L2-specific solutions)
- Mutable data (use ICP or traditional databases)

**Pricing:** Highly variable based on chain selection and network conditions. Estimate $0.0001-$0.001 per message on L2 chains like Base.

---

**Study Status:** Complete  
**Last Updated:** February 10, 2026  
**Next Review:** After initial experimentation phase
