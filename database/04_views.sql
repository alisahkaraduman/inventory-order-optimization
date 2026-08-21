CREATE OR REPLACE VIEW low_stock_products AS
SELECT
    i.inventory_id,
    p.product_id,
    p.product_name,
    w.warehouse_id,
    w.warehouse_name,
    i.current_stock,
    i.safety_stock,
    i.reorder_point
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id
WHERE i.current_stock <= i.reorder_point;


CREATE OR REPLACE VIEW inventory_summary AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    w.warehouse_name,
    i.current_stock,
    i.safety_stock,
    i.reorder_point,
    CASE
        WHEN i.current_stock <= i.safety_stock THEN 'CRITICAL'
        WHEN i.current_stock <= i.reorder_point THEN 'REORDER'
        ELSE 'HEALTHY'
    END AS stock_status
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id;