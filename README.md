# Restaurant Database Project (SQL Server)

This repository contains T‑SQL scripts to create and seed a complete restaurant operations database on Microsoft SQL Server. It includes schema objects for customers, staff, menu, inventory, recipes, reservations, supply orders, and sales orders.

## Prerequisites
- Microsoft SQL Server (2017 or later; Express is fine)
- One of:
  - Command line `sqlcmd` (installed with SQL Server or Microsoft SQL Tools)
  - SQL Server Management Studio (SSMS)
- Clone this repo locally and open a terminal in the project root.

## Repository Structure
```
├── Database-Setup/
│   ├── buildDB.sql      # Creates RestaurantDB and all tables, indexes, constraints
│   ├── seedDB.sql       # Populates test data (menu, inventory, customers, orders, etc.)
│   └── deleteDB.sql     # Drops the database (for reset/cleanup)
├── Analytics/
│   ├── Analytics.sql         # Functions, procedures, triggers, and views for BI
│   ├── useAnalytics.sql      # Testing script with examples for all analytics components
│   └── Analytics-in-practice.sql  # Ad-hoc query examples for data exploration
├── ERD-and-Mapping/
│   ├── Restaurant-ERD-mapping.pdf  # Entity-Relationship Diagram mapping document
│   └── Resturant-ERD.pdf           # Entity-Relationship Diagram
└── README.md
```

## Quickstart (sqlcmd)
Use Windows authentication (`-E`) or SQL authentication (`-U` / `-P`). Replace `localhost` with your server name or instance (e.g., `.\SQLEXPRESS`). Add `-C` to trust the server certificate if you encounter SSL errors.

1) Create the database and schema
```
sqlcmd -S localhost -d master -E -b -i "Database-Setup\buildDB.sql" -C
```
2) Align reservation status constraint to match seeding data (recommended)
```
sqlcmd -S localhost -d RestaurantDB -E -b -Q "ALTER TABLE RESERVATIONS DROP CONSTRAINT CK_RESERVATIONS_Status; ALTER TABLE RESERVATIONS ADD CONSTRAINT CK_RESERVATIONS_Status CHECK (Status IN ('Pending','Confirmed','Completed','Canceled','Cancelled','No-Show'));" -C
```
3) Seed the database
```
sqlcmd -S localhost -d RestaurantDB -E -b -i "Database-Setup\seedDB.sql" -C
```

SQL authentication examples:
```
sqlcmd -S localhost -d master -U sa -P "<PASSWORD>" -b -i "Database-Setup\buildDB.sql" -C
sqlcmd -S localhost -d RestaurantDB -U sa -P "<PASSWORD>" -b -i "Database-Setup\seedDB.sql" -C
```

Tips:
- Use `-o "seed.log"` to write output to a file.
- For named instances: `-S .\SQLEXPRESS`.

## Quickstart (SSMS GUI)
1) Open SSMS and connect to your SQL Server.
- File → Open → `Database-Setup\buildDB.sql`
- Click `Execute`. This creates `RestaurantDB` and its schema.

2) Align reservation status constraint (recommended).
- New Query (connected to `RestaurantDB`), paste and execute:
```
ALTER TABLE RESERVATIONS DROP CONSTRAINT CK_RESERVATIONS_Status;
ALTER TABLE RESERVATIONS ADD CONSTRAINT CK_RESERVATIONS_Status CHECK (Status IN ('Pending','Confirmed','Completed','Canceled','Cancelled','No-Show'));
```

3) Seed the data.
- File → Open → `Database-Setup\seedDB.sql`
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

## Analytics
The `Analytics\Analytics.sql` script provides comprehensive business intelligence with functions, procedures, triggers, and views for data-driven insights.

### Key Reports
- **Daily Sales Summary**: `EXEC sp_DailySalesSummary '2025-12-01'` - Revenue, top items, peak hours
- **Customer Loyalty**: `EXEC sp_CustomerLoyaltyReport 5` - Tier classification, lifetime value, retention
- **Inventory Alerts**: `EXEC sp_InventoryReorderAlert` - Low stock warnings with criticality levels  
- **Staff Performance**: `EXEC sp_StaffPerformance '2025-01-01', '2025-12-31'` - Sales per employee, efficiency
- **Monthly Trends**: `EXEC sp_MonthlyTrends 2025` - Revenue patterns, seasonal insights
- **Menu Profitability**: `EXEC sp_MenuProfitability` - Cost analysis, profit margins per item

### Automated Features
- **Order Total Updates**: Automatically recalculates totals when order items change
- **Inventory Monitoring**: Logs alerts when stock drops below reorder levels
- **Revenue Tracking**: Functions for date-range revenue and customer lifetime value
- **Operational Views**: Day-of-week revenue patterns, table utilization, supply costs

### Testing Analytics
Use `Analytics\useAnalytics.sql` for comprehensive testing of all analytics components with example queries.

Use `Analytics\Analytics-in-practice.sql` for ad-hoc data exploration queries.

Deploy analytics:
```
sqlcmd -S localhost -d RestaurantDB -E -b -i "Analytics\Analytics.sql" -C
```

## Reset / Rerun
To reset the database and rerun, use the delete script:
```
sqlcmd -S localhost -d master -E -b -i "Database-Setup\deleteDB.sql" -C
```
Or manually:
```
DROP DATABASE IF EXISTS RestaurantDB;
GO
-- Then repeat the Quickstart steps
```

## Troubleshooting
- Constraint error on `RESERVATIONS.Status`: If the seed script fails with a CHECK constraint error, ensure you applied the constraint update shown above so the statuses `'No-Show'` and `'Cancelled'` are allowed.
- Cannot connect with `sqlcmd`: Confirm the instance name (`-S`), authentication method (`-E` vs `-U`/`-P`), and that SQL Server is running.
- File path issues: Run commands from the repository root so `Database-Setup\...` and `Analytics\...` paths resolve correctly, or use absolute paths.
- SSL certificate errors: Use `-C` flag to trust the server certificate (quick but less secure), or configure a trusted certificate:
  1. In SQL Server Configuration Manager, enable Force Encryption and install a valid certificate
  2. Export the SQL Server certificate (certmgr.msc → Local Computer → Personal → Certificates)
  3. Import to Trusted Root (certmgr.msc → Trusted Root Certification Authorities → Import)
  4. Remove `-C` flag from commands

