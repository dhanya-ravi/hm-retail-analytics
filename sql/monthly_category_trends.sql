-- =====================================================
-- Analysis: Monthly Product Category Trends
-- Business question:
-- How does garment-group item-line volume and share change over time?
--
-- Metrics:
-- 1. Monthly item-line count by garment group
-- 2. Percentage of each month's total item-line volume
--
-- Method:
-- Groups transaction records by month and garment group.
-- A window function calculates each group's share within its respective month.
--
-- Limitation:
-- Item-line volume does not measure revenue or profit.
-- September 2018 and September 2020 are partial months.
-- Monthly changes alone do not establish seasonality or explain why demand patterns changed.
-- =====================================================
SELECT
    DATE_FORMAT(t.transaction_date, '%Y-%m') AS month,
    a.garment_group_name,
    COUNT(*) AS item_lines,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (
            PARTITION BY DATE_FORMAT(t.transaction_date, '%Y-%m')
        ),
        2
    ) AS pct_of_monthly_item_lines
FROM transactions AS t
JOIN articles AS a
    ON t.article_id = a.article_id
GROUP BY
    DATE_FORMAT(t.transaction_date, '%Y-%m'),
    a.garment_group_name
ORDER BY
    month,
    item_lines DESC;