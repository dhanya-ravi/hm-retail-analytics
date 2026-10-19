
-- =====================================================
-- Analysis: Customer Purchase Frequency
-- Business question:
-- How frequently do customers make purchases during the observed dataset period?
--
-- Metrics:
-- 1. Number of distinct purchase days per customer
-- 2. Number and percentage of customers by frequency group
-- 3. Average purchase lines per customer in each group
--
-- Method:
-- Counts distinct transaction dates for each customer,groups customers by purchase frequency, and summarizes
-- customer counts and average purchase lines.
--
-- Limitations:
-- Purchase days are not the same as orders or sessions.
-- Purchase lines are not unique orders.
-- Frequency reflects the full observed dataset period,so customers with different observation periods may
-- have different opportunities to accumulate purchases.
-- =====================================================

WITH customer_frequency AS (
    SELECT
        customer_id,
        COUNT(*) AS purchase_lines,
        COUNT(DISTINCT transaction_date) AS purchase_days
    FROM transactions
    GROUP BY customer_id
),
frequency_groups AS (
    SELECT
        customer_id,
        purchase_lines,
        purchase_days,
        CASE
            WHEN purchase_days = 1 THEN '1 day'
            WHEN purchase_days BETWEEN 2 AND 3 THEN '2-3 days'
            WHEN purchase_days BETWEEN 4 AND 6 THEN '4-6 days'
            ELSE '7+ days'
        END AS frequency_group
    FROM customer_frequency
)
SELECT
    frequency_group,
    COUNT(*) AS customers,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_customers,
    ROUND(AVG(purchase_lines), 2) AS avg_purchase_lines
FROM frequency_groups
GROUP BY frequency_group
ORDER BY MIN(purchase_days);
