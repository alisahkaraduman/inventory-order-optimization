-- =========================================
-- Indexes for Query Performance
-- =========================================

CREATE INDEX idx_order_items_product_id
ON order_items(product_id);

CREATE INDEX idx_order_items_order_id
ON order_items(order_id);

CREATE INDEX idx_orders_status
ON orders(status);

CREATE INDEX idx_orders_order_date
ON orders(order_date);

CREATE INDEX idx_inventory_product_warehouse
ON inventory(product_id, warehouse_id);

CREATE INDEX idx_stock_transactions_product_warehouse
ON stock_transactions(product_id, warehouse_id);

CREATE INDEX idx_stock_transactions_date
ON stock_transactions(transaction_date);