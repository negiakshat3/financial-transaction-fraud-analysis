
-- =====================================================
-- PROJECT: Financial Transaction Fraud & Anomaly Analysis
-- DATABASE: PostgreSQL
-- DATASET: PaySim
-- PURPOSE: Explore transaction patterns and fraud labels
-- =====================================================

-- 1. Overall transaction and fraud summary
SELECT
    COUNT(*) AS total_transactions,
    SUM(isFraud) AS fraudulent_transactions,
    ROUND(
        SUM(isFraud)::NUMERIC / COUNT(*) * 100,
        4
    ) AS fraud_rate_percentage
FROM transactions;

-- 2. Fraud analysis by transaction type
SELECT
    type,
    COUNT(*) AS total_transactions,
    SUM(isFraud) AS fraudulent_transactions,
    ROUND(
        SUM(isFraud)::NUMERIC / COUNT(*) * 100,
        4
    ) AS fraud_rate_percentage
FROM transactions
GROUP BY type
ORDER BY fraud_rate_percentage DESC;

-- 3. Compare average transaction amounts
SELECT
    isFraud,
    COUNT(*) AS transaction_count,
    ROUND(AVG(amount), 2) AS average_amount,
    ROUND(MAX(amount), 2) AS maximum_amount,
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY isFraud
ORDER BY isFraud DESC;

-- 4. Data quality: check missing values
-- Missing value check across all columns

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(step) AS missing_step,
    COUNT(*) - COUNT(type) AS missing_type,
    COUNT(*) - COUNT(amount) AS missing_amount,
    COUNT(*) - COUNT(nameOrig) AS missing_nameOrig,
    COUNT(*) - COUNT(oldbalanceOrg) AS missing_oldbalanceOrg,
    COUNT(*) - COUNT(newbalanceOrig) AS missing_newbalanceOrig,
    COUNT(*) - COUNT(nameDest) AS missing_nameDest,
    COUNT(*) - COUNT(oldbalanceDest) AS missing_oldbalanceDest,
    COUNT(*) - COUNT(newbalanceDest) AS missing_newbalanceDest,
    COUNT(*) - COUNT(isFraud) AS missing_isFraud,
    COUNT(*) - COUNT(isFlaggedFraud) AS missing_isFlaggedFraud
FROM transactions;
-- 5. Total fraud value by transaction type
SELECT
    type,
    COUNT(*) AS fraud_cases,
    ROUND(SUM(amount), 2) AS total_fraud_amount,
    ROUND(AVG(amount), 2) AS average_fraud_amount,
    ROUND(MAX(amount), 2) AS largest_fraud_amount
FROM transactions
WHERE isFraud = 1
GROUP BY type
ORDER BY total_fraud_amount DESC;

-- 6. Fraud analysis by transaction type and amount band
SELECT
    type,
    CASE
        WHEN amount < 10000 THEN 'Under 10K'
        WHEN amount < 100000 THEN '10K-100K'
        WHEN amount < 1000000 THEN '100K-1M'
        ELSE '1M and above'
    END AS amount_band,
    COUNT(*) AS total_transactions,
    SUM(isFraud) AS fraud_cases,
    ROUND(
        SUM(isFraud)::NUMERIC / COUNT(*) * 100,
        4
    ) AS fraud_rate_percentage
FROM transactions

GROUP BY
    type,
    CASE
        WHEN amount < 10000 THEN 'Under 10K'
        WHEN amount < 100000 THEN '10K-100K'
        WHEN amount < 1000000 THEN '100K-1M'
        ELSE '1M and above'
    END
ORDER BY type, amount_band;


-- 7. High-value CASH_OUT fraud analysis
SELECT
    COUNT(*) AS large_cashout_fraud_cases,
    ROUND(SUM(amount), 2) AS total_fraud_amount,
    ROUND(AVG(amount), 2) AS average_fraud_amount,
    ROUND(MAX(amount), 2) AS largest_fraud_amount
