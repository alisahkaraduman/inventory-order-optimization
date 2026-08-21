-- =========================================
-- Inventory & Order KPI Queries
-- =========================================


-- 1. Total completed order revenue

SELECT
    ROUND(
        SUM(oi.quantity * oi.unit_price),
        2
    ) AS total_completed_revenue
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.status = 'COMPLETED';


-- 2. Total completed orders

SELECT
    COUNT(*) AS total_completed_orders
FROM orders
WHERE status = 'COMPLETED';


-- 3. Average order value

SELECT
    ROUND(
        AVG(order_total),
        2
    ) AS average_order_value
FROM (
    SELECT
        o.order_id,
        SUM(
            oi.quantity * oi.unit_price
        ) AS order_total
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.status = 'COMPLETED'
    GROUP BY o.order_id
) completed_orders;


-- 4. Products currently below reorder point

SELECT
    COUNT(*) AS products_below_reorder_point
FROM inventory
WHERE current_stock <= reorder_point;


-- 5. Products currently below safety stock

SELECT
    COUNT(*) AS critical_inventory_records
FROM inventory
WHERE current_stock <= safety_stock;


-- 6. Total inventory units

SELECT
    SUM(current_stock) AS total_inventory_units
FROM inventory;


-- 7. Current inventory value

SELECT
    ROUND(
        SUM(
            i.current_stock * p.unit_price
        ),
        2
    ) AS current_inventory_value
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id;


-- 8. Warehouse inventory summary

SELECT
    w.warehouse_id,
    w.warehouse_name,
    SUM(i.current_stock) AS total_units,
    ROUND(
        SUM(
            i.current_stock * p.unit_price
        ),
        2
    ) AS inventory_value
FROM inventory i
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id
JOIN products p
    ON i.product_id = p.product_id
GROUP BY
    w.warehouse_id,
    w.warehouse_name
ORDER BY inventory_value DESC;


-- 9. Most demanded products

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.status = 'COMPLETED'
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 10;


-- 10. Order status distribution

SELECT
    status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*)::NUMERIC
        / SUM(COUNT(*)) OVER ()
        * 100,
        2
    ) AS percentage
FROM orders
GROUP BY status
ORDER BY order_count DESC;


-- 11. Monthly completed revenue

SELECT
    DATE_TRUNC(
        'month',
        o.order_date
    ) AS month,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price
        ),
        2
    ) AS monthly_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.status = 'COMPLETED'
GROUP BY
    DATE_TRUNC(
        'month',
        o.order_date
    )
ORDER BY month;


-- 12. Warehouse order performance

SELECT
    w.warehouse_name,
    COUNT(
        DISTINCT o.order_id
    ) AS completed_orders,
    SUM(oi.quantity) AS units_sold,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price
        ),
        2
    ) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN warehouses w
    ON o.warehouse_id = w.warehouse_id
WHERE o.status = 'COMPLETED'
GROUP BY
    w.warehouse_id,
    w.warehouse_name
ORDER BY revenue DESC;