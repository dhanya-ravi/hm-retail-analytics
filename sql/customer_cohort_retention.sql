
-- =====================================================
-- Analysis: Customer Cohort Retention
-- Business question:
-- What percentage of customers return to purchase in subsequent months after their first observed purchase?
--
-- Metrics:
-- 1. Customer acquisition cohort month
-- 2. Number of months since first observed purchase
-- 3. Active customers in each cohort and activity month
-- 4. Monthly retention percentage
--
-- Method:
-- Assigns each customer to the month of their first observed purchase, identifies the months in which each
-- customer purchased, and calculates the percentage of the original cohort active in each subsequent month.
--
-- Retention definition:
-- A customer is retained in a month if they have at least one observed transaction during that calendar month.
-- Customers may return after skipping one or more months.
--
-- Limitations:
-- The first observed purchase is not necessarily the customer's first-ever purchase from H&M.
-- Month 0 represents the initial cohort month, not repeat retention.
-- The latest cohorts have fewer subsequent months available.
-- Monthly activity does not necessarily represent unique
-- orders or shopping sessions.
-- =====================================================

WITH customer_first_purchase AS (
    SELECT
        customer_id,
        MIN(transaction_date) AS first_purchase_date
    FROM transactions
    GROUP BY customer_id
),
customer_cohorts AS (
    SELECT
        customer_id,
        STR_TO_DATE(
            DATE_FORMAT(first_purchase_date, '%Y-%m-01'),
            '%Y-%m-%d'
        ) AS cohort_month
    FROM customer_first_purchase
),
customer_monthly_activity AS (
    SELECT DISTINCT
        customer_id,
        STR_TO_DATE(
            DATE_FORMAT(transaction_date, '%Y-%m-01'),
            '%Y-%m-%d'
        ) AS activity_month
    FROM transactions
),
cohort_activity AS (
    SELECT
        cc.customer_id,
        cc.cohort_month,
        cma.activity_month,
        TIMESTAMPDIFF(
            MONTH,
            cc.cohort_month,
            cma.activity_month
        ) AS months_since_first_purchase
    FROM customer_cohorts cc
    JOIN customer_monthly_activity cma
        ON cc.customer_id = cma.customer_id
),
cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(*) AS cohort_customers
    FROM customer_cohorts
    GROUP BY cohort_month
),
monthly_retention AS (
    SELECT
        cohort_month,
        months_since_first_purchase,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM cohort_activity
    GROUP BY
        cohort_month,
        months_since_first_purchase
)
SELECT
    DATE_FORMAT(mr.cohort_month, '%Y-%m') AS cohort_month,
    mr.months_since_first_purchase,
    cs.cohort_customers,
    mr.active_customers,
    ROUND(
        100.0 * mr.active_customers / cs.cohort_customers,
        2
    ) AS retention_pct
FROM monthly_retention mr
JOIN cohort_sizes cs
    ON mr.cohort_month = cs.cohort_month
ORDER BY
    mr.cohort_month,
    mr.months_since_first_purchase;