FROM transactions
WHERE isFraud = 1
  AND type = 'CASH_OUT'
  AND amount >= 1000000;


  
-- 8. Evaluate the zero-balance fraud detection rule

WITH predictions AS (
    SELECT
        isFraud,
        CASE
            WHEN newbalanceOrig = 0 THEN 1
            ELSE 0
        END AS predicted_fraud
    FROM transactions
)
SELECT
    SUM(CASE
        WHEN predicted_fraud = 1 AND isFraud = 1
        THEN 1 ELSE 0
    END) AS true_positives,

    SUM(CASE
        WHEN predicted_fraud = 1 AND isFraud = 0
        THEN 1 ELSE 0
    END) AS false_positives,

    SUM(CASE
        WHEN predicted_fraud = 0 AND isFraud = 1
        THEN 1 ELSE 0
    END) AS false_negatives,

    ROUND(
        100.0 * SUM(CASE
            WHEN predicted_fraud = 1 AND isFraud = 1
            THEN 1 ELSE 0
        END)
        / NULLIF(SUM(CASE
            WHEN predicted_fraud = 1
            THEN 1 ELSE 0
        END), 0),
        2
    ) AS precision_pct,

    ROUND(
        100.0 * SUM(CASE
            WHEN predicted_fraud = 1 AND isFraud = 1
            THEN 1 ELSE 0
        END)
        / NULLIF(SUM(isFraud), 0),
        2
    ) AS recall_pct
FROM predictions;

-- 9. Evaluate the high-value transaction fraud rule

WITH predictions AS (
    SELECT
        isFraud,
        CASE
            WHEN type IN ('CASH_OUT', 'TRANSFER')
                 AND amount >= 1000000
            THEN 1
            ELSE 0
        END AS predicted_fraud
    FROM transactions
)
SELECT
    SUM(CASE
        WHEN predicted_fraud = 1 AND isFraud = 1
        THEN 1 ELSE 0
    END) AS true_positives,

    SUM(CASE
        WHEN predicted_fraud = 1 AND isFraud = 0
        THEN 1 ELSE 0
    END) AS false_positives,

    SUM(CASE
        WHEN predicted_fraud = 0 AND isFraud = 1
        THEN 1 ELSE 0
    END) AS false_negatives,

    ROUND(
        100.0 * SUM(CASE
            WHEN predicted_fraud = 1 AND isFraud = 1
            THEN 1 ELSE 0
        END)
        / NULLIF(SUM(CASE
            WHEN predicted_fraud = 1
            THEN 1 ELSE 0
        END), 0),
        2
    ) AS precision_pct,

    ROUND(
        100.0 * SUM(CASE
            WHEN predicted_fraud = 1 AND isFraud = 1
            THEN 1 ELSE 0
        END)
        / NULLIF(SUM(isFraud), 0),
        2
    ) AS recall_pct
FROM predictions;


-- 10. Rank transaction types by fraud rate

SELECT
    type,
    COUNT(*) AS total_transactions,
    SUM(isFraud) AS fraud_cases,
    ROUND(
        100.0 * SUM(isFraud) / COUNT(*),
        4
    ) AS fraud_rate_pct,
    RANK() OVER (
        ORDER BY
            1.0 * SUM(isFraud) / COUNT(*) DESC
    ) AS fraud_risk_rank
FROM transactions
GROUP BY type
ORDER BY fraud_risk_rank;


-- 11. Contribution of each transaction type

SELECT
    type,
    COUNT(*) AS total_transactions,
    SUM(isFraud) AS fraud_cases,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM transactions),
        2
    ) AS share_of_all_transactions_pct,
    ROUND(
        100.0 * SUM(isFraud) /
        NULLIF(
            (SELECT SUM(isFraud) FROM transactions),
            0
        ),
        2
    ) AS share_of_all_fraud_pct
FROM transactions
GROUP BY type
ORDER BY share_of_all_fraud_pct DESC;
