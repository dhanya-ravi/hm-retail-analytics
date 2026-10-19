-- =====================================================
-- Analysis: Customer Purchase Frequency
-- Business question:
-- How frequently do customers purchase, and what share of customers are one-time versus repeat purchasers?
--
-- Metrics:
-- 1. Number of distinct customers by purchase frequency
-- 2. Percentage of customers in each frequency group
--
-- Method:
-- Counts each customer's distinct active purchase dates and groups customers by the number of purchase dates.
--
-- Limitation:
-- The dataset contains item-level records, not a verified order identifier. Distinct purchase dates are
-- used as a proxy and may not represent separate orders.
-- =====================================================

WITH customer_frequency AS (
    SELECT
        customer_id,
        COUNT(DISTINCT transaction_date) AS purchase_dates
    FROM transactions
    GROUP BY customer_id
),
frequency_groups AS (
    SELECT
        CASE
            WHEN purchase_dates = 1 THEN 'One purchase date'
            WHEN purchase_dates BETWEEN 2 AND 5 THEN '2-5 purchase dates'
            ELSE '6+ purchase dates'
        END AS frequency_group,
        COUNT(*) AS customers
    FROM customer_frequency
    GROUP BY
        CASE
            WHEN purchase_dates = 1 THEN 'One purchase date'
            WHEN purchase_dates BETWEEN 2 AND 5 THEN '2-5 purchase dates'
            ELSE '6+ purchase dates'
        END
)
SELECT
    frequency_group,
    customers,
    ROUND(
        100.0 * customers / SUM(customers) OVER (),
        2
    ) AS pct_of_customers
FROM frequency_groups
ORDER BY
    CASE frequency_group
        WHEN 'One purchase date' THEN 1
        WHEN '2-5 purchase dates' THEN 2
        ELSE 3
    END;