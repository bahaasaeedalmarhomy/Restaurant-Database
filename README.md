# Restaurant Database Project (SQL Server)

This repository contains T‑SQL scripts to create and seed a complete restaurant operations database on Microsoft SQL Server. It includes schema objects for customers, staff, menu, inventory, recipes, reservations, supply orders, and sales orders.

## Prerequisites
- Microsoft SQL Server (2017 or later; Express is fine)
- One of:
  - Command line `sqlcmd` (installed with SQL Server or Microsoft SQL Tools)
  - SQL Server Management Studio (SSMS)
- Clone this repo locally and open a terminal in the project root.

## Scripts
- `Scripts\create_restaurant_database.sql` — creates database `RestaurantDB` and all tables, indexes, and constraints.
- `Scripts\seed_restaurant_database_tanta.sql` — populates core reference data, menu items, inventory and recipes, sample customers, reservations, supply orders, and realistic historical orders.

## Quickstart (sqlcmd)
Use Windows authentication (`-E`) or SQL authentication (`-U` / `-P`). Replace `localhost` with your server name or instance (e.g., `.\SQLEXPRESS`).

1) Create the database and schema
```
sqlcmd -S localhost -d master -E -b -i "Scripts\create_restaurant_database.sql"
```
2) Align reservation status constraint to match seeding data (recommended)
```
sqlcmd -S localhost -d RestaurantDB -E -b -Q "ALTER TABLE RESERVATIONS DROP CONSTRAINT CK_RESERVATIONS_Status; ALTER TABLE RESERVATIONS ADD CONSTRAINT CK_RESERVATIONS_Status CHECK (Status IN ('Pending','Confirmed','Completed','Canceled','Cancelled','No-Show'));"
```
3) Seed the database
```
sqlcmd -S localhost -d RestaurantDB -E -b -i "Scripts\seed_restaurant_database_tanta.sql"
```

SQL authentication examples:
```
sqlcmd -S localhost -d master -U sa -P "<PASSWORD>" -b -i "Scripts\create_restaurant_database.sql"
sqlcmd -S localhost -d RestaurantDB -U sa -P "<PASSWORD>" -b -i "Scripts\seed_restaurant_database_tanta.sql"
```

Tips:
- Use `-o "seed.log"` to write output to a file.
- For named instances: `-S .\SQLEXPRESS`.

## Quickstart (SSMS GUI)
1) Open SSMS and connect to your SQL Server.
- File → Open → `Scripts\create_restaurant_database.sql`
- Click `Execute`. This creates `RestaurantDB` and its schema.

2) Align reservation status constraint (recommended).
- New Query (connected to `RestaurantDB`), paste and execute:
```
ALTER TABLE RESERVATIONS DROP CONSTRAINT CK_RESERVATIONS_Status;
ALTER TABLE RESERVATIONS ADD CONSTRAINT CK_RESERVATIONS_Status CHECK (Status IN ('Pending','Confirmed','Completed','Canceled','Cancelled','No-Show'));
```

3) Seed the data.
- File → Open → `Scripts\seed_restaurant_database_tanta.sql`
- Ensure the database dropdown shows `RestaurantDB`.
- Click `Execute`.

## Verify
Run a few checks in `RestaurantDB`:
```
SELECT COUNT(*) AS Categories FROM MENUCATEGORIES;
SELECT COUNT(*) AS MenuItems FROM MENUITEMS;
SELECT TOP 5 OrderID, OrderType, OrderDateTime, TotalAmount FROM ORDERS ORDER BY OrderDateTime DESC;
SELECT TOP 5 CustomerID, TableID, ReservationDateTime, Status FROM RESERVATIONS ORDER BY ReservationDateTime DESC;
```

## Reset / Rerun
To reset the database and rerun:
```
DROP DATABASE IF EXISTS RestaurantDB;
GO
-- Then repeat the Quickstart steps
```

## Troubleshooting
- Constraint error on `RESERVATIONS.Status`: If the seed script fails with a CHECK constraint error, ensure you applied the constraint update shown above so the statuses `'No-Show'` and `'Cancelled'` are allowed.
- Cannot connect with `sqlcmd`: Confirm the instance name (`-S`), authentication method (`-E` vs `-U`/`-P`), and that SQL Server is running.
- File path issues: Run commands from the repository root so `Scripts\...` paths resolve correctly, or use absolute paths.

