/*
    Seed script for RestaurantDB (Tanta, Egypt)
    Purpose: Populate comprehensive test data for all tables to support deep analytical queries.
    
    Data Generated:
    - 5 Menu Categories with 15 Menu Items
    - 19 Inventory Items with Recipe mappings
    - 6 Staff Roles with 10 Staff Members
    - 12 Restaurant Tables
    - 30 Customers (mix of loyalty tiers)
    - 3 Suppliers with monthly supply orders over 12 months
    - ~3500+ Orders spanning 365 days with varied patterns
    - ~1000+ Reservations with realistic status distribution
*/

USE RestaurantDB;
GO

-- ============================================================================
-- SECTION 1: REFERENCE DATA (Categories, Roles, Inventory, Menu)
-- ============================================================================

-- Menu Categories
INSERT INTO MENUCATEGORIES (Name) VALUES
('Appetizers'),
('Main Dishes'),
('Sandwiches'),
('Drinks'),
('Desserts');

-- Inventory Items (raw materials)
INSERT INTO INVENTORYITEMS (Name, Quantity, Unit, ReorderLevel) VALUES
('Rice', 150, 'kg', 30),
('Pasta', 120, 'kg', 25),
('Lentils', 80, 'kg', 20),
('Chickpeas', 60, 'kg', 15),
('Tomato Sauce', 100, 'l', 30),
('Onions', 200, 'kg', 50),
('Garlic', 40, 'kg', 15),
('Vegetable Oil', 150, 'l', 50),
('Pita Bread', 500, 'pcs', 150),
('Chicken', 100, 'kg', 30),
('Beef', 80, 'kg', 25),
('Molokhia Leaves', 50, 'kg', 15),
('Sugar', 100, 'kg', 30),
('Semolina', 80, 'kg', 20),
('Butter', 50, 'kg', 15),
('Milk', 150, 'l', 50),
('Hibiscus', 40, 'kg', 15),
('Tea Leaves', 30, 'kg', 10),
('Mint', 25, 'kg', 10);

-- Menu Items with proper category lookups
INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT c.CategoryID, 'Koshary', 'Traditional Egyptian mix of rice, pasta, lentils, chickpeas, tomato sauce and fried onions', 55.00, 1 
FROM MENUCATEGORIES c WHERE c.Name = 'Main Dishes';

INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT c.CategoryID, 'Molokhia with Chicken', 'Molokhia stew served with grilled chicken and rice', 95.00, 1 
FROM MENUCATEGORIES c WHERE c.Name = 'Main Dishes';

INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT c.CategoryID, 'Grilled Kofta', 'Seasoned ground beef kofta with rice and salad', 85.00, 1 
FROM MENUCATEGORIES c WHERE c.Name = 'Main Dishes';

INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT c.CategoryID, 'Shawarma Sandwich', 'Marinated beef shawarma in pita with tahini', 60.00, 1 
FROM MENUCATEGORIES c WHERE c.Name = 'Sandwiches';

INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT c.CategoryID, 'Falafel Wrap', 'Crispy falafel with vegetables in pita bread', 45.00, 1 
FROM MENUCATEGORIES c WHERE c.Name = 'Sandwiches';

INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT c.CategoryID, 'Taamiya', 'Egyptian falafel made with fava beans (6 pieces)', 35.00, 1 
FROM MENUCATEGORIES c WHERE c.Name = 'Appetizers';

INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT c.CategoryID, 'Lentil Soup', 'Warm Egyptian lentil soup with lemon', 30.00, 1 
FROM MENUCATEGORIES c WHERE c.Name = 'Appetizers';

INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT c.CategoryID, 'Hummus', 'Creamy chickpea dip with olive oil', 25.00, 1 
FROM MENUCATEGORIES c WHERE c.Name = 'Appetizers';

INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT c.CategoryID, 'Kunafa', 'Shredded filo pastry dessert with cream and syrup', 45.00, 1 
FROM MENUCATEGORIES c WHERE c.Name = 'Desserts';

INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT c.CategoryID, 'Basbousa', 'Semolina cake soaked in sweet syrup', 35.00, 1 
FROM MENUCATEGORIES c WHERE c.Name = 'Desserts';

INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT c.CategoryID, 'Um Ali', 'Egyptian bread pudding with nuts and cream', 40.00, 1 
FROM MENUCATEGORIES c WHERE c.Name = 'Desserts';

INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT c.CategoryID, 'Karkade', 'Chilled hibiscus drink', 20.00, 1 
FROM MENUCATEGORIES c WHERE c.Name = 'Drinks';

INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT c.CategoryID, 'Mint Tea', 'Fresh mint tea', 15.00, 1 
FROM MENUCATEGORIES c WHERE c.Name = 'Drinks';

INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT c.CategoryID, 'Fresh Lemonade', 'Freshly squeezed lemonade with mint', 18.00, 1 
FROM MENUCATEGORIES c WHERE c.Name = 'Drinks';

INSERT INTO MENUITEMS (CategoryID, Name, Description, Price, Available)
SELECT c.CategoryID, 'Sahlab', 'Warm creamy milk drink with coconut', 22.00, 1 
FROM MENUCATEGORIES c WHERE c.Name = 'Drinks';

-- ============================================================================
-- SECTION 2: RECIPE INGREDIENTS (Menu Item -> Inventory mapping)
-- ============================================================================

-- Koshary Recipe
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.15, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Koshary' AND i.Name = 'Rice';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.10, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Koshary' AND i.Name = 'Pasta';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.10, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Koshary' AND i.Name = 'Lentils';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.08, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Koshary' AND i.Name = 'Chickpeas';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.15, 'l' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Koshary' AND i.Name = 'Tomato Sauce';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.05, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Koshary' AND i.Name = 'Onions';

-- Molokhia with Chicken Recipe
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.15, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Molokhia with Chicken' AND i.Name = 'Molokhia Leaves';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.25, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Molokhia with Chicken' AND i.Name = 'Chicken';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.20, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Molokhia with Chicken' AND i.Name = 'Rice';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.02, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Molokhia with Chicken' AND i.Name = 'Garlic';

-- Grilled Kofta Recipe
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.25, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Grilled Kofta' AND i.Name = 'Beef';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.15, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Grilled Kofta' AND i.Name = 'Rice';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.05, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Grilled Kofta' AND i.Name = 'Onions';

-- Shawarma Sandwich Recipe
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.20, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Shawarma Sandwich' AND i.Name = 'Beef';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 1.00, 'pcs' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Shawarma Sandwich' AND i.Name = 'Pita Bread';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.03, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Shawarma Sandwich' AND i.Name = 'Onions';

-- Falafel Wrap Recipe
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.10, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Falafel Wrap' AND i.Name = 'Chickpeas';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 1.00, 'pcs' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Falafel Wrap' AND i.Name = 'Pita Bread';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.05, 'l' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Falafel Wrap' AND i.Name = 'Vegetable Oil';

-- Taamiya Recipe
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.12, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Taamiya' AND i.Name = 'Chickpeas';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.08, 'l' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Taamiya' AND i.Name = 'Vegetable Oil';

-- Lentil Soup Recipe
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.12, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Lentil Soup' AND i.Name = 'Lentils';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.03, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Lentil Soup' AND i.Name = 'Onions';

-- Hummus Recipe
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.15, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Hummus' AND i.Name = 'Chickpeas';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.02, 'l' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Hummus' AND i.Name = 'Vegetable Oil';

-- Kunafa Recipe
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.05, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Kunafa' AND i.Name = 'Sugar';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.04, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Kunafa' AND i.Name = 'Butter';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.10, 'l' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Kunafa' AND i.Name = 'Milk';

-- Basbousa Recipe
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.12, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Basbousa' AND i.Name = 'Semolina';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.06, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Basbousa' AND i.Name = 'Sugar';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.03, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Basbousa' AND i.Name = 'Butter';

-- Um Ali Recipe
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.15, 'l' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Um Ali' AND i.Name = 'Milk';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.04, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Um Ali' AND i.Name = 'Sugar';

-- Karkade Recipe
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.02, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Karkade' AND i.Name = 'Hibiscus';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.03, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Karkade' AND i.Name = 'Sugar';

-- Mint Tea Recipe
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.01, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Mint Tea' AND i.Name = 'Tea Leaves';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.02, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Mint Tea' AND i.Name = 'Mint';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.01, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Mint Tea' AND i.Name = 'Sugar';

-- Fresh Lemonade Recipe
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.03, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Fresh Lemonade' AND i.Name = 'Sugar';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.01, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Fresh Lemonade' AND i.Name = 'Mint';

