# Inventory & Order Optimization System

A PostgreSQL-based inventory and order management project designed to track stock movements, manage orders, analyze inventory performance, and support replenishment decisions.

## Features

- Relational database design with PostgreSQL
- Supplier, product, warehouse, inventory, order and stock transaction management
- Automatic stock updates using PostgreSQL triggers
- Prevention of negative stock
- Low-stock monitoring
- Reorder point analysis
- Safety stock tracking
- ABC inventory analysis
- Inventory and order KPI queries
- Warehouse performance analysis
- Query optimization using indexes
- Synthetic data generation with Python

## Technologies

- PostgreSQL 18
- SQL
- PL/pgSQL
- Python
- DBeaver
- Rocky Linux
- Git
- GitHub

## Dataset

The project uses synthetic data generated with Python.

The dataset contains:

- 5 suppliers
- 3 warehouses
- 100 products
- 300 inventory records
- 1,500 orders
- Thousands of order items
- 3,000 stock transactions

A fixed random seed is used to keep the generated dataset reproducible.

## Inventory Automation

Stock movements are stored in the `stock_transactions` table.

Two transaction types are supported:

- `RECEIPT` for stock entering a warehouse
- `ISSUE` for stock leaving a warehouse

A PostgreSQL trigger automatically updates the corresponding inventory record after a stock transaction is inserted.

The trigger also prevents an `ISSUE` transaction when the requested quantity is greater than the available stock.

## Reorder Point Analysis

Reorder points are analyzed using historical demand.

```text
Reorder Point =
Average Daily Demand × Supplier Lead Time
+ Safety Stock
```

This formula is used to compare calculated replenishment needs with the current stock level.

## ABC Analysis

Products are classified according to their contribution to completed-order revenue.

- **A:** approximately the first 80% of cumulative value
- **B:** approximately 80% to 95%
- **C:** the remaining value

## KPI Analysis

The project includes SQL queries for:

- Total completed-order revenue
- Completed order count
- Average order value
- Current inventory value
- Low-stock records
- Critical inventory records
- Warehouse inventory value
- Most demanded products
- Monthly revenue
- Order status distribution
- Warehouse order performance

## Query Performance

A composite index was tested on:

```text
stock_transactions(product_id, warehouse_id)
```

Performance results:

| Test | Execution Time |
|---|---:|
| Without index | 0.485 ms |
| With index | 0.075 ms |

In this test, the indexed query executed approximately **6.5 times faster**.

For broader queries on relatively small tables, PostgreSQL may still choose sequential scans when they are estimated to be cheaper.

## Project Structure

```text
inventory-order-optimization/
├── analytics/
│   ├── abc_analysis.sql
│   ├── inventory_turnover.sql
│   ├── kpi_queries.sql
│   └── reorder_point.sql
├── data/
│   └── generate_data.py
├── database/
│   ├── 01_schema.sql
│   ├── 02_seed_data.sql
│   ├── 03_triggers.sql
│   ├── 04_views.sql
│   └── 05_indexes.sql
├── docs/
└── README.md
```

## Notes

All data used in this repository is synthetic.

No confidential or real company data is included.