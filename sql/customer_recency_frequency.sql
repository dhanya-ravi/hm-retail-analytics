
-- =====================================================
-- Analysis: Customer Recency and Frequency Segmentation
-- Business question:
-- How can customers be grouped by how recently and how frequently they purchased during the observed dataset
-- period?
--
-- Metrics:
-- 1. Days since each customer's last observed purchase
-- 2. Distinct purchase days per customer
-- 3. Number and percentage of customers in each segment
--
-- Method:
-- Calculates customer-level recency and frequency, assigns each customer to a recency group and a frequency group,
-- and summarizes the resulting customer segments.
--
-- Limitations:
-- Recency is measured relative to the dataset's latest transaction date, not today's date.
-- Purchase days are not the same as orders or sessions.
-- Frequency covers the entire observed dataset period.
-- Long inactivity does not prove that a customer has churned.
-- Segment thresholds are descriptive and may need business
-- validation before they are used for targeting.
-- =====================================================

WITH dataset_date AS (
    SELECT MAX(transaction_date) AS latest_date
    FROM transactions
),
customer_metrics AS (
    SELECT
        customer_id,
        MAX(transaction_date) AS last_purchase_date,
        COUNT(DISTINCT transaction_date) AS purchase_days
    FROM transactions
    GROUP BY customer_id
),
customer_segments AS (
    SELECT
        cm.customer_id,
        DATEDIFF(
            dd.latest_date,
            cm.last_purchase_date
        ) AS days_since_last_purchase,
        cm.purchase_days,
        CASE
            WHEN DATEDIFF(dd.latest_date, cm.last_purchase_date) <= 30
                THEN '0-30 days'
            WHEN DATEDIFF(dd.latest_date, cm.last_purchase_date) <= 90
                THEN '31-90 days'
            WHEN DATEDIFF(dd.latest_date, cm.last_purchase_date) <= 180
                THEN '91-180 days'
            WHEN DATEDIFF(dd.latest_date, cm.last_purchase_date) <= 365
                THEN '181-365 days'
            ELSE 'Over 365 days'
        END AS recency_group,
        CASE
            WHEN cm.purchase_days = 1 THEN '1 day'
            WHEN cm.purchase_days BETWEEN 2 AND 3 THEN '2-3 days'
            WHEN cm.purchase_days BETWEEN 4 AND 6 THEN '4-6 days'
            ELSE '7+ days'
        END AS frequency_group
    FROM customer_metrics cm
    CROSS JOIN dataset_date dd
)
SELECT
    recency_group,
    frequency_group,
    COUNT(*) AS customers,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_customers
FROM customer_segments
GROUP BY
    recency_group,
    frequency_group
ORDER BY
    MIN(days_since_last_purchase),
    MIN(purchase_days);
