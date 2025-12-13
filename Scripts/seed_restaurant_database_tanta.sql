/*
    Seed script for RestaurantDB (Tanta, Egypt)
    Purpose: Populate core reference data, menu, inventory, recipes, staff, tables,
             customers, reservations, suppliers, supply orders, and sample customer orders.
    Notes:
      - Uses SELECT-from-lookup patterns to resolve foreign keys by name (e.g., CategoryID).
      - Captures IDENTITY values via SCOPE_IDENTITY() into local variables for follow-up inserts.
      - Computes parent totals (orders, supply orders) from their line items using UPDATE + SUM.
*/
-- Use the target database context
USE RestaurantDB;

DECLARE @Seed INT = 123456;
DECLARE @AnchorDate DATE = '2025-12-01';
DECLARE @AnchorDateTime DATETIME = CAST(@AnchorDate AS DATETIME);

/* Section: Menu Setup (categories and items)
   - Inserts base menu categories
   - Adds representative menu items for each category
   - Item-to-category linkage is resolved by looking up CategoryID by Name
*/
-- Seed menu categories used by menu items
INSERT INTO MENUCATEGORIES (Name) VALUES
('Appetizers'),
('Main Dishes'),
('Sandwiches'),
('Drinks'),
('Desserts');

-- Seed representative menu items using CategoryID looked up by category name
INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT CategoryID, 'Koshary', 'Traditional Egyptian mix of rice, pasta, lentils, chickpeas, tomato sauce and fried onions', 55.00, 1 FROM MENUCATEGORIES WHERE Name='Main Dishes';
INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT CategoryID, 'Molokhia with Chicken', 'Molokhia stew served with grilled chicken and rice', 95.00, 1 FROM MENUCATEGORIES WHERE Name='Main Dishes';
INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT CategoryID, 'Shawarma Sandwich', 'Marinated beef shawarma in pita with tahini', 60.00, 1 FROM MENUCATEGORIES WHERE Name='Sandwiches';
INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT CategoryID, 'Taamiya', 'Egyptian falafel made with fava beans', 35.00, 1 FROM MENUCATEGORIES WHERE Name='Appetizers';
INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT CategoryID, 'Lentil Soup', 'Warm Egyptian lentil soup', 30.00, 1 FROM MENUCATEGORIES WHERE Name='Appetizers';
INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT CategoryID, 'Kunafa', 'Shredded filo pastry dessert with cream', 45.00, 1 FROM MENUCATEGORIES WHERE Name='Desserts';
INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT CategoryID, 'Basbousa', 'Semolina cake soaked in syrup', 35.00, 1 FROM MENUCATEGORIES WHERE Name='Desserts';
INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT CategoryID, 'Karkade', 'Chilled hibiscus drink', 20.00, 1 FROM MENUCATEGORIES WHERE Name='Drinks';
INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT CategoryID, 'Mint Tea', 'Fresh mint tea', 15.00, 1 FROM MENUCATEGORIES WHERE Name='Drinks';

/* Section: Inventory Setup
   - Inserts back-of-house inventory items with starting quantities and units
   - ReorderLevel illustrates threshold for restocking alerts
*/
-- Seed back-of-house inventory items and starting quantities
INSERT INTO INVENTORYITEMS (Name, Quantity, Unit, ReorderLevel) VALUES
('Rice', 50, 'kg', 20),
('Pasta', 40, 'kg', 15),
('Lentils', 30, 'kg', 10),
('Chickpeas', 20, 'kg', 10),
('Tomato Sauce', 60, 'l', 20),
('Onions', 80, 'kg', 30),
('Garlic', 20, 'kg', 10),
('Vegetable Oil', 100, 'l', 40),
('Pita Bread', 200, 'pcs', 80),
('Chicken', 40, 'kg', 15),
('Beef', 30, 'kg', 10),
('Molokhia Leaves', 25, 'kg', 10),
('Sugar', 50, 'kg', 20),
('Semolina', 40, 'kg', 15),
('Butter', 25, 'kg', 10),
('Milk', 80, 'l', 30),
('Hibiscus', 20, 'kg', 10),
('Tea Leaves', 15, 'kg', 5),
('Mint', 10, 'kg', 5);

/* Section: Recipes (Menu → Inventory mapping)
   - Defines per-serving ingredient quantities for each menu item
   - Units reflect the measurement used when deducting inventory for an order
*/
-- Recipe mappings: link each menu item to inventory and per-serving quantities
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Koshary'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Rice'), 0.15, 'kg';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Koshary'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Pasta'), 0.10, 'kg';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Koshary'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Lentils'), 0.10, 'kg';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Koshary'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Chickpeas'), 0.08, 'kg';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Koshary'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Tomato Sauce'), 0.20, 'l';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Koshary'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Onions'), 0.05, 'kg';

INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Molokhia with Chicken'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Molokhia Leaves'), 0.15, 'kg';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Molokhia with Chicken'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Chicken'), 0.25, 'kg';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Molokhia with Chicken'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Rice'), 0.20, 'kg';

INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Shawarma Sandwich'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Beef'), 0.20, 'kg';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Shawarma Sandwich'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Pita Bread'), 1.00, 'pcs';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Shawarma Sandwich'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Onions'), 0.03, 'kg';

INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Taamiya'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Chickpeas'), 0.12, 'kg';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Taamiya'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Vegetable Oil'), 0.05, 'l';

INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Lentil Soup'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Lentils'), 0.12, 'kg';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Lentil Soup'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Onions'), 0.02, 'kg';

INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Kunafa'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Sugar'), 0.05, 'kg';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Kunafa'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Butter'), 0.04, 'kg';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Kunafa'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Milk'), 0.10, 'l';

INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Basbousa'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Semolina'), 0.12, 'kg';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Basbousa'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Sugar'), 0.05, 'kg';

INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Karkade'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Hibiscus'), 0.02, 'kg';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Karkade'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Sugar'), 0.03, 'kg';

INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Mint Tea'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Tea Leaves'), 0.01, 'kg';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT (SELECT MenuItemID FROM MENUITEMS WHERE Name='Mint Tea'), (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Mint'), 0.02, 'kg';

/* Section: Staff Setup (roles and roster)
   - Inserts roles used by staff
   - Adds employees and resolves RoleID by role name to avoid hard-coding IDs
*/
-- Staff roles used by roster
INSERT INTO ROLES (RoleName) VALUES
('Manager'),
('Chef'),
('Waiter'),
('Cashier'),
('Delivery');

-- Staff roster: resolve RoleID by role name to avoid hard-coding IDs
INSERT INTO STAFF (RoleID, FirstName, LastName, Phone, Email, HireDate)
SELECT RoleID, 'Ahmed', 'Hassan', '0100000001', 'ahmed.hassan@example.com', '2024-02-01' FROM ROLES WHERE RoleName='Manager';
INSERT INTO STAFF (RoleID, FirstName, LastName, Phone, Email, HireDate)
SELECT RoleID, 'Salma', 'Younis', '0100000002', 'salma.younis@example.com', '2024-03-10' FROM ROLES WHERE RoleName='Chef';
INSERT INTO STAFF (RoleID, FirstName, LastName, Phone, Email, HireDate)
SELECT RoleID, 'Omar', 'Mahmoud', '0100000003', 'omar.mahmoud@example.com', '2024-04-05' FROM ROLES WHERE RoleName='Waiter';
INSERT INTO STAFF (RoleID, FirstName, LastName, Phone, Email, HireDate)
SELECT RoleID, 'Hassan', 'El-Sayed', '0100000006', 'hassan.elsayed@example.com', '2024-07-01' FROM ROLES WHERE RoleName='Waiter';
INSERT INTO STAFF (RoleID, FirstName, LastName, Phone, Email, HireDate)
SELECT RoleID, 'Noor', 'Adel', '0100000007', 'noor.adel@example.com', '2024-08-01' FROM ROLES WHERE RoleName='Waiter';
INSERT INTO STAFF (RoleID, FirstName, LastName, Phone, Email, HireDate)
SELECT RoleID, 'Lina', 'Mostafa', '0100000004', 'lina.mostafa@example.com', '2024-05-15' FROM ROLES WHERE RoleName='Cashier';
INSERT INTO STAFF (RoleID, FirstName, LastName, Phone, Email, HireDate)
SELECT RoleID, 'Karim', 'Hafez', '0100000005', 'karim.hafez@example.com', '2024-06-20' FROM ROLES WHERE RoleName='Delivery';
INSERT INTO STAFF (RoleID, FirstName, LastName, Phone, Email, HireDate)
SELECT RoleID, 'Mahmoud', 'Nabil', '0100000008', 'mahmoud.nabil@example.com', '2024-07-10' FROM ROLES WHERE RoleName='Delivery';

/* Section: Dining Area Setup (tables)
   - Inserts physical tables with capacities
*/
-- Physical tables and capacities in the dining area
INSERT INTO TABLES (TableNumber, Capacity) VALUES
(1, 2), (2, 2), (3, 4), (4, 4), (5, 4), (6, 4), (7, 6), (8, 6), (9, 6), (10, 8), (11, 8), (12, 10);

/* Section: Customers
   - Adds a small initial customer set used for early examples and tests
*/
-- Initial customers for testing reservations and orders
INSERT INTO CUSTOMERS (FirstName, LastName, Phone, Email)
VALUES ('Mohamed', 'Ali', '0101111111', 'mohamed.ali@example.com');
INSERT INTO CUSTOMERS (FirstName, LastName, Phone, Email)
VALUES ('Sara', 'Ibrahim', '0102222222', 'sara.ibrahim@example.com');
INSERT INTO CUSTOMERS (FirstName, LastName, Phone, Email)
VALUES ('Youssef', 'Kamal', '0103333333', 'youssef.kamal@example.com');
INSERT INTO CUSTOMERS (FirstName, LastName, Phone, Email)
VALUES ('Amira', 'Hamed', '0104444444', 'amira.hamed@example.com');
INSERT INTO CUSTOMERS (FirstName, LastName, Phone, Email)
VALUES ('Heba', 'Saad', '0105555555', 'heba.saad@example.com');
INSERT INTO CUSTOMERS (FirstName, LastName, Phone, Email)
VALUES ('Mahmoud', 'Farag', '0106666666', 'mahmoud.farag@example.com');
INSERT INTO CUSTOMERS (FirstName, LastName, Phone, Email)
VALUES ('Nour', 'El Gendy', '0107777777', 'nour.elgendy@example.com');
INSERT INTO CUSTOMERS (FirstName, LastName, Phone, Email)
VALUES ('Karim', 'Abdelrahman', '0108888888', 'karim.abdelrahman@example.com');
INSERT INTO CUSTOMERS (FirstName, LastName, Phone, Email)
VALUES ('Salma', 'Fathy', '0109999999', 'salma.fathy@example.com');
INSERT INTO CUSTOMERS (FirstName, LastName, Phone, Email)
VALUES ('Ola', 'Nasr', '0110000000', 'ola.nasr@example.com');

/* Section: Sample Reservations (near-term)
   - Creates upcoming reservations linked to existing customers and tables
   - Status illustrates booking lifecycle
*/
-- Sample reservations linking customers to tables at specific times
INSERT INTO RESERVATIONS (CustomerID, TableID, ReservationDateTime, NumGuests, Status)
VALUES (
    (SELECT CustomerID FROM CUSTOMERS WHERE FirstName='Mohamed' AND LastName='Ali'),
    (SELECT TableID FROM TABLES WHERE TableNumber=5),
    DATEADD(day, 3, @AnchorDateTime),
    4,
    'Confirmed'
);

INSERT INTO RESERVATIONS (CustomerID, TableID, ReservationDateTime, NumGuests, Status)
VALUES (
    (SELECT CustomerID FROM CUSTOMERS WHERE FirstName='Sara' AND LastName='Ibrahim'),
    (SELECT TableID FROM TABLES WHERE TableNumber=2),
    DATEADD(day, 1, @AnchorDateTime),
    2,
    'Pending'
);

INSERT INTO RESERVATIONS (CustomerID, TableID, ReservationDateTime, NumGuests, Status)
VALUES (
    (SELECT CustomerID FROM CUSTOMERS WHERE FirstName='Karim' AND LastName='Abdelrahman'),
    (SELECT TableID FROM TABLES WHERE TableNumber=10),
    DATEADD(day, 2, @AnchorDateTime),
    3,
    'Confirmed'
);

/* Section: Suppliers and Initial Supply Orders
   - Inserts supplier master records
   - Creates two immediate supply orders (one per supplier), adds line items,
     computes totals, and updates inventory with received quantities
*/
-- Supplier master data for the supply chain
INSERT INTO SUPPLIERS (Name, ContactEmail, Phone) VALUES
('Tanta Food Wholesale', 'orders@tantafood.eg', '0401234567'),
('Delta Farms', 'contact@deltafarms.eg', '0407654321');

-- Create a supply order and capture its generated ID for line item inserts
DECLARE @SO1 INT;
INSERT INTO SUPPLYORDERS (SupplierID, OrderDate, TotalCost)
VALUES ((SELECT SupplierID FROM SUPPLIERS WHERE Name='Tanta Food Wholesale'), @AnchorDateTime, 0);
SET @SO1 = SCOPE_IDENTITY();

-- Supply order line items referencing inventory and received quantities with costs
INSERT INTO SUPPLYORDERITEMS (SupplyOrderID, InventoryID, Quantity, CostPerUnit) VALUES
(@SO1, (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Rice'), 100, 18.00),
(@SO1, (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Pasta'), 80, 20.00),
(@SO1, (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Tomato Sauce'), 120, 12.00),
(@SO1, (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Onions'), 150, 9.00);

-- Compute and update supply order total from its line items
UPDATE SUPPLYORDERS SET TotalCost = (
    SELECT SUM(Quantity * CostPerUnit) FROM SUPPLYORDERITEMS WHERE SupplyOrderID=@SO1
) WHERE SupplyOrderID=@SO1;

-- Increase inventory levels by quantities received in the supply order
UPDATE INVENTORYITEMS SET Quantity = Quantity + (
    SELECT SUM(Quantity) FROM SUPPLYORDERITEMS WHERE SupplyOrderID=@SO1 AND InventoryID=INVENTORYITEMS.InventoryID
);

DECLARE @SO2 INT;
INSERT INTO SUPPLYORDERS (SupplierID, OrderDate, TotalCost)
VALUES ((SELECT SupplierID FROM SUPPLIERS WHERE Name='Delta Farms'), @AnchorDateTime, 0);
SET @SO2 = SCOPE_IDENTITY();

INSERT INTO SUPPLYORDERITEMS (SupplyOrderID, InventoryID, Quantity, CostPerUnit) VALUES
(@SO2, (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Chicken'), 50, 90.00),
(@SO2, (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Beef'), 40, 120.00),
(@SO2, (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Molokhia Leaves'), 60, 25.00),
(@SO2, (SELECT InventoryID FROM INVENTORYITEMS WHERE Name='Mint'), 30, 8.00);

UPDATE SUPPLYORDERS SET TotalCost = (
    SELECT SUM(Quantity * CostPerUnit) FROM SUPPLYORDERITEMS WHERE SupplyOrderID=@SO2
) WHERE SupplyOrderID=@SO2;

UPDATE INVENTORYITEMS SET Quantity = Quantity + (
    SELECT SUM(Quantity) FROM SUPPLYORDERITEMS WHERE SupplyOrderID=@SO2 AND InventoryID=INVENTORYITEMS.InventoryID
);




/* Section: Dine-In Orders (current time, illustrative)
   - Bulk-creates 5 dine-in orders for each of five customers
   - Captures inserted orders via OUTPUT into @DineInOrders for follow-up line items
*/
-- Create 5 dine-in orders for 5 customers at current time
DECLARE @DineInOrders TABLE (OrderID INT, CustomerID INT);

-- Capture OrderID and CustomerID for follow-up line item inserts
INSERT INTO ORDERS (CustomerID, StaffID, OrderType, OrderDateTime, TotalAmount, PaymentStatus)
OUTPUT INSERTED.OrderID, INSERTED.CustomerID INTO @DineInOrders
SELECT c.CustomerID,
       (SELECT StaffID FROM STAFF WHERE FirstName='Omar' AND LastName='Mahmoud'),
       'Dine-In',
       @AnchorDateTime,
       0,
       'Paid'
FROM CUSTOMERS c
WHERE (c.FirstName='Mohamed' AND c.LastName='Ali')
   OR (c.FirstName='Amira' AND c.LastName='Hamed')
   OR (c.FirstName='Heba' AND c.LastName='Saad')
   OR (c.FirstName='Mahmoud' AND c.LastName='Farag')
   OR (c.FirstName='Nour' AND c.LastName='El Gendy')
CROSS JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) x;


-- Line items per customer for mass dine-in orders
-- Each customer gets a consistent pattern of items to demonstrate variety
INSERT INTO ORDERITEMS (OrderID, MenuItemID, Quantity, PriceAtPurchase)
SELECT o.OrderID, (SELECT MenuItemID FROM MENUITEMS WHERE Name='Koshary'), 2, (SELECT Price FROM MENUITEMS WHERE Name='Koshary')
FROM @DineInOrders o JOIN CUSTOMERS c ON o.CustomerID=c.CustomerID
WHERE c.FirstName='Mohamed' AND c.LastName='Ali';
INSERT INTO ORDERITEMS (OrderID, MenuItemID, Quantity, PriceAtPurchase)
SELECT o.OrderID, (SELECT MenuItemID FROM MENUITEMS WHERE Name='Mint Tea'), 2, (SELECT Price FROM MENUITEMS WHERE Name='Mint Tea')
FROM @DineInOrders o JOIN CUSTOMERS c ON o.CustomerID=c.CustomerID
WHERE c.FirstName='Mohamed' AND c.LastName='Ali';

INSERT INTO ORDERITEMS (OrderID, MenuItemID, Quantity, PriceAtPurchase)
SELECT o.OrderID, (SELECT MenuItemID FROM MENUITEMS WHERE Name='Molokhia with Chicken'), 1, (SELECT Price FROM MENUITEMS WHERE Name='Molokhia with Chicken')
FROM @DineInOrders o JOIN CUSTOMERS c ON o.CustomerID=c.CustomerID
WHERE c.FirstName='Amira' AND c.LastName='Hamed';
INSERT INTO ORDERITEMS (OrderID, MenuItemID, Quantity, PriceAtPurchase)
SELECT o.OrderID, (SELECT MenuItemID FROM MENUITEMS WHERE Name='Karkade'), 2, (SELECT Price FROM MENUITEMS WHERE Name='Karkade')
FROM @DineInOrders o JOIN CUSTOMERS c ON o.CustomerID=c.CustomerID
WHERE c.FirstName='Amira' AND c.LastName='Hamed';

INSERT INTO ORDERITEMS (OrderID, MenuItemID, Quantity, PriceAtPurchase)
SELECT o.OrderID, (SELECT MenuItemID FROM MENUITEMS WHERE Name='Shawarma Sandwich'), 2, (SELECT Price FROM MENUITEMS WHERE Name='Shawarma Sandwich')
FROM @DineInOrders o JOIN CUSTOMERS c ON o.CustomerID=c.CustomerID
WHERE c.FirstName='Heba' AND c.LastName='Saad';
INSERT INTO ORDERITEMS (OrderID, MenuItemID, Quantity, PriceAtPurchase)
SELECT o.OrderID, (SELECT MenuItemID FROM MENUITEMS WHERE Name='Lentil Soup'), 1, (SELECT Price FROM MENUITEMS WHERE Name='Lentil Soup')
FROM @DineInOrders o JOIN CUSTOMERS c ON o.CustomerID=c.CustomerID
WHERE c.FirstName='Heba' AND c.LastName='Saad';

INSERT INTO ORDERITEMS (OrderID, MenuItemID, Quantity, PriceAtPurchase)
SELECT o.OrderID, (SELECT MenuItemID FROM MENUITEMS WHERE Name='Taamiya'), 3, (SELECT Price FROM MENUITEMS WHERE Name='Taamiya')
FROM @DineInOrders o JOIN CUSTOMERS c ON o.CustomerID=c.CustomerID
WHERE c.FirstName='Mahmoud' AND c.LastName='Farag';
INSERT INTO ORDERITEMS (OrderID, MenuItemID, Quantity, PriceAtPurchase)
SELECT o.OrderID, (SELECT MenuItemID FROM MENUITEMS WHERE Name='Mint Tea'), 2, (SELECT Price FROM MENUITEMS WHERE Name='Mint Tea')
FROM @DineInOrders o JOIN CUSTOMERS c ON o.CustomerID=c.CustomerID
WHERE c.FirstName='Mahmoud' AND c.LastName='Farag';

INSERT INTO ORDERITEMS (OrderID, MenuItemID, Quantity, PriceAtPurchase)
SELECT o.OrderID, (SELECT MenuItemID FROM MENUITEMS WHERE Name='Basbousa'), 2, (SELECT Price FROM MENUITEMS WHERE Name='Basbousa')
FROM @DineInOrders o JOIN CUSTOMERS c ON o.CustomerID=c.CustomerID
WHERE c.FirstName='Nour' AND c.LastName='El Gendy';
INSERT INTO ORDERITEMS (OrderID, MenuItemID, Quantity, PriceAtPurchase)
SELECT o.OrderID, (SELECT MenuItemID FROM MENUITEMS WHERE Name='Karkade'), 2, (SELECT Price FROM MENUITEMS WHERE Name='Karkade')
FROM @DineInOrders o JOIN CUSTOMERS c ON o.CustomerID=c.CustomerID
WHERE c.FirstName='Nour' AND c.LastName='El Gendy';

UPDATE o
SET TotalAmount = calc.SumTotal
FROM ORDERS o
JOIN (
    SELECT OrderID, SUM(Quantity * PriceAtPurchase) AS SumTotal
    FROM ORDERITEMS
    WHERE OrderID IN (SELECT OrderID FROM @DineInOrders)
    GROUP BY OrderID
) calc ON calc.OrderID = o.OrderID;

/* Section: Takeout and Delivery Orders (illustrative current activity)
   - Creates one takeout order with line items and computed total
   - Creates two delivery orders with line items and computed totals
*/
-- Create a takeout order for Sara Ibrahim, capture OrderID
DECLARE @Order2 INT;
INSERT INTO ORDERS (CustomerID, StaffID, OrderType, OrderDateTime, TotalAmount, PaymentStatus)
VALUES (
    (SELECT CustomerID FROM CUSTOMERS WHERE FirstName='Sara' AND LastName='Ibrahim'),
    (SELECT StaffID FROM STAFF WHERE FirstName='Lina' AND LastName='Mostafa'),
    'Takeout',
    DATEADD(hour, -2, @AnchorDateTime),
    0,
    'Paid'
);
SET @Order2 = SCOPE_IDENTITY();

-- Line items for the takeout order
INSERT INTO ORDERITEMS (OrderID, MenuItemID, Quantity, PriceAtPurchase)
VALUES
(@Order2, (SELECT MenuItemID FROM MENUITEMS WHERE Name='Shawarma Sandwich'), 3, (SELECT Price FROM MENUITEMS WHERE Name='Shawarma Sandwich')),
(@Order2, (SELECT MenuItemID FROM MENUITEMS WHERE Name='Karkade'), 3, (SELECT Price FROM MENUITEMS WHERE Name='Karkade'));

-- Compute and update total for the takeout order
UPDATE ORDERS SET TotalAmount = (
    SELECT SUM(Quantity * PriceAtPurchase) FROM ORDERITEMS WHERE OrderID=@Order2
) WHERE OrderID=@Order2;

-- Two delivery orders
DECLARE @OrderDel1 INT;
INSERT INTO ORDERS (CustomerID, StaffID, OrderType, OrderDateTime, TotalAmount, PaymentStatus)
VALUES (
    (SELECT CustomerID FROM CUSTOMERS WHERE FirstName='Salma' AND LastName='Fathy'),
    (SELECT StaffID FROM STAFF WHERE FirstName='Karim' AND LastName='Hafez'),
    'Delivery',
    @AnchorDateTime,
    0,
    'Paid'
);
SET @OrderDel1 = SCOPE_IDENTITY();

INSERT INTO ORDERITEMS (OrderID, MenuItemID, Quantity, PriceAtPurchase)
VALUES
(@OrderDel1, (SELECT MenuItemID FROM MENUITEMS WHERE Name='Shawarma Sandwich'), 2, (SELECT Price FROM MENUITEMS WHERE Name='Shawarma Sandwich')),
(@OrderDel1, (SELECT MenuItemID FROM MENUITEMS WHERE Name='Karkade'), 2, (SELECT Price FROM MENUITEMS WHERE Name='Karkade'));

UPDATE ORDERS SET TotalAmount = (
    SELECT SUM(Quantity * PriceAtPurchase) FROM ORDERITEMS WHERE OrderID=@OrderDel1
) WHERE OrderID=@OrderDel1;

DECLARE @OrderDel2 INT;
INSERT INTO ORDERS (CustomerID, StaffID, OrderType, OrderDateTime, TotalAmount, PaymentStatus)
VALUES (
    (SELECT CustomerID FROM CUSTOMERS WHERE FirstName='Ola' AND LastName='Nasr'),
    (SELECT StaffID FROM STAFF WHERE FirstName='Mahmoud' AND LastName='Nabil'),
    'Delivery',
    @AnchorDateTime,
    0,
    'Paid'
);
SET @OrderDel2 = SCOPE_IDENTITY();

INSERT INTO ORDERITEMS (OrderID, MenuItemID, Quantity, PriceAtPurchase)
VALUES
(@OrderDel2, (SELECT MenuItemID FROM MENUITEMS WHERE Name='Koshary'), 1, (SELECT Price FROM MENUITEMS WHERE Name='Koshary')),
(@OrderDel2, (SELECT MenuItemID FROM MENUITEMS WHERE Name='Mint Tea'), 2, (SELECT Price FROM MENUITEMS WHERE Name='Mint Tea'));

UPDATE ORDERS SET TotalAmount = (
    SELECT SUM(Quantity * PriceAtPurchase) FROM ORDERITEMS WHERE OrderID=@OrderDel2
) WHERE OrderID=@OrderDel2;

/* Section: Historical Orders (last ~365 days)
   - Generates a Dates CTE spanning the previous year
   - Inserts 6–14 orders per day with randomized customers, staff, and order types
   - Adds 1–3 items per order and computes totals
*/
;WITH Dates AS (
    SELECT CAST(DATEADD(day, -364, @AnchorDate) AS date) AS d
    UNION ALL
    SELECT DATEADD(day, 1, d) FROM Dates WHERE DATEADD(day, 1, d) <= @AnchorDate
)
-- Table variable collects IDs of newly inserted orders over the last year
DECLARE @NewOrders TABLE (OrderID INT);

-- Create randomized orders and capture inserted OrderIDs
INSERT INTO ORDERS (CustomerID, StaffID, OrderType, OrderDateTime, TotalAmount, PaymentStatus)
OUTPUT INSERTED.OrderID INTO @NewOrders
SELECT
    cust.PickedCustomerID,
    CASE WHEN ABS(CHECKSUM(@Seed, DATEDIFF(day,'20000101', d), N.n, 101)) % 3 = 0 THEN (SELECT StaffID FROM STAFF WHERE FirstName='Omar' AND LastName='Mahmoud')
         WHEN ABS(CHECKSUM(@Seed, DATEDIFF(day,'20000101', d), N.n, 101)) % 3 = 1 THEN (SELECT StaffID FROM STAFF WHERE FirstName='Lina' AND LastName='Mostafa')
         ELSE CASE WHEN ABS(CHECKSUM(@Seed, DATEDIFF(day,'20000101', d), N.n, 102)) % 2 = 0 THEN (SELECT StaffID FROM STAFF WHERE FirstName='Karim' AND LastName='Hafez')
                   ELSE (SELECT StaffID FROM STAFF WHERE FirstName='Mahmoud' AND LastName='Nabil') END END,
    CASE WHEN ABS(CHECKSUM(@Seed, DATEDIFF(day,'20000101', d), N.n, 103)) % 3 = 0 THEN 'Dine-In'
         WHEN ABS(CHECKSUM(@Seed, DATEDIFF(day,'20000101', d), N.n, 103)) % 3 = 1 THEN 'Takeout'
         ELSE 'Delivery' END,
    DATEADD(hour, (ABS(CHECKSUM(@Seed, DATEDIFF(day,'20000101', d), N.n, 104)) % 12) + 11, CAST(d AS datetime)),
    0,
    'Paid'
FROM Dates
CROSS APPLY (
    SELECT CAST(ABS(CHECKSUM(@Seed, DATEDIFF(day,'20000101', d), 100)) % 9 + 6 AS INT) AS OrdersPerDay
) c
CROSS JOIN (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15)) N(n)
WHERE N.n <= c.OrdersPerDay
OPTION (MAXRECURSION 0);

-- Add randomized items for each generated order using available menu items
INSERT INTO ORDERITEMS (OrderID, MenuItemID, Quantity, PriceAtPurchase)
SELECT
    o.OrderID,
    mi.MenuItemID,
    CAST(ABS(CHECKSUM(@Seed, DATEDIFF(day,'20000101', CAST(o2.OrderDateTime AS date)), DATEPART(hour, o2.OrderDateTime), mi.MenuItemID)) % 3 + 1 AS INT),
    mi.Price
FROM @NewOrders o
JOIN ORDERS o2 ON o2.OrderID = o.OrderID
CROSS APPLY (SELECT CAST(ABS(CHECKSUM(@Seed, DATEDIFF(day,'20000101', CAST(o2.OrderDateTime AS date)), DATEPART(hour, o2.OrderDateTime))) % 3 + 1 AS INT) AS ItemCount) ic
CROSS JOIN (VALUES (1),(2),(3)) I(i)
CROSS APPLY (
    SELECT TOP 1 MenuItemID, Price
    FROM MENUITEMS
    WHERE Available=1
    ORDER BY ABS(CHECKSUM(@Seed, DATEDIFF(day,'20000101', CAST(o2.OrderDateTime AS date)), DATEPART(hour, o2.OrderDateTime), I.i, MenuItemID))
) mi
WHERE I.i <= ic.ItemCount;

UPDATE o
SET TotalAmount = s.SumTotal
FROM ORDERS o
JOIN (
    SELECT OrderID, SUM(Quantity * PriceAtPurchase) AS SumTotal
    FROM ORDERITEMS
    WHERE OrderID IN (SELECT OrderID FROM @NewOrders)
    GROUP BY OrderID
) s ON s.OrderID = o.OrderID;

/* Section: Historical Supply Orders (last 12 months)
   - Generates first-of-month dates for the last year
   - Inserts one supply order per supplier per month
   - Adds 3–6 line items, computes supply order totals, and updates inventory
*/
;WITH Months AS (
SELECT DATEFROMPARTS(YEAR(DATEADD(month, -m, @AnchorDate)), MONTH(DATEADD(month, -m, @AnchorDate)), 1) AS m
    FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11)) t(m)
)
DECLARE @SupplyOrders TABLE (SupplyOrderID INT);

INSERT INTO SUPPLYORDERS (SupplierID, OrderDate, TotalCost)
OUTPUT INSERTED.SupplyOrderID INTO @SupplyOrders
SELECT s.SupplierID,
       -- Random day within each month for supply order receipt
       DATEADD(day, ABS(CHECKSUM(@Seed, YEAR(M.m), MONTH(M.m), s.SupplierID)) % 27, CAST(M.m AS datetime)),
       0
FROM SUPPLIERS s
JOIN Months M ON 1=1
WHERE s.Name IN ('Tanta Food Wholesale','Delta Farms');

-- Randomize which inventory items and quantities are received in each supply order
INSERT INTO SUPPLYORDERITEMS (SupplyOrderID, InventoryID, Quantity, CostPerUnit)
SELECT
    so.SupplyOrderID,
    inv.InventoryID,
    CAST(ABS(CHECKSUM(@Seed, s.SupplierID, DATEDIFF(month,'20000101', s.OrderDate))) % 150 + 30 AS INT),
    CAST(ABS(CHECKSUM(@Seed, s.SupplierID, DATEDIFF(month,'20000101', s.OrderDate), inv.InventoryID)) % 50 + 5 AS DECIMAL(10,2))
FROM @SupplyOrders so
CROSS APPLY (SELECT CAST(ABS(CHECKSUM(@Seed, DATEDIFF(month,'20000101', s.OrderDate), s.SupplierID)) % 4 + 3 AS INT) AS ItemCount) ic
CROSS JOIN (VALUES (1),(2),(3),(4),(5),(6)) I(i)
CROSS APPLY (
    SELECT TOP 1 InventoryID
    FROM INVENTORYITEMS
    ORDER BY ABS(CHECKSUM(@Seed, DATEDIFF(month,'20000101', s.OrderDate), s.SupplierID, I.i, InventoryID))
) inv
WHERE I.i <= ic.ItemCount;

UPDATE s
SET TotalCost = d.SumTotal
FROM SUPPLYORDERS s
JOIN (
    SELECT SupplyOrderID, SUM(Quantity * CostPerUnit) AS SumTotal
    FROM SUPPLYORDERITEMS
    WHERE SupplyOrderID IN (SELECT SupplyOrderID FROM @SupplyOrders)
    GROUP BY SupplyOrderID
) d ON d.SupplyOrderID = s.SupplyOrderID;

-- Update inventory quantities by the sum of received amounts across generated supply orders
UPDATE i
SET Quantity = i.Quantity + d.SumQty
FROM INVENTORYITEMS i
JOIN (
    SELECT InventoryID, SUM(Quantity) AS SumQty
    FROM SUPPLYORDERITEMS
    WHERE SupplyOrderID IN (SELECT SupplyOrderID FROM @SupplyOrders)
    GROUP BY InventoryID
) d ON d.InventoryID = i.InventoryID;

/* Section: Historical Reservations (last ~365 days)
   - Generates daily reservation activity with varied status outcomes
   - Each day can have up to three reservations, with realistic timings and guest counts
*/
;WITH Dates AS (
    SELECT CAST(DATEADD(day, -364, @AnchorDate) AS date) AS d
    UNION ALL
    SELECT DATEADD(day, 1, d) FROM Dates WHERE DATEADD(day, 1, d) <= @AnchorDate
)
INSERT INTO RESERVATIONS (CustomerID, TableID, ReservationDateTime, NumGuests, Status)
SELECT
    (SELECT TOP 1 CustomerID FROM CUSTOMERS ORDER BY ABS(CHECKSUM(@Seed, DATEDIFF(day,'20000101', d), CustomerID))),
    (SELECT TOP 1 TableID FROM TABLES ORDER BY ABS(CHECKSUM(@Seed, DATEDIFF(day,'20000101', d), TableID))),
    DATEADD(hour, (ABS(CHECKSUM(@Seed, DATEDIFF(day,'20000101', d), 201)) % 10) + 12, CAST(d AS datetime)),
    CAST(ABS(CHECKSUM(@Seed, DATEDIFF(day,'20000101', d), 202)) % 6 + 1 AS INT),
    -- Status distribution: past dates yield No-Show/Cancelled/Confirmed,
    -- future dates are Pending/Confirmed
    CASE WHEN d < @AnchorDate
         THEN CASE WHEN ABS(CHECKSUM(@Seed, DATEDIFF(day,'20000101', d), 203)) % 10 = 0 THEN 'No-Show'
                   WHEN ABS(CHECKSUM(@Seed, DATEDIFF(day,'20000101', d), 204)) % 10 = 1 THEN 'Cancelled'
                   ELSE 'Confirmed' END
         ELSE CASE WHEN ABS(CHECKSUM(@Seed, DATEDIFF(day,'20000101', d), 205)) % 3 = 0 THEN 'Pending' ELSE 'Confirmed' END
    END
FROM Dates
-- Up to three reservations per day using enumerator and deterministic per-day count
CROSS APPLY (SELECT CAST(ABS(CHECKSUM(@Seed, DATEDIFF(day,'20000101', d), 206)) % 4 AS INT) AS ResCount) rc
CROSS JOIN (VALUES (1),(2),(3)) N(n)
WHERE N.n <= rc.ResCount
OPTION (MAXRECURSION 0);