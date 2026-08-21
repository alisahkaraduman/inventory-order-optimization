WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    WHERE o.status = 'COMPLETED'
    GROUP BY
        p.product_id,
        p.product_name,
        p.category
),
ranked_products AS (
    SELECT
        product_id,
        product_name,
        category,
        revenue,
        SUM(revenue) OVER (
            ORDER BY revenue DESC
        ) AS cumulative_revenue,
        SUM(revenue) OVER () AS total_revenue
    FROM product_revenue
)
SELECT
    product_id,
    product_name,
    category,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        cumulative_revenue
        / NULLIF(total_revenue, 0)
        * 100,
        2
    ) AS cumulative_percentage,
    CASE
        WHEN cumulative_revenue
             / NULLIF(total_revenue, 0) <= 0.80
            THEN 'A'
        WHEN cumulative_revenue
             / NULLIF(total_revenue, 0) <= 0.95
            THEN 'B'
        ELSE 'C'
    END AS abc_class
FROM ranked_products
ORDER BY revenue DESC;