# 👗 Traceable Luxury Fashion Provenance

> Blockchain-powered authenticity and ethical sourcing verification for luxury fashion items

## ✨ Overview

This smart contract creates an immutable, transparent supply chain tracking system for luxury fashion garments. Each item receives an NFT certificate that chronicles its complete journey from raw materials to final sale, ensuring authenticity and ethical sourcing.

## 🎯 Features

- **🏷️ NFT Certification**: Each garment is represented as a unique non-fungible token
- **📍 Supply Chain Tracking**: Complete traceability from cotton/material origin → production → sale
- **✅ Authenticity Verification**: Instant verification of garment authenticity via blockchain
- **🌱 Ethical Sourcing**: Track and verify ethical certification throughout the supply chain
- **📜 Ownership History**: Immutable record of all previous owners and transactions
- **🔐 Authorized Verifiers**: Designated verifiers can validate supply chain stages
- **💰 Price Tracking**: Optional price recording for each ownership transfer

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for deployment

### Installation

```bash
git clone <repository-url>
cd Traceable-Luxury-Fashion-Provenance
clarinet check
```

## 📖 Usage

### Minting a Garment

Only the contract owner can mint new garments:

```clarity
(contract-call? .Traceable-Luxury-Fashion-Provenance mint-garment
    "Silk Evening Gown"
    "Versace"
    "Organic silk farm, Suzhou, China"
    "Milan, Italy"
    true
)
```

### Adding Supply Chain Stages

Authorized verifiers can add supply chain stages:

```clarity
(contract-call? .Traceable-Luxury-Fashion-Provenance add-supply-chain-stage
    u1
    "production"
    "Factory, Milan, Italy"
    "Quality control passed"
)
```

### Transferring Ownership

Transfer garment to a new owner:

```clarity
(contract-call? .Traceable-Luxury-Fashion-Provenance transfer-garment
    u1
    tx-sender
    'SP2...NEW-OWNER
)
```

Transfer with price tracking:

```clarity
(contract-call? .Traceable-Luxury-Fashion-Provenance transfer-garment-with-price
    u1
    tx-sender
    'SP2...NEW-OWNER
    u5000000
)
```

### Verifying Authenticity

Anyone can verify a garment's authenticity:

```clarity
(contract-call? .Traceable-Luxury-Fashion-Provenance verify-authenticity u1)
```

### Managing Verifiers

Add authorized verifier (owner only):

```clarity
(contract-call? .Traceable-Luxury-Fashion-Provenance add-verifier 'SP2...VERIFIER)
```

Remove verifier (owner only):

```clarity
(contract-call? .Traceable-Luxury-Fashion-Provenance remove-verifier 'SP2...VERIFIER)
```

### Querying Data

**Get garment metadata:**
```clarity
(contract-call? .Traceable-Luxury-Fashion-Provenance get-garment-metadata u1)
```

**Get specific supply chain stage:**
```clarity
(contract-call? .Traceable-Luxury-Fashion-Provenance get-supply-chain-stage u1 "production")
```

**Get ownership history:**
```clarity
(contract-call? .Traceable-Luxury-Fashion-Provenance get-ownership-history u1 u0)
```

**Get current owner:**
```clarity
(contract-call? .Traceable-Luxury-Fashion-Provenance get-owner u1)
```

## 🏗️ Contract Architecture

### Data Structures

- **luxury-garment NFT**: Non-fungible token representing each unique garment
- **garment-metadata**: Name, brand, origin, production location, stage, and certification status
- **supply-chain-stages**: Detailed tracking of each stage in the garment's journey
- **garment-ownership-history**: Complete ownership history with timestamps and prices
- **authorized-verifiers**: Map of principals authorized to verify supply chain stages

### Key Functions

| Function | Access | Description |
|----------|--------|-------------|
| `mint-garment` | Owner only | Create new garment NFT |
| `add-supply-chain-stage` | Owner/Verifiers | Add supply chain stage |
| `transfer-garment` | Token owner | Transfer ownership |
| `transfer-garment-with-price` | Token owner | Transfer with price tracking |
| `verify-authenticity` | Public | Verify garment authenticity |
| `add-verifier` | Owner only | Authorize verifier |
| `update-ethical-certification` | Owner/Verifiers | Update ethical status |

## 🔒 Security

- Contract owner controls minting and verifier management
- Only token owners can transfer their garments
- Supply chain stages can only be added by authorized verifiers
- All data is immutable once written to the blockchain

## 🌐 Use Cases

- **🛍️ Luxury Retail**: Verify authenticity at point of sale
- **♻️ Resale Markets**: Prove provenance for pre-owned luxury items
- **🌍 Ethical Shopping**: Consumers verify ethical sourcing claims
- **🏭 Brand Protection**: Brands combat counterfeiting
- **📊 Supply Chain Transparency**: Full visibility into production process

## 🧪 Testing

Run tests with Clarinet:

```bash
clarinet test
```

## 📄 License

MIT License - see LICENSE file for details

## 🤝 Contributing

Contributions welcome! Please open an issue or submit a pull request.

---

Made with ❤️ for transparent and ethical fashion
