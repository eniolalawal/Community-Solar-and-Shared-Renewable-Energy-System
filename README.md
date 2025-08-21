# Community Solar and Shared Renewable Energy System

A comprehensive blockchain-based platform for managing community solar projects, subscriber allocations, energy credit distribution, and transparent billing coordination.

## Overview

This system enables communities to collectively invest in and benefit from solar energy installations through smart contracts that manage:

- **Subscriber Management**: Registration, allocation, and energy credit distribution
- **Solar Panel Operations**: Performance tracking, maintenance scheduling, and grid integration
- **Financial Coordination**: Transparent billing, net metering, and investment participation
- **Energy Storage**: Battery management and grid coordination
- **Community Governance**: Ownership participation and decision-making

## Smart Contracts

### 1. Subscriber Management (`subscriber-management.clar`)
- Handles subscriber registration and energy allocation
- Manages energy credit distribution based on subscription levels
- Tracks subscriber balances and payment history

### 2. Solar Panel Operations (`solar-panel-operations.clar`)
- Monitors solar panel performance and energy generation
- Schedules maintenance and tracks operational status
- Manages grid integration and energy output reporting

### 3. Billing Coordination (`billing-coordination.clar`)
- Provides transparent billing calculations
- Handles net metering coordination with utility companies
- Manages payment processing and credit applications

### 4. Community Investment (`community-investment.clar`)
- Enables community ownership and investment participation
- Tracks ownership stakes and dividend distributions
- Manages voting rights and governance decisions

### 5. Energy Storage Management (`energy-storage-management.clar`)
- Coordinates battery storage systems
- Manages energy storage and release cycles
- Optimizes grid integration and load balancing

## Key Features

- **Transparent Operations**: All transactions and operations recorded on blockchain
- **Fair Distribution**: Automated energy credit allocation based on subscription levels
- **Community Ownership**: Democratic participation in solar project governance
- **Grid Integration**: Seamless coordination with existing utility infrastructure
- **Performance Monitoring**: Real-time tracking of solar panel efficiency and maintenance needs

## Data Types

- **Subscribers**: Community members with energy allocations
- **Solar Panels**: Individual panel units with performance metrics
- **Energy Credits**: Tradeable units representing generated solar energy
- **Maintenance Records**: Scheduled and completed maintenance activities
- **Investment Stakes**: Ownership percentages in community solar projects

## Getting Started

1. Deploy the smart contracts to the Stacks blockchain
2. Initialize the system with solar panel specifications
3. Register community subscribers and their allocations
4. Begin energy generation tracking and credit distribution
5. Monitor performance and coordinate maintenance activities

## Testing

Run the comprehensive test suite with:
\`\`\`bash
npm test
\`\`\`

Tests cover all contract functionality including edge cases and error conditions.
