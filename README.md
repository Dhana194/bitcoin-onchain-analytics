# Bitcoin On-Chain Analytics

## Overview

This project explores Bitcoin blockchain activity through on-chain data analysis and data visualization.

The goal is to investigate blockchain metrics, identify trends over time, and translate on-chain data into meaningful insights.

## Objectives

- Explore Bitcoin network activity through on-chain metrics.
- Analyze changes in blockchain activity over time.
- Build data visualizations to communicate key insights.
- Document the analytical approach and SQL queries.

## Tools & Technologies

- Dune Analytics
- SQL
- Data Visualization

## Technical Implementation

The dashboard is powered by SQL queries developed in Dune Analytics.

The main query combines Bitcoin price data with on-chain activity metrics to produce a daily dataset covering a rolling 180-day window.

The analysis includes:

- Daily transaction count
- Total output value converted to USD
- Average transaction size in USD
- Large transactions with at least one output of 10 BTC or more
- Whale transaction share proxy
- Average transaction fees in USD
- Daily Bitcoin price in USD

### SQL Files

- [`bitcoin_price.sql`](sql/bitcoin_price.sql): retrieves Bitcoin price observations.
- [`bitcoin_onchain_metrics.sql`](sql/bitcoin_onchain_metrics.sql): combines price data, transaction activity, output values, large transaction indicators, and transaction fees.

### Technical Notes

The metrics are descriptive indicators of on-chain activity. They should not be interpreted as direct measures of unique users, investor identities, or the complete volume of cryptocurrency trading.

The whale transaction share is a proxy based on transactions containing at least one output of 10 BTC or more.
## Methodology

The project uses on-chain data available through Dune Analytics.

The analysis focuses on selected Bitcoin network metrics. Query logic, metric definitions, and findings will be documented to make the analysis easier to understand and reproduce where possible.

## Dashboard

Interactive dashboard: [Market Panic vs Network Reality (BTC)](https://dune.com/dhana24687890/btc-onchain-stress-drawdowns)

## Research

Read the full research report, including methodology, key observations, interpretation, and limitations: [Bitcoin — Does the Network Really Panic?](research.md)

## Key Findings

*To be completed after reviewing the dashboard and validating the results.*

## Limitations

On-chain metrics provide insights into blockchain activity but do not necessarily represent unique users, investor behavior, or market performance.

Results depend on data availability, metric definitions, and the selected time period.

## Disclaimer

This project is for educational and analytical purposes only. It does not constitute investment advice.