-- Sahlab Recipe
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.20, 'l' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Sahlab' AND i.Name = 'Milk';
INSERT INTO RECIPE_INGREDIENTS (MenuItemID, InventoryID, QuantityRequired, Unit)
SELECT m.MenuItemID, i.InventoryID, 0.02, 'kg' FROM MENUITEMS m, INVENTORYITEMS i WHERE m.Name = 'Sahlab' AND i.Name = 'Sugar';

-- ============================================================================
-- SECTION 3: STAFF SETUP
-- ============================================================================

-- Staff Roles
INSERT INTO ROLES (RoleName) VALUES
('Manager'),
('Head Chef'),
('Chef'),
('Waiter'),
('Cashier'),
('Delivery Driver');

-- Staff Members (10 total for good distribution)
INSERT INTO STAFF (RoleID, FirstName, LastName, Phone, Email, HireDate)
SELECT RoleID, 'Ahmed', 'Hassan', '01001234501', 'ahmed.hassan@restaurant.eg', '2023-01-15' FROM ROLES WHERE RoleName = 'Manager';

INSERT INTO STAFF (RoleID, FirstName, LastName, Phone, Email, HireDate)
SELECT RoleID, 'Salma', 'Younis', '01001234502', 'salma.younis@restaurant.eg', '2023-02-01' FROM ROLES WHERE RoleName = 'Head Chef';

INSERT INTO STAFF (RoleID, FirstName, LastName, Phone, Email, HireDate)
SELECT RoleID, 'Khaled', 'Mostafa', '01001234503', 'khaled.mostafa@restaurant.eg', '2023-03-10' FROM ROLES WHERE RoleName = 'Chef';

INSERT INTO STAFF (RoleID, FirstName, LastName, Phone, Email, HireDate)
SELECT RoleID, 'Omar', 'Mahmoud', '01001234504', 'omar.mahmoud@restaurant.eg', '2023-04-01' FROM ROLES WHERE RoleName = 'Waiter';

INSERT INTO STAFF (RoleID, FirstName, LastName, Phone, Email, HireDate)
SELECT RoleID, 'Hassan', 'El-Sayed', '01001234505', 'hassan.elsayed@restaurant.eg', '2023-05-15' FROM ROLES WHERE RoleName = 'Waiter';

INSERT INTO STAFF (RoleID, FirstName, LastName, Phone, Email, HireDate)
SELECT RoleID, 'Noor', 'Adel', '01001234506', 'noor.adel@restaurant.eg', '2023-06-01' FROM ROLES WHERE RoleName = 'Waiter';

INSERT INTO STAFF (RoleID, FirstName, LastName, Phone, Email, HireDate)
SELECT RoleID, 'Lina', 'Mostafa', '01001234507', 'lina.mostafa@restaurant.eg', '2023-07-01' FROM ROLES WHERE RoleName = 'Cashier';

INSERT INTO STAFF (RoleID, FirstName, LastName, Phone, Email, HireDate)
SELECT RoleID, 'Karim', 'Hafez', '01001234508', 'karim.hafez@restaurant.eg', '2023-08-15' FROM ROLES WHERE RoleName = 'Delivery Driver';

INSERT INTO STAFF (RoleID, FirstName, LastName, Phone, Email, HireDate)
SELECT RoleID, 'Mahmoud', 'Nabil', '01001234509', 'mahmoud.nabil@restaurant.eg', '2023-09-01' FROM ROLES WHERE RoleName = 'Delivery Driver';

INSERT INTO STAFF (RoleID, FirstName, LastName, Phone, Email, HireDate)
SELECT RoleID, 'Fatma', 'Salem', '01001234510', 'fatma.salem@restaurant.eg', '2024-01-10' FROM ROLES WHERE RoleName = 'Cashier';

-- ============================================================================
-- SECTION 4: TABLES SETUP
-- ============================================================================

INSERT INTO TABLES (TableNumber, Capacity) VALUES
(1, 2), (2, 2), (3, 2),           -- 3 tables for couples
(4, 4), (5, 4), (6, 4), (7, 4),   -- 4 tables for small groups
(8, 6), (9, 6), (10, 6),          -- 3 tables for medium groups
(11, 8), (12, 10);                -- 2 tables for large groups

-- ============================================================================
-- SECTION 5: CUSTOMERS (30 customers for varied loyalty analysis)
-- ============================================================================

