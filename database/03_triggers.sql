CREATE OR REPLACE FUNCTION update_inventory_after_transaction()
RETURNS TRIGGER
AS
$$
DECLARE
    available_stock INT;
BEGIN
    SELECT current_stock
    INTO available_stock
    FROM inventory
    WHERE product_id = NEW.product_id
      AND warehouse_id = NEW.warehouse_id;

    IF available_stock IS NULL THEN
        RAISE EXCEPTION
            'Inventory record not found for product_id %, warehouse_id %',
            NEW.product_id,
            NEW.warehouse_id;
    END IF;

    IF NEW.transaction_type = 'RECEIPT' THEN

        UPDATE inventory
        SET current_stock = current_stock + NEW.quantity
        WHERE product_id = NEW.product_id
          AND warehouse_id = NEW.warehouse_id;

    ELSIF NEW.transaction_type = 'ISSUE' THEN

        IF available_stock < NEW.quantity THEN
            RAISE EXCEPTION
                'Insufficient stock. Available: %, Requested: %',
                available_stock,
                NEW.quantity;
        END IF;

        UPDATE inventory
        SET current_stock = current_stock - NEW.quantity
        WHERE product_id = NEW.product_id
          AND warehouse_id = NEW.warehouse_id;

    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER trg_update_inventory_after_transaction
AFTER INSERT ON stock_transactions
FOR EACH ROW
EXECUTE FUNCTION update_inventory_after_transaction();