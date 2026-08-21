-- =========================================
-- Inventory Turnover Analysis
-- =========================================

WITH sold_units AS (
    SELECT
        oi.product_id,
        SUM(oi.quantity) AS total_units_sold
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.status = 'COMPLETED'
    GROUP BY oi.product_id
),

inventory_totals AS (
    SELECT
        product_id,
        SUM(current_stock) AS total_current_stock
    FROM inventory
    GROUP BY product_id
)

SELECT
    p.product_id,
    p.product_name,
    p.category,
    COALESCE(s.total_units_sold, 0) AS total_units_sold,
    i.total_current_stock,
    ROUND(
        COALESCE(s.total_units_sold, 0)::NUMERIC
        / NULLIF(i.total_current_stock, 0),
        2
    ) AS inventory_turnover_ratio
FROM products p
JOIN inventory_totals i
    ON p.product_id = i.product_id
LEFT JOIN sold_units s
    ON p.product_id = s.product_id
ORDER BY inventory_turnover_ratio DESC;