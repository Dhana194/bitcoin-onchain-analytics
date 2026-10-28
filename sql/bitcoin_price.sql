
-- Project: Bitcoin On-Chain Analytics
-- Query: Daily Bitcoin price over the last 180 days
-- Source: Dune Analytics
-- Purpose: Retrieve BTC price observations for comparison
-- with on-chain network activity.

SELECT
    date_trunc('day', timestamp) AS day,
    price
FROM prices.day
WHERE blockchain = 'bitcoin'
    AND symbol = 'BTC'
    AND timestamp >= now() - interval '180' day
ORDER BY day;
