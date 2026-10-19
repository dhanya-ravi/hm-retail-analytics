
-- =====================================================
-- Analysis: Customer Category Affinity
-- Business question:
-- Which garment groups have the broadest customer reach,
-- and how many customers purchase across categories?
--
-- Metrics:
-- 1. Distinct customers per garment group
-- 2. Percentage of all observed customers buying each group
--
-- Method:
-- Counts distinct customers associated with each garment group using the transaction and article tables.
--
-- Limitation:
-- Customers may purchase multiple garment groups, so percentages can add up to more than 100%.
-- Association does not prove that categories are bought together in the same order or shopping session.
-- =====================================================

SELECT
    a.garment_group_name,
    COUNT(DISTINCT t.customer_id) AS distinct_customers,
    ROUND(
        100.0 * COUNT(DISTINCT t.customer_id) /
        (SELECT COUNT(DISTINCT customer_id)
         FROM transactions),
        2
    ) AS pct_of_all_customers
FROM transactions AS t
JOIN articles AS a
    ON t.article_id = a.article_id
GROUP BY
    a.garment_group_name
ORDER BY
    distinct_customers DESC;
