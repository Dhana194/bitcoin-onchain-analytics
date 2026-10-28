-- Project: Bitcoin On-Chain Analytics
-- Query: Daily Bitcoin on-chain metrics
-- Source: Dune Analytics
-- Time window: Rolling 180 days
--
-- Purpose:
-- Combine Bitcoin price, transaction activity, output values,
-- large transaction counts, and transaction fees.
--
-- Outputs:
-- tx_count, large_tx_count, whale_share, value_moved_usd,
-- avg_tx_usd, avg_fee_usd, btc_price_usd.

WITH params AS (
  SELECT
    now() - interval '180' day AS start_time,
    10.0 AS large_tx_threshold_btc -- <-- soglia: 10 BTC (modifica qui se vuoi)
),

btc_price AS (
  SELECT
    date_trunc('day', timestamp) AS day,
    AVG(CAST(price AS double)) AS btc_price_usd
  FROM prices.day
  WHERE blockchain = 'bitcoin'
    AND symbol = 'BTC'
    AND timestamp >= (SELECT start_time FROM params)
  GROUP BY 1
),

-- Convertiamo ogni output in BTC in modo coerente
outputs_btc AS (
  SELECT
    o.block_time,
    o.tx_id,
    CASE
      WHEN CAST(o.value AS double) > 1e9 THEN CAST(o.value AS double) / 1e8
      ELSE CAST(o.value AS double)
    END AS output_value_btc
  FROM bitcoin.outputs o
  JOIN params p
    ON o.block_time >= p.start_time
),

daily_activity_raw AS (
  SELECT
    date_trunc('day', block_time) AS day,
    COUNT(DISTINCT tx_id) AS tx_count,
    SUM(output_value_btc) AS btc_transferred
  FROM outputs_btc
  GROUP BY 1
),

-- NEW: conta le tx che hanno almeno 1 output "grande"
daily_large_tx AS (
  SELECT
    date_trunc('day', block_time) AS day,
    COUNT(DISTINCT tx_id) AS large_tx_count
  FROM outputs_btc
  WHERE output_value_btc >= (SELECT large_tx_threshold_btc FROM params)
  GROUP BY 1
),

daily_fees_raw AS (
  SELECT
    date_trunc('day', t.block_time) AS day,
    AVG(CAST(t.fee AS double)) AS fee_avg_raw
  FROM bitcoin.transactions t
  JOIN params p
    ON t.block_time >= p.start_time
  GROUP BY 1
),

daily_fees AS (
  SELECT
    day,
    CASE
      WHEN fee_avg_raw > 1 THEN fee_avg_raw / 1e8
      ELSE fee_avg_raw
    END AS avg_fee_btc
  FROM daily_fees_raw
)

SELECT
  a.day,

  -- 1) Network activity
  a.tx_count,

  -- NEW) Large transactions proxy (tx con almeno 1 output >= soglia BTC)
  COALESCE(l.large_tx_count, 0) AS large_tx_count,
  ROUND(
  COALESCE(l.large_tx_count, 0) * 1.0 / NULLIF(a.tx_count, 0),
  4
) AS whale_share,

  -- 2) Value moved (USD)
  ROUND(a.btc_transferred * p.btc_price_usd, 0) AS value_moved_usd,

  -- 3) Avg transaction size (USD)
  ROUND((a.btc_transferred / NULLIF(a.tx_count, 0)) * p.btc_price_usd, 2) AS avg_tx_usd,

  -- 4) Avg fee per transaction (USD)
  ROUND(f.avg_fee_btc * p.btc_price_usd, 2) AS avg_fee_usd,

  -- helpful
  ROUND(p.btc_price_usd, 0) AS btc_price_usd

FROM daily_activity_raw a
LEFT JOIN daily_large_tx l
  ON a.day = l.day
LEFT JOIN daily_fees f
  ON a.day = f.day
LEFT JOIN btc_price p
  ON a.day = p.day
ORDER BY a.day;
