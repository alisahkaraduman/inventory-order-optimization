WITH demand AS (
    SELECT
        oi.product_id,
        o.warehouse_id,
        SUM(oi.quantity) AS total_demand,
        COUNT(DISTINCT DATE(o.order_date)) AS active_days
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.status = 'COMPLETED'
    GROUP BY
        oi.product_id,
        o.warehouse_id
),
average_demand AS (
    SELECT
        product_id,
        warehouse_id,
        ROUND(
            total_demand::NUMERIC
            / NULLIF(active_days, 0),
            2
        ) AS average_daily_demand
    FROM demand
)
SELECT
    p.product_id,
    p.product_name,
    w.warehouse_name,
    s.lead_time_days,
    a.average_daily_demand,
    i.safety_stock,
    CEIL(
        a.average_daily_demand
        * s.lead_time_days
        + i.safety_stock
    ) AS calculated_reorder_point,
    i.reorder_point AS current_reorder_point,
    i.current_stock
FROM average_demand a
JOIN products p
    ON a.product_id = p.product_id
JOIN suppliers s
    ON p.supplier_id = s.supplier_id
JOIN inventory i
    ON a.product_id = i.product_id
    AND a.warehouse_id = i.warehouse_id
JOIN warehouses w
    ON a.warehouse_id = w.warehouse_id
ORDER BY
    calculated_reorder_point DESC;