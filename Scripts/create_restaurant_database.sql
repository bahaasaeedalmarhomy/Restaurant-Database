/*
    RestaurantDB schema creation script
    Purpose: Create a SQL Server database schema that matches the ERD in the project requirements.
*/
-- Create database if it does not already exist
IF DB_ID('RestaurantDB') IS NULL CREATE DATABASE RestaurantDB;
GO
-- Switch context to the target database
USE RestaurantDB;
GO

-- Front of House: customers record
CREATE TABLE CUSTOMERS (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY, -- Using IDENTITY(seed, increment) to auto-generate unique IDs
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Phone VARCHAR(25),
    Email VARCHAR(255),
    CreatedAt DATETIME NOT NULL DEFAULT(GETDATE()) -- To track the date and time a customer first ordered from the restaurant 
);

-- Physical tables in the restaurant (e.g., table numbers and seating capacity)
CREATE TABLE TABLES (
    TableID INT IDENTITY(1,1) PRIMARY KEY,
    TableNumber INT NOT NULL UNIQUE,
    Capacity INT NOT NULL
);

-- Staff roles lookup (e.g., Manager, Chef, Waiter)
CREATE TABLE ROLES (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName VARCHAR(100) NOT NULL UNIQUE
);

-- Staff list linked to roles; basic contact and hire date
CREATE TABLE STAFF (
    StaffID INT IDENTITY(1,1) PRIMARY KEY,
    RoleID INT NOT NULL,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Phone VARCHAR(25),
    Email VARCHAR(255),
    HireDate DATE NOT NULL,
    CONSTRAINT FK_STAFF_ROLE FOREIGN KEY (RoleID) REFERENCES ROLES(RoleID)
);

-- Menu category (e.g., Appetizers, Main Dishes, Drinks)
CREATE TABLE MENUCATEGORIES (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE
);

-- Menu items linked to categories; price and availability
CREATE TABLE MENUITEMS (
    MenuItemID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Description VARCHAR(500),
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    Available BIT NOT NULL DEFAULT(1), -- Using binary variable to indicate the availability of an item
    CONSTRAINT FK_MENUITEMS_CATEGORY FOREIGN KEY (CategoryID) REFERENCES MENUCATEGORIES(CategoryID),
    CONSTRAINT UQ_MENUITEMS_Category_Name UNIQUE (CategoryID, Name) -- To ensure that each menu item has a unique name within its category
);

-- Inventory items in storage with current stock and reorder threshold
CREATE TABLE INVENTORYITEMS (
    InventoryID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE,
    Quantity INT NOT NULL,
    Unit VARCHAR(50) NOT NULL, -- Specifies the unit used to count the quantity (e.g., "kg," "grams," "liters," "cases," "bottles")
    ReorderLevel INT NOT NULL CHECK (ReorderLevel >= 0) -- To ensure that the reorder level is non-negative
);

/*
    Recipe ingredients bridge: maps each menu item to required inventory items
    Enforces positive quantities and prevents duplicate ingredient mapping per menu item
*/
CREATE TABLE RECIPE_INGREDIENTS (
    RecipeID INT IDENTITY(1,1) PRIMARY KEY,
    MenuItemID INT NOT NULL,
    InventoryID INT NOT NULL,
    QuantityRequired DECIMAL(10,2) NOT NULL CHECK (QuantityRequired > 0),
    Unit VARCHAR(50) NOT NULL,
    CONSTRAINT FK_RECIPE_MENUITEM FOREIGN KEY (MenuItemID) REFERENCES MENUITEMS(MenuItemID),
    CONSTRAINT FK_RECIPE_INVENTORY FOREIGN KEY (InventoryID) REFERENCES INVENTORYITEMS(InventoryID),
    CONSTRAINT UQ_RECIPE_INGREDIENT UNIQUE (MenuItemID, InventoryID) -- To ensure that a single menu item cannot list the same inventory ingredient twice in its recipe.
);

-- Supplier master data
CREATE TABLE SUPPLIERS (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(200) NOT NULL UNIQUE,
    ContactEmail VARCHAR(255),
    Phone VARCHAR(25)
);

-- Supply orders placed with suppliers; total cost validated non-negative
CREATE TABLE SUPPLYORDERS (
    SupplyOrderID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT NOT NULL,
    OrderDate DATE NOT NULL DEFAULT(GETDATE()),
    TotalCost DECIMAL(12,2) NOT NULL CHECK (TotalCost >= 0),
    CONSTRAINT FK_SUPPLYORDERS_SUPPLIER FOREIGN KEY (SupplierID) REFERENCES SUPPLIERS(SupplierID)
);

-- Line items for supply orders; references inventory and order
CREATE TABLE SUPPLYORDERITEMS (
    SupplyOrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    SupplyOrderID INT NOT NULL,
    InventoryID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    CostPerUnit DECIMAL(10,2) NOT NULL CHECK (CostPerUnit >= 0),
    CONSTRAINT FK_SOITEMS_SUPPLYORDER FOREIGN KEY (SupplyOrderID) REFERENCES SUPPLYORDERS(SupplyOrderID),
    CONSTRAINT FK_SOITEMS_INVENTORY FOREIGN KEY (InventoryID) REFERENCES INVENTORYITEMS(InventoryID)
);

/*
    Customer orders processed by staff
    OrderType and PaymentStatus act as enum-like fields via CHECK constraints
*/
CREATE TABLE ORDERS (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    StaffID INT NOT NULL,
    OrderType VARCHAR(20) NOT NULL,
    OrderDateTime DATETIME NOT NULL DEFAULT(GETDATE()),
    TotalAmount DECIMAL(10,2) NOT NULL CHECK (TotalAmount >= 0),
    PaymentStatus VARCHAR(20) NOT NULL,
    CONSTRAINT FK_ORDERS_CUSTOMER FOREIGN KEY (CustomerID) REFERENCES CUSTOMERS(CustomerID),
    CONSTRAINT FK_ORDERS_STAFF FOREIGN KEY (StaffID) REFERENCES STAFF(StaffID),
    CONSTRAINT CK_ORDERS_OrderType CHECK (OrderType IN ('Dine-In','Takeout','Delivery')), -- Because T-SQL does not have built-in ENUM type, we use a CHECK constraint to ensure valid order types.
    CONSTRAINT CK_ORDERS_PaymentStatus CHECK (PaymentStatus IN ('Paid','Unpaid','Refunded'))
);

-- Order line items tying orders to menu items, with quantities and captured price
CREATE TABLE ORDERITEMS (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    MenuItemID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    PriceAtPurchase DECIMAL(10,2) NOT NULL CHECK (PriceAtPurchase >= 0), -- Important in cases if the prices in the menu changed later
    CONSTRAINT FK_ORDERITEMS_ORDER FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID),
    CONSTRAINT FK_ORDERITEMS_MENUITEM FOREIGN KEY (MenuItemID) REFERENCES MENUITEMS(MenuItemID)
);

/*
    Reservations link customers to specific tables at a timestamp
    Status acts like an enum via CHECK
*/
CREATE TABLE RESERVATIONS (
    ReservationID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    TableID INT NOT NULL,
    ReservationDateTime DATETIME NOT NULL,
    NumGuests INT NOT NULL CHECK (NumGuests > 0),
    Status VARCHAR(20) NOT NULL,
    CONSTRAINT FK_RESERVATIONS_CUSTOMER FOREIGN KEY (CustomerID) REFERENCES CUSTOMERS(CustomerID),
    CONSTRAINT FK_RESERVATIONS_TABLE FOREIGN KEY (TableID) REFERENCES TABLES(TableID),
    CONSTRAINT CK_RESERVATIONS_Status CHECK (Status IN ('Pending','Confirmed','Completed','Canceled'))
);

-- Helpful nonclustered indexes to accelerate common joins and lookups (FK columns)
CREATE INDEX IX_STAFF_RoleID ON STAFF(RoleID);
CREATE INDEX IX_MENUITEMS_CategoryID ON MENUITEMS(CategoryID);
CREATE INDEX IX_RECIPE_MenuItemID ON RECIPE_INGREDIENTS(MenuItemID);
CREATE INDEX IX_RECIPE_InventoryID ON RECIPE_INGREDIENTS(InventoryID);
CREATE INDEX IX_SUPPLYORDERS_SupplierID ON SUPPLYORDERS(SupplierID);
CREATE INDEX IX_SUPPLYORDERITEMS_SupplyOrderID ON SUPPLYORDERITEMS(SupplyOrderID);
CREATE INDEX IX_SUPPLYORDERITEMS_InventoryID ON SUPPLYORDERITEMS(InventoryID);
CREATE INDEX IX_ORDERS_CustomerID ON ORDERS(CustomerID);
CREATE INDEX IX_ORDERS_StaffID ON ORDERS(StaffID);
CREATE INDEX IX_ORDERITEMS_OrderID ON ORDERITEMS(OrderID);
CREATE INDEX IX_ORDERITEMS_MenuItemID ON ORDERITEMS(MenuItemID);
CREATE INDEX IX_RESERVATIONS_CustomerID ON RESERVATIONS(CustomerID);
CREATE INDEX IX_RESERVATIONS_TableID ON RESERVATIONS(TableID);