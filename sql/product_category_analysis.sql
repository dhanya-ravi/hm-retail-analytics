-- =====================================================
-- Analysis: Product Category Performance
-- Business question:
-- Which garment groups account for the largest share of item-line volume?
--
-- Metrics:
-- 1. Item-line count
-- 2. Percentage of total item-line volume
--
-- Limitation:
-- Item-line volume does not measure revenue or profit.
-- =====================================================

SELECT
    a.garment_group_name,
    COUNT(*) AS item_lines,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_item_lines
FROM transactions AS t
JOIN articles AS a
    ON t.article_id = a.article_id
GROUP BY
    a.garment_group_name
ORDER BY
    item_lines DESC;