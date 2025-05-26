# Decentralized Financial Market Data

A blockchain-based system for providing verified, high-quality financial market data through a decentralized network of data providers and consumers.

## Overview

This system creates a trustless marketplace for financial market data by leveraging smart contracts to ensure data quality, manage access permissions, and handle pricing transparently. The platform eliminates single points of failure while maintaining data integrity and fair compensation for data providers.

## Architecture

The system consists of five core smart contracts that work together to create a complete data marketplace:

### Core Contracts

#### 1. Data Provider Verification Contract
- **Purpose**: Validates and manages the reputation of data sources
- **Key Features**:
    - Provider registration and KYC verification
    - Reputation scoring based on data accuracy history
    - Stake-based verification system
    - Provider blacklisting for malicious actors

#### 2. Data Quality Contract
- **Purpose**: Ensures accuracy and reliability of market data
- **Key Features**:
    - Real-time data validation against multiple sources
    - Consensus mechanisms for price discovery
    - Outlier detection and filtering
    - Historical accuracy tracking
    - Quality scoring algorithms

#### 3. Distribution Protocol Contract
- **Purpose**: Manages the dissemination of verified market data
- **Key Features**:
    - Efficient data broadcasting to subscribers
    - Load balancing across provider nodes
    - Data format standardization
    - Latency optimization
    - Redundancy and failover mechanisms

#### 4. Access Control Contract
- **Purpose**: Manages data permissions and subscription tiers
- **Key Features**:
    - Role-based access control (RBAC)
    - Subscription tier management
    - API key generation and validation
    - Rate limiting per subscription level
    - Geographic access restrictions

#### 5. Pricing Contract
- **Purpose**: Handles subscription fees and provider compensation
- **Key Features**:
    - Dynamic pricing based on data quality and demand
    - Multi-token payment support
    - Revenue sharing with data providers
    - Escrow services for disputes
    - Subscription billing automation

## System Flow

```
1. Data Provider Registration → Verification Contract
2. Data Submission → Quality Contract (validation)
3. Validated Data → Distribution Contract (broadcast)
4. Consumer Access Request → Access Control Contract
5. Payment Processing → Pricing Contract
6. Data Delivery → Consumer Application
```

## Getting Started

### Prerequisites

- Node.js v16+
- Hardhat or Truffle development environment
- Web3 wallet (MetaMask recommended)
- Sufficient testnet tokens for deployment

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/defi-market-data.git
cd defi-market-data

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your configuration
```

### Environment Configuration

```env
# Network Configuration
NETWORK=mainnet
RPC_URL=your_rpc_endpoint
PRIVATE_KEY=your_deployer_private_key

# Contract Addresses (populated after deployment)
PROVIDER_VERIFICATION_ADDRESS=
DATA_QUALITY_ADDRESS=
DISTRIBUTION_PROTOCOL_ADDRESS=
ACCESS_CONTROL_ADDRESS=
PRICING_CONTRACT_ADDRESS=

# API Configuration
API_BASE_URL=https://api.your-domain.com
RATE_LIMIT_REQUESTS_PER_MINUTE=100
```

### Deployment

```bash
# Compile contracts
npm run compile

# Deploy to testnet
npm run deploy:testnet

# Deploy to mainnet
npm run deploy:mainnet

# Verify contracts on block explorer
npm run verify
```

## Usage

### For Data Providers

#### 1. Register as a Data Provider
```javascript
const verification = await ProviderVerification.deployed();
await verification.registerProvider(
  "Provider Name",
  "contact@provider.com",
  stakingAmount,
  { from: providerAddress }
);
```

#### 2. Submit Market Data
```javascript
const dataQuality = await DataQuality.deployed();
await dataQuality.submitData(
  symbol,
  price,
  timestamp,
  signature,
  { from: providerAddress }
);
```

### For Data Consumers

#### 1. Subscribe to Data Feed
```javascript
const accessControl = await AccessControl.deployed();
const pricing = await Pricing.deployed();

// Purchase subscription
await pricing.subscribe(tierLevel, duration, { value: subscriptionFee });

// Access data
const apiKey = await accessControl.generateApiKey();
```

#### 2. Retrieve Market Data
```javascript
// Via REST API
const response = await fetch(`${API_BASE_URL}/market-data/${symbol}`, {
  headers: {
    'Authorization': `Bearer ${apiKey}`,
    'Content-Type': 'application/json'
  }
});

// Via WebSocket
const ws = new WebSocket(`wss://ws.your-domain.com/market-data`);
ws.send(JSON.stringify({ 
  action: 'subscribe', 
  symbols: ['BTC/USD', 'ETH/USD'],
  apiKey: apiKey 
}));
```

## API Reference

### REST Endpoints

#### Market Data
- `GET /market-data/{symbol}` - Get latest price for symbol
- `GET /market-data/{symbol}/history` - Get historical data
- `GET /market-data/symbols` - List all available symbols

#### Provider Management
- `POST /providers/register` - Register new data provider
- `GET /providers/{address}/reputation` - Get provider reputation score
- `POST /providers/{address}/stake` - Add stake to provider

#### Subscription Management
- `POST /subscriptions/purchase` - Purchase data subscription
- `GET /subscriptions/status` - Check subscription status
- `POST /subscriptions/cancel` - Cancel subscription

### WebSocket Events

#### Subscription Events
```javascript
{
  "event": "price_update",
  "symbol": "BTC/USD",
  "price": 45000.50,
  "timestamp": 1640995200000,
  "provider": "0x...",
  "quality_score": 0.98
}
```

## Data Quality Metrics

The system tracks several quality metrics for each data provider:

- **Accuracy Score**: Percentage of data points within acceptable variance
- **Latency Score**: Average time to provide data after market events
- **Uptime Score**: Percentage of time provider is available
- **Consistency Score**: Variance from consensus price across providers
- **Overall Quality Score**: Weighted average of all metrics

## Subscription Tiers

| Tier | Price/Month | Rate Limit | Historical Data | Latency |
|------|-------------|------------|-----------------|---------|
| Basic | $50 | 1000 req/min | 30 days | ~1s |
| Professional | $200 | 5000 req/min | 1 year | ~500ms |
| Enterprise | $1000 | 20000 req/min | 5 years | ~100ms |
| Institutional | Custom | Unlimited | Full history | ~50ms |

## Security Considerations

- All data providers must stake tokens as collateral
- Multi-signature wallets required for admin functions
- Regular smart contract audits
- Encrypted data transmission
- DDoS protection at API layer
- Rate limiting and abuse detection

## Governance

The platform uses a DAO governance model where token holders can:

- Vote on parameter changes (fees, quality thresholds)
- Approve new data sources and symbols
- Decide on protocol upgrades
- Manage treasury funds

## Contributing

We welcome contributions from the community. Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on:

- Code style and standards
- Testing requirements
- Pull request process
- Bug reporting
- Feature requests

## Testing

```bash
# Run unit tests
npm test

# Run integration tests
npm run test:integration

# Generate coverage report
npm run coverage

# Run gas optimization tests
npm run test:gas
```

## Monitoring and Analytics

The system includes comprehensive monitoring:

- **Provider Performance Dashboard**: Real-time metrics for data providers
- **Quality Analytics**: Historical accuracy and performance trends
- **Network Health**: System uptime and performance metrics
- **Financial Metrics**: Revenue, subscription trends, and provider earnings

## Roadmap

### Phase 1 (Current)
- [x] Core contract development
- [x] Basic API implementation
- [x] Provider verification system
- [ ] Mainnet deployment

### Phase 2 (Q2 2025)
- [ ] Advanced quality algorithms
- [ ] Mobile SDK release
- [ ] Additional asset classes (commodities, forex)
- [ ] Institutional partnerships

### Phase 3 (Q3 2025)
- [ ] Layer 2 scaling solutions
- [ ] Cross-chain data bridges
- [ ] AI-powered data validation
- [ ] Derivative data products

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Documentation**: [docs.your-domain.com](https://docs.your-domain.com)
- **Discord**: [Join our community](https://discord.gg/your-invite)
- **Email**: support@your-domain.com
- **Bug Reports**: [GitHub Issues](https://github.com/your-org/defi-market-data/issues)

## Acknowledgments

- Thanks to all data providers and early adopters
- Special recognition to our security audit partners
- Community contributors and beta testers
- Open source libraries and tools used in this project
