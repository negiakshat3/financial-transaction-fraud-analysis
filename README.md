# Financial Transaction Fraud & Anomaly Analysis Using SQL

## Project Overview

This project analyzes financial transactions using PostgreSQL to identify patterns associated with fraudulent activity. The analysis focuses on transaction types, transaction amounts, fraud rates, balance discrepancies, and high-value transactions.

The goal is to turn transaction data into meaningful business insights that could help inform fraud monitoring and risk investigation.

## Dataset

- **Dataset:** PaySim Synthetic Financial Dataset
- **Source:** [Kaggle – PaySim Dataset](https://www.kaggle.com/datasets/ealaxi/paysim1)
- **Total Transactions:** 6,362,620
- **Fraud-Labeled Transactions:** 8,213

PaySim is a synthetic financial transaction dataset. Its results should not be interpreted as actual fraud rates in a real financial institution.

## Tools Used

- PostgreSQL
- SQL
- Visual Studio Code

## Business Questions

1. What percentage of transactions are labeled as fraudulent?
2. Which transaction types have the highest fraud rates?
3. How do transaction amounts differ between fraudulent and non-fraudulent transactions?
4. Which transaction types account for the largest fraud-labeled transaction value?
5. How do fraud rates vary across transaction amount ranges?
6. What patterns appear in high-value cash-out transactions?
7. Are sender balance discrepancies useful indicators of fraud?
8. Are there missing values in key transaction fields?

## Key Findings

- **Overall fraud rate:** Approximately 0.1291% of transactions are labeled as fraudulent.
- **Transaction types:** Transfer has the highest fraud rate, while cash-out has the highest number of fraud-labeled transactions.
- **Transaction amounts:** The average fraud-labeled transaction amount is approximately 8.24 times the average non-fraudulent transaction amount.
- **High-value cash-outs:** Fraud-labeled cash-out transactions of 1 million or above account for approximately 43.05% of the total fraud-labeled transaction value.
- **Balance discrepancies:** Simple sender balance mismatch rules did not reliably distinguish fraud-labeled transactions from non-fraudulent transactions.
- **Data quality:** No missing values were found in the five key fields checked.
- - The dataset's built-in fraud flag marked only 16 transactions, all labeled as fraud. These represented approximately 0.19% of fraud-labeled cases and 0.6452% of their total transaction value.

## SQL Concepts Practiced

- SELECT, WHERE, and ORDER BY
- Aggregate functions: COUNT, SUM, AVG, MIN, and MAX
- GROUP BY and conditional CASE expressions
- Filtering aggregated results
- Conditional aggregation using FILTER
- Calculating percentages and fraud rates
- Data quality checks
- Financial transaction analysis

## Repository Contents

- `fraud_analysis.sql` — SQL queries used for the analysis.
- `README.md` — Project documentation, methodology, and key findings.

## Conclusion

This project demonstrates how SQL can be used to explore large transaction datasets, compare fraud patterns, validate assumptions, and identify areas that may warrant further investigation.

The findings describe patterns in a synthetic dataset and do not establish that any transaction is fraudulent in a real-world setting.
