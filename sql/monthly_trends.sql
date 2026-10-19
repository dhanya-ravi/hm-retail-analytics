-- =====================================================
-- Analysis: Monthly Retail Trends
-- Business question:
-- How do monthly item-line volume and active customer counts change over the analysis period?
--
-- Metrics:
-- 1. Total item-line count per month
-- 2. Distinct active customers per month
--
-- Method:
-- Groups transaction records by calendar month and counts item lines and distinct customers.
--
-- Limitation:
-- Item-line volume does not measure revenue or profit.
-- Monthly active-customer counts cannot be summed to calculate unique customers across the full period.
-- September 2018 and September 2020 are partial months.
-- =====================================================

SELECT
    DATE_FORMAT(transaction_date, '%Y-%m') AS month,
    COUNT(*) AS item_lines,
    COUNT(DISTINCT customer_id) AS active_customers
FROM transactions
GROUP BY month
ORDER BY month;
