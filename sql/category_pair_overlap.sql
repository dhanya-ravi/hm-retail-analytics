
-- =====================================================
-- Analysis: Category-Pair Customer Overlap
-- Business question:
-- Which pairs of garment groups share the largest number of customers?
--
-- Metrics:
-- 1. Number of distinct customers purchasing both groups
-- 2. Percentage of all observed customers purchasing both
--
-- Method:
-- Builds a distinct customer-category mapping and self-joins it to identify category pairs.
--
-- Limitation:
-- Shared customers may have purchased categories on different dates; this does not prove same-order affinity.
-- Popular categories may have high overlap simply because they reach more customers.
-- =====================================================

WITH customer_categories AS (
    SELECT DISTINCT
        t.customer_id,
        a.garment_group_name
    FROM transactions AS t
    JOIN articles AS a
        ON t.article_id = a.article_id
    WHERE a.garment_group_name IS NOT NULL
),
total_customers AS (
    SELECT COUNT(DISTINCT customer_id) AS total_customers
    FROM transactions
)
SELECT
    c1.garment_group_name AS category_1,
    c2.garment_group_name AS category_2,
    COUNT(*) AS shared_customers,
    ROUND(
        100.0 * COUNT(*) / tc.total_customers,
        2
    ) AS pct_of_all_customers
FROM customer_categories AS c1
JOIN customer_categories AS c2
    ON c1.customer_id = c2.customer_id
   AND c1.garment_group_name < c2.garment_group_name
CROSS JOIN total_customers AS tc
GROUP BY
    c1.garment_group_name,
    c2.garment_group_name,
    tc.total_customers
ORDER BY
    shared_customers DESC
LIMIT 30;
