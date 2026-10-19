
-- =====================================================
-- Analysis: Customer Recency
-- Business question:
-- How recently did customers make their last observed purchase during the dataset period?
--
-- Metrics:
-- 1. Days since last observed purchase
-- 2. Number and percentage of customers by recency group
--
-- Method:
-- Finds each customer's latest transaction date, then calculates days between that date and the dataset's
-- latest transaction date.
--
-- Limitation:
-- Recency is relative to the dataset end date, not today.
-- A long gap does not prove that a customer has churned.
-- =====================================================

WITH customer_last_purchase AS (
    SELECT
        customer_id,
        MAX(transaction_date) AS last_purchase_date
    FROM transactions
    GROUP BY customer_id
),
customer_recency AS (
    SELECT
        customer_id,
        last_purchase_date,
        DATEDIFF(
            (SELECT MAX(transaction_date) FROM transactions),
            last_purchase_date
        ) AS days_since_last_purchase
    FROM customer_last_purchase
)
SELECT
    CASE
        WHEN days_since_last_purchase <= 30 THEN '0-30 days'
        WHEN days_since_last_purchase <= 90 THEN '31-90 days'
        WHEN days_since_last_purchase <= 180 THEN '91-180 days'
        WHEN days_since_last_purchase <= 365 THEN '181-365 days'
        ELSE 'Over 365 days'
    END AS recency_group,
    COUNT(*) AS customers,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_customers
FROM customer_recency
GROUP BY
    CASE
        WHEN days_since_last_purchase <= 30 THEN '0-30 days'
        WHEN days_since_last_purchase <= 90 THEN '31-90 days'
        WHEN days_since_last_purchase <= 180 THEN '91-180 days'
        WHEN days_since_last_purchase <= 365 THEN '181-365 days'
        ELSE 'Over 365 days'
    END
ORDER BY
    MIN(days_since_last_purchase);