INSERT INTO CUSTOMERS (FirstName, LastName, Phone, Email, CreatedAt) VALUES
-- VIP Customers (high frequency)
('Mohamed', 'Ali', '01011111101', 'mohamed.ali@gmail.com', '2024-01-05'),
('Sara', 'Ibrahim', '01011111102', 'sara.ibrahim@gmail.com', '2024-01-10'),
('Youssef', 'Kamal', '01011111103', 'youssef.kamal@gmail.com', '2024-01-15'),
('Amira', 'Hamed', '01011111104', 'amira.hamed@gmail.com', '2024-01-20'),
('Heba', 'Saad', '01011111105', 'heba.saad@gmail.com', '2024-02-01'),
-- Gold Customers
('Mahmoud', 'Farag', '01011111106', 'mahmoud.farag@gmail.com', '2024-02-10'),
('Nour', 'El-Gendy', '01011111107', 'nour.elgendy@gmail.com', '2024-02-15'),
('Karim', 'Abdelrahman', '01011111108', 'karim.abdelrahman@gmail.com', '2024-02-20'),
('Salma', 'Fathy', '01011111109', 'salma.fathy@gmail.com', '2024-03-01'),
('Ola', 'Nasr', '01011111110', 'ola.nasr@gmail.com', '2024-03-05'),
-- Silver Customers
('Tarek', 'Samy', '01011111111', 'tarek.samy@gmail.com', '2024-03-10'),
('Mariam', 'Khalil', '01011111112', 'mariam.khalil@gmail.com', '2024-03-15'),
('Ahmed', 'Zaki', '01011111113', 'ahmed.zaki@gmail.com', '2024-04-01'),
('Dina', 'Fouad', '01011111114', 'dina.fouad@gmail.com', '2024-04-10'),
('Hassan', 'Reda', '01011111115', 'hassan.reda@gmail.com', '2024-04-15'),
-- Bronze Customers
('Layla', 'Mansour', '01011111116', 'layla.mansour@gmail.com', '2024-05-01'),
('Walid', 'Tamer', '01011111117', 'walid.tamer@gmail.com', '2024-05-10'),
('Rania', 'Sherif', '01011111118', 'rania.sherif@gmail.com', '2024-05-15'),
('Adel', 'Gamal', '01011111119', 'adel.gamal@gmail.com', '2024-06-01'),
('Noha', 'Ashraf', '01011111120', 'noha.ashraf@gmail.com', '2024-06-10'),
-- Occasional Customers
('Sherif', 'Helmy', '01011111121', 'sherif.helmy@gmail.com', '2024-07-01'),
('Yasmin', 'Naguib', '01011111122', 'yasmin.naguib@gmail.com', '2024-07-15'),
('Fady', 'Ramzy', '01011111123', 'fady.ramzy@gmail.com', '2024-08-01'),
('Mona', 'Atef', '01011111124', 'mona.atef@gmail.com', '2024-08-15'),
('Hazem', 'Badawy', '01011111125', 'hazem.badawy@gmail.com', '2024-09-01'),
-- New Customers
('Rana', 'Medhat', '01011111126', 'rana.medhat@gmail.com', '2024-10-01'),
('Tamer', 'Hosny', '01011111127', 'tamer.hosny@gmail.com', '2024-10-15'),
('Hana', 'Sabry', '01011111128', 'hana.sabry@gmail.com', '2024-11-01'),
('Khaled', 'Anwar', '01011111129', 'khaled.anwar@gmail.com', '2024-11-15'),
('Nadia', 'Lotfy', '01011111130', 'nadia.lotfy@gmail.com', '2024-12-01');

-- ============================================================================
-- SECTION 6: SUPPLIERS AND SUPPLY ORDERS
-- ============================================================================

INSERT INTO SUPPLIERS (Name, ContactEmail, Phone) VALUES
('Tanta Food Wholesale', 'orders@tantafood.eg', '0401234567'),
('Delta Farms', 'contact@deltafarms.eg', '0407654321'),
('Egyptian Grains Co', 'sales@egyptgrains.eg', '0409876543');

-- ============================================================================
-- SECTION 7: HISTORICAL DATA GENERATION
-- Using explicit loops for reliability
-- ============================================================================

-- Variables for data generation
DECLARE @StartDate DATE = '2024-01-01';
DECLARE @EndDate DATE = '2024-12-31';
DECLARE @CurrentDate DATE = @StartDate;
DECLARE @OrderID INT;
DECLARE @SupplyOrderID INT;

-- Temporary tables to hold IDs for lookups
DECLARE @StaffWaiters TABLE (StaffID INT);
DECLARE @StaffDelivery TABLE (StaffID INT);
DECLARE @StaffCashiers TABLE (StaffID INT);
DECLARE @MenuItemsList TABLE (MenuItemID INT, Price DECIMAL(10,2), CategoryName VARCHAR(100));
DECLARE @CustomersList TABLE (CustomerID INT, Tier VARCHAR(20));
DECLARE @TablesList TABLE (TableID INT, Capacity INT);
DECLARE @InventoryList TABLE (InventoryID INT, Name VARCHAR(100));

-- Populate lookup tables
INSERT INTO @StaffWaiters SELECT StaffID FROM STAFF s JOIN ROLES r ON s.RoleID = r.RoleID WHERE r.RoleName = 'Waiter';
INSERT INTO @StaffDelivery SELECT StaffID FROM STAFF s JOIN ROLES r ON s.RoleID = r.RoleID WHERE r.RoleName = 'Delivery Driver';
INSERT INTO @StaffCashiers SELECT StaffID FROM STAFF s JOIN ROLES r ON s.RoleID = r.RoleID WHERE r.RoleName = 'Cashier';
INSERT INTO @MenuItemsList SELECT m.MenuItemID, m.Price, c.Name FROM MENUITEMS m JOIN MENUCATEGORIES c ON m.CategoryID = c.CategoryID WHERE m.Available = 1;
INSERT INTO @TablesList SELECT TableID, Capacity FROM TABLES;
INSERT INTO @InventoryList SELECT InventoryID, Name FROM INVENTORYITEMS;

-- Assign customer tiers based on CustomerID
INSERT INTO @CustomersList 
SELECT CustomerID, 
    CASE 
        WHEN ROW_NUMBER() OVER (ORDER BY CustomerID) <= 5 THEN 'VIP'
        WHEN ROW_NUMBER() OVER (ORDER BY CustomerID) <= 10 THEN 'Gold'
        WHEN ROW_NUMBER() OVER (ORDER BY CustomerID) <= 15 THEN 'Silver'
        WHEN ROW_NUMBER() OVER (ORDER BY CustomerID) <= 20 THEN 'Bronze'
        ELSE 'New'
    END
FROM CUSTOMERS;

-- ============================================================================
-- GENERATE SUPPLY ORDERS (Monthly orders from each supplier)
-- ============================================================================

DECLARE @SupMonth INT = 1;
WHILE @SupMonth <= 12
BEGIN
    -- For each supplier, create a supply order this month
    DECLARE @SupplierID INT;
    DECLARE supplierCursor CURSOR FOR SELECT SupplierID FROM SUPPLIERS;
    OPEN supplierCursor;
    FETCH NEXT FROM supplierCursor INTO @SupplierID;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Create supply order on varying days of the month
        INSERT INTO SUPPLYORDERS (SupplierID, OrderDate, TotalCost)
        VALUES (@SupplierID, DATEFROMPARTS(2024, @SupMonth, 5 + (@SupplierID * 3) % 20), 0);
        
        SET @SupplyOrderID = SCOPE_IDENTITY();
        
        -- Add 4-6 random items to each supply order
        INSERT INTO SUPPLYORDERITEMS (SupplyOrderID, InventoryID, Quantity, CostPerUnit)
        SELECT TOP (4 + @SupMonth % 3)
            @SupplyOrderID,
            InventoryID,
            50 + (InventoryID * @SupMonth) % 100,  -- Quantity between 50-150
            5.00 + (InventoryID * 2.5)              -- Cost varies by item
        FROM @InventoryList
        ORDER BY NEWID();
        
        -- Update supply order total
        UPDATE SUPPLYORDERS 
        SET TotalCost = (SELECT SUM(Quantity * CostPerUnit) FROM SUPPLYORDERITEMS WHERE SupplyOrderID = @SupplyOrderID)
        WHERE SupplyOrderID = @SupplyOrderID;
        
        FETCH NEXT FROM supplierCursor INTO @SupplierID;
    END;
    
    CLOSE supplierCursor;
    DEALLOCATE supplierCursor;
    
    SET @SupMonth = @SupMonth + 1;
END;

-- ============================================================================
-- GENERATE ORDERS (8-15 orders per day throughout the year)
-- ============================================================================

WHILE @CurrentDate <= @EndDate
BEGIN
    DECLARE @DayOfWeek INT = DATEPART(WEEKDAY, @CurrentDate);
    DECLARE @Month INT = MONTH(@CurrentDate);
    DECLARE @DayNum INT = DAY(@CurrentDate);
    
    -- More orders on weekends and during summer/winter holidays
    DECLARE @OrdersToday INT = 8 + (@DayNum % 8);  -- Base 8-15 orders
    IF @DayOfWeek IN (6, 7) SET @OrdersToday = @OrdersToday + 3;  -- Weekend bonus
    IF @Month IN (7, 8, 12) SET @OrdersToday = @OrdersToday + 2;  -- Holiday months
    
    DECLARE @OrderNum INT = 1;
    WHILE @OrderNum <= @OrdersToday
    BEGIN
        -- Determine order type based on pattern
        DECLARE @OrderType VARCHAR(20) = 
            CASE 
                WHEN @OrderNum % 5 = 0 THEN 'Delivery'
                WHEN @OrderNum % 3 = 0 THEN 'Takeout'
                ELSE 'Dine-In'
            END;
        
        -- Select customer (VIP/Gold customers order more frequently)
        DECLARE @CustomerID INT;
        SELECT TOP 1 @CustomerID = CustomerID 
        FROM @CustomersList 
        WHERE 
            (Tier = 'VIP' AND @OrderNum % 2 = 0) OR
            (Tier = 'Gold' AND @OrderNum % 3 = 0) OR
            (Tier = 'Silver' AND @OrderNum % 4 = 0) OR
            (Tier IN ('Bronze', 'New'))
        ORDER BY NEWID();
        
        -- Select appropriate staff based on order type
        DECLARE @StaffID INT;
        IF @OrderType = 'Delivery'
            SELECT TOP 1 @StaffID = StaffID FROM @StaffDelivery ORDER BY NEWID();
        ELSE IF @OrderType = 'Takeout'
            SELECT TOP 1 @StaffID = StaffID FROM @StaffCashiers ORDER BY NEWID();
        ELSE
            SELECT TOP 1 @StaffID = StaffID FROM @StaffWaiters ORDER BY NEWID();
        
        -- Order time (11 AM to 10 PM, varied throughout day)
        DECLARE @Hour INT = 11 + (@OrderNum % 11);  -- 11 AM to 10 PM
        DECLARE @OrderDateTime DATETIME = DATEADD(HOUR, @Hour, CAST(@CurrentDate AS DATETIME));
        SET @OrderDateTime = DATEADD(MINUTE, @OrderNum * 7 % 60, @OrderDateTime);
        
        -- Payment status (most are paid, some unpaid for recent orders)
        DECLARE @PaymentStatus VARCHAR(20) = 
            CASE 
                WHEN @Month = 12 AND @OrderNum % 10 = 0 THEN 'Unpaid'
                WHEN @OrderNum % 50 = 0 THEN 'Refunded'
                ELSE 'Paid'
            END;
        
        -- Create order
        INSERT INTO ORDERS (CustomerID, StaffID, OrderType, OrderDateTime, TotalAmount, PaymentStatus)
        VALUES (@CustomerID, @StaffID, @OrderType, @OrderDateTime, 0, @PaymentStatus);
        
        SET @OrderID = SCOPE_IDENTITY();
        
        -- Add 1-4 items to order (more items for dine-in)
        DECLARE @ItemCount INT = 1 + (@OrderNum % 3);
        IF @OrderType = 'Dine-In' SET @ItemCount = @ItemCount + 1;
        
        -- Insert order items with varied categories
        INSERT INTO ORDERITEMS (OrderID, MenuItemID, Quantity, PriceAtPurchase)
        SELECT TOP (@ItemCount)
            @OrderID,
            MenuItemID,
            1 + (MenuItemID % 3),  -- Quantity 1-3
            Price
        FROM @MenuItemsList
        ORDER BY NEWID();
        
        -- Update order total
        UPDATE ORDERS 
        SET TotalAmount = (SELECT SUM(Quantity * PriceAtPurchase) FROM ORDERITEMS WHERE OrderID = @OrderID)
        WHERE OrderID = @OrderID;
        
        SET @OrderNum = @OrderNum + 1;
    END;
    
    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END;

-- ============================================================================
-- GENERATE RESERVATIONS (2-5 per day)
-- ============================================================================

SET @CurrentDate = @StartDate;

WHILE @CurrentDate <= @EndDate
BEGIN
    DECLARE @DayOfWeek2 INT = DATEPART(WEEKDAY, @CurrentDate);
    DECLARE @ResCount INT = 2 + (@DayOfWeek2 % 4);  -- More on weekends
    
    DECLARE @ResNum INT = 1;
    WHILE @ResNum <= @ResCount
    BEGIN
        DECLARE @ResCustomerID INT;
        SELECT TOP 1 @ResCustomerID = CustomerID FROM @CustomersList ORDER BY NEWID();
        
        DECLARE @ResTableID INT;
        SELECT TOP 1 @ResTableID = TableID FROM @TablesList ORDER BY NEWID();
        
        -- Reservation time (12 PM to 9 PM)
        DECLARE @ResHour INT = 12 + (@ResNum * 2);
        DECLARE @ResDateTime DATETIME = DATEADD(HOUR, @ResHour, CAST(@CurrentDate AS DATETIME));
        
        -- Guest count based on table capacity
        DECLARE @NumGuests INT;
        SELECT @NumGuests = CASE WHEN Capacity > 2 THEN 2 + (Capacity / 2) ELSE Capacity END 
        FROM @TablesList WHERE TableID = @ResTableID;
        
        -- Status based on whether date is past or future
        DECLARE @ResStatus VARCHAR(20);
        IF @CurrentDate < '2024-12-15'
            SET @ResStatus = CASE 
                WHEN @ResNum % 10 = 0 THEN 'Canceled'
                ELSE 'Completed'
            END;
        ELSE
            SET @ResStatus = CASE 
                WHEN @ResNum % 3 = 0 THEN 'Pending'
                ELSE 'Confirmed'
            END;
        
        INSERT INTO RESERVATIONS (CustomerID, TableID, ReservationDateTime, NumGuests, Status)
        VALUES (@ResCustomerID, @ResTableID, @ResDateTime, @NumGuests, @ResStatus);
        
        SET @ResNum = @ResNum + 1;
    END;
    
    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END;

-- ============================================================================
-- UPDATE INVENTORY QUANTITIES (Add received supplies)
-- ============================================================================

UPDATE i
SET Quantity = i.Quantity + ISNULL(s.TotalReceived, 0)
FROM INVENTORYITEMS i
LEFT JOIN (
    SELECT InventoryID, SUM(Quantity) AS TotalReceived
    FROM SUPPLYORDERITEMS
    GROUP BY InventoryID
) s ON i.InventoryID = s.InventoryID;

-- ============================================================================
-- FINAL SUMMARY
-- ============================================================================

PRINT '============================================';
PRINT 'RestaurantDB Seed Data Complete!';
PRINT '============================================';
PRINT '';

SELECT 'Menu Categories' AS Entity, COUNT(*) AS Count FROM MENUCATEGORIES
UNION ALL SELECT 'Menu Items', COUNT(*) FROM MENUITEMS
UNION ALL SELECT 'Inventory Items', COUNT(*) FROM INVENTORYITEMS
UNION ALL SELECT 'Recipe Ingredients', COUNT(*) FROM RECIPE_INGREDIENTS
UNION ALL SELECT 'Roles', COUNT(*) FROM ROLES
UNION ALL SELECT 'Staff', COUNT(*) FROM STAFF
UNION ALL SELECT 'Tables', COUNT(*) FROM TABLES
UNION ALL SELECT 'Customers', COUNT(*) FROM CUSTOMERS
UNION ALL SELECT 'Suppliers', COUNT(*) FROM SUPPLIERS
UNION ALL SELECT 'Supply Orders', COUNT(*) FROM SUPPLYORDERS
UNION ALL SELECT 'Supply Order Items', COUNT(*) FROM SUPPLYORDERITEMS
UNION ALL SELECT 'Orders', COUNT(*) FROM ORDERS
UNION ALL SELECT 'Order Items', COUNT(*) FROM ORDERITEMS
UNION ALL SELECT 'Reservations', COUNT(*) FROM RESERVATIONS;

PRINT '';
PRINT 'Data is ready for analytical queries!';
PRINT 'Try: EXEC sp_DailySalesSummary, sp_CustomerLoyaltyReport, sp_MenuProfitability';
GO
