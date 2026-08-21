# Project Analysis

## Problem

Inventory management requires organizations to maintain enough stock to meet demand while avoiding unnecessary inventory costs.

This project demonstrates how PostgreSQL can be used to manage inventory transactions and support inventory-related decisions using historical order data.

## Inventory Process

The simplified process used in the project is:

1. Products are supplied by suppliers.
2. Products are stored across multiple warehouses.
3. Inventory records maintain stock levels for each product and warehouse combination.
4. Orders represent product demand.
5. Stock movements are recorded as `RECEIPT` or `ISSUE` transactions.
6. PostgreSQL triggers automatically update stock quantities.
7. Historical data is analyzed for replenishment and inventory prioritization.

## Data Integrity

The database uses:

- Primary keys
- Foreign keys
- `NOT NULL` constraints
- `CHECK` constraints
- `UNIQUE` constraints
- Trigger-based validation

An `ISSUE` transaction is rejected when the requested quantity exceeds the available stock.

## Reorder Point

The project analyzes replenishment requirements using:

```text
Reorder Point =
Average Daily Demand × Supplier Lead Time
+ Safety Stock
```

Completed order history is used to estimate demand, while supplier lead time is obtained from the suppliers table.

## ABC Analysis

ABC analysis classifies products according to their contribution to completed-order revenue.

- **A:** high-value products
- **B:** medium-value products
- **C:** lower-value products

This allows inventory control efforts to focus more heavily on financially important products.

## KPI Analysis

The project includes queries for:

- Completed-order revenue
- Average order value
- Product demand
- Current inventory value
- Low-stock products
- Critical stock levels
- Monthly revenue
- Warehouse performance
- Order status distribution

## Database Automation

A PL/pgSQL trigger automatically processes stock transactions.

For `RECEIPT` transactions:

```text
Current Stock = Current Stock + Quantity
```

For `ISSUE` transactions:

```text
Current Stock = Current Stock - Quantity
```

The trigger prevents stock quantities from becoming negative.

## Performance Analysis

A composite index was tested on:

```text
stock_transactions(product_id, warehouse_id)
```

Measured execution times:

```text
Without index: 0.485 ms
With index:    0.075 ms
```

The indexed query executed approximately 6.5 times faster in this test.

Because the dataset is relatively small, PostgreSQL may still prefer sequential scans for queries that access a large portion of a table.

## Dataset

All data used in the project is synthetic and generated using Python.

A fixed random seed is used to keep the dataset reproducible.

No real company or confidential data is included.