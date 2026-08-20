import random
from datetime import datetime, timedelta
from pathlib import Path

# --------------------------------------------------
# Configuration
# --------------------------------------------------

random.seed(42)

NUM_SUPPLIERS = 5
NUM_WAREHOUSES = 3
NUM_PRODUCTS = 100
NUM_ORDERS = 1500
NUM_STOCK_TRANSACTIONS = 3000

# Fixed date so the generated dataset is always identical.
END_DATE = datetime(2026, 8, 20, 12, 0, 0)
START_DATE = END_DATE - timedelta(days=180)


# --------------------------------------------------
# Suppliers
# --------------------------------------------------

suppliers = [
    ("Atlas Supply", 4),
    ("Nova Industrial", 7),
    ("Marmara Trade", 5),
    ("Anka Logistics", 10),
    ("Delta Components", 6),
]


# --------------------------------------------------
# Warehouses
# --------------------------------------------------

warehouses = [
    ("Istanbul Warehouse", "Istanbul"),
    ("Ankara Warehouse", "Ankara"),
    ("Izmir Warehouse", "Izmir"),
]


# --------------------------------------------------
# Products
# --------------------------------------------------

categories = [
    "Electronics",
    "Office",
    "Industrial",
    "Packaging",
    "Maintenance",
]

products = []

for product_id in range(1, NUM_PRODUCTS + 1):
    product_name = f"Product {product_id:03d}"
    category = random.choice(categories)
    unit_price = round(random.uniform(20, 2500), 2)
    supplier_id = random.randint(1, NUM_SUPPLIERS)

    products.append(
        (
            product_name,
            category,
            unit_price,
            supplier_id,
        )
    )


# --------------------------------------------------
# Initial Inventory
# --------------------------------------------------

inventory_records = []

# Used only while generating valid stock transactions.
stock_levels = {}

for product_id in range(1, NUM_PRODUCTS + 1):
    for warehouse_id in range(1, NUM_WAREHOUSES + 1):

        safety_stock = random.randint(10, 40)

        reorder_point = random.randint(
            safety_stock + 10,
            safety_stock + 80,
        )

        current_stock = random.randint(50, 250)

        inventory_records.append(
            (
                product_id,
                warehouse_id,
                current_stock,
                safety_stock,
                reorder_point,
            )
        )

        stock_levels[(product_id, warehouse_id)] = current_stock


# --------------------------------------------------
# Orders and Order Items
# --------------------------------------------------

orders = []
order_items = []

for order_id in range(1, NUM_ORDERS + 1):

    warehouse_id = random.randint(
        1,
        NUM_WAREHOUSES,
    )

    order_date = START_DATE + timedelta(
        days=random.randint(0, 180),
        hours=random.randint(0, 23),
        minutes=random.randint(0, 59),
    )

    status = random.choices(
        ["COMPLETED", "PENDING", "CANCELLED"],
        weights=[80, 15, 5],
        k=1,
    )[0]

    orders.append(
        (
            warehouse_id,
            order_date,
            status,
        )
    )

    number_of_items = random.randint(1, 5)

    selected_product_ids = random.sample(
        range(1, NUM_PRODUCTS + 1),
        number_of_items,
    )

    for product_id in selected_product_ids:

        quantity = random.randint(1, 10)

        unit_price = products[
            product_id - 1
        ][2]

        order_items.append(
            (
                order_id,
                product_id,
                quantity,
                unit_price,
            )
        )


# --------------------------------------------------
# Stock Transactions
# --------------------------------------------------

stock_transactions = []

for _ in range(NUM_STOCK_TRANSACTIONS):

    product_id = random.randint(
        1,
        NUM_PRODUCTS,
    )

    warehouse_id = random.randint(
        1,
        NUM_WAREHOUSES,
    )

    key = (
        product_id,
        warehouse_id,
    )

    current_stock = stock_levels[key]

    transaction_type = random.choices(
        ["RECEIPT", "ISSUE"],
        weights=[45, 55],
        k=1,
    )[0]

    if transaction_type == "RECEIPT":

        quantity = random.randint(
            1,
            25,
        )

        stock_levels[key] += quantity

    else:

        # Prevent negative stock.
        if current_stock == 0:

            transaction_type = "RECEIPT"

            quantity = random.randint(
                5,
                25,
            )

            stock_levels[key] += quantity

        else:

            maximum_issue = min(
                25,
                current_stock,
            )

            quantity = random.randint(
                1,
                maximum_issue,
            )

            stock_levels[key] -= quantity

    transaction_date = START_DATE + timedelta(
        days=random.randint(0, 180),
        hours=random.randint(0, 23),
        minutes=random.randint(0, 59),
    )

    stock_transactions.append(
        (
            product_id,
            warehouse_id,
            transaction_type,
            quantity,
            transaction_date,
        )
    )


# --------------------------------------------------
# SQL Output
# --------------------------------------------------

output_path = (
    Path(__file__).resolve().parent.parent
    / "database"
    / "02_seed_data.sql"
)

with open(
    output_path,
    "w",
    encoding="utf-8",
) as file:

    file.write(
        "-- =============================================\n"
    )
    file.write(
        "-- Synthetic Seed Data\n"
    )
    file.write(
        "-- Generated deterministically with seed 42\n"
    )
    file.write(
        "-- =============================================\n\n"
    )

    # Suppliers

    file.write("-- Suppliers\n\n")

    for (
        supplier_name,
        lead_time_days,
    ) in suppliers:

        file.write(
            "INSERT INTO suppliers "
            "(supplier_name, lead_time_days) "
            f"VALUES ('{supplier_name}', "
            f"{lead_time_days});\n"
        )

    file.write("\n\n")

    # Warehouses

    file.write("-- Warehouses\n\n")

    for (
        warehouse_name,
        location,
    ) in warehouses:

        file.write(
            "INSERT INTO warehouses "
            "(warehouse_name, location) "
            f"VALUES ('{warehouse_name}', "
            f"'{location}');\n"
        )

    file.write("\n\n")

    # Products

    file.write("-- Products\n\n")

    for (
        product_name,
        category,
        unit_price,
        supplier_id,
    ) in products:

        file.write(
            "INSERT INTO products "
            "(product_name, category, "
            "unit_price, supplier_id) "
            f"VALUES ('{product_name}', "
            f"'{category}', "
            f"{unit_price}, "
            f"{supplier_id});\n"
        )

    file.write("\n\n")

    # Inventory

    file.write("-- Initial Inventory\n\n")

    for (
        product_id,
        warehouse_id,
        current_stock,
        safety_stock,
        reorder_point,
    ) in inventory_records:

        file.write(
            "INSERT INTO inventory "
            "(product_id, warehouse_id, "
            "current_stock, safety_stock, "
            "reorder_point) "
            f"VALUES ({product_id}, "
            f"{warehouse_id}, "
            f"{current_stock}, "
            f"{safety_stock}, "
            f"{reorder_point});\n"
        )

    file.write("\n\n")

    # Orders

    file.write("-- Orders\n\n")

    for (
        warehouse_id,
        order_date,
        status,
    ) in orders:

        formatted_date = order_date.strftime(
            "%Y-%m-%d %H:%M:%S"
        )

        file.write(
            "INSERT INTO orders "
            "(warehouse_id, order_date, status) "
            f"VALUES ({warehouse_id}, "
            f"'{formatted_date}', "
            f"'{status}');\n"
        )

    file.write("\n\n")

    # Order Items

    file.write("-- Order Items\n\n")

    for (
        order_id,
        product_id,
        quantity,
        unit_price,
    ) in order_items:

        file.write(
            "INSERT INTO order_items "
            "(order_id, product_id, quantity, unit_price) "
            f"VALUES ({order_id}, "
            f"{product_id}, "
            f"{quantity}, "
            f"{unit_price});\n"
        )

    file.write("\n\n")

    # Stock Transactions

    file.write("-- Stock Transactions\n\n")

    for (
        product_id,
        warehouse_id,
        transaction_type,
        quantity,
        transaction_date,
    ) in stock_transactions:

        formatted_date = transaction_date.strftime(
            "%Y-%m-%d %H:%M:%S"
        )

        file.write(
            "INSERT INTO stock_transactions "
            "(product_id, warehouse_id, "
            "transaction_type, quantity, "
            "transaction_date) "
            f"VALUES ({product_id}, "
            f"{warehouse_id}, "
            f"'{transaction_type}', "
            f"{quantity}, "
            f"'{formatted_date}');\n"
        )


# --------------------------------------------------
# Summary
# --------------------------------------------------

print("Seed data generated successfully.")
print(f"File: {output_path}")
print()
print(f"Suppliers: {len(suppliers)}")
print(f"Warehouses: {len(warehouses)}")
print(f"Products: {len(products)}")
print(f"Inventory records: {len(inventory_records)}")
print(f"Orders: {len(orders)}")
print(f"Order items: {len(order_items)}")
print(
    f"Stock transactions: "
    f"{len(stock_transactions)}"
)