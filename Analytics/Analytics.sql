/*
    Restaurant Analytics Script
    Comprehensive statistical queries, functions, procedures, and triggers for business insights
*/
USE RestaurantDB;
GO

-- ============================================================================
-- SECTION 1: SCALAR FUNCTIONS
-- ============================================================================

-- Calculate total revenue for a specific date range
CREATE OR ALTER FUNCTION dbo.fn_GetRevenue(@StartDate DATE, @EndDate DATE)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @Revenue DECIMAL(12,2);
    SELECT @Revenue = ISNULL(SUM(TotalAmount), 0)
    FROM ORDERS
    WHERE CAST(OrderDateTime AS DATE) BETWEEN @StartDate AND @EndDate
        AND PaymentStatus = 'Paid';
    RETURN @Revenue;
END;
GO

-- Calculate customer lifetime value
CREATE OR ALTER FUNCTION dbo.fn_CustomerLifetimeValue(@CustomerID INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @TotalSpent DECIMAL(12,2);
    SELECT @TotalSpent = ISNULL(SUM(TotalAmount), 0)
    FROM ORDERS
    WHERE CustomerID = @CustomerID AND PaymentStatus = 'Paid';
    RETURN @TotalSpent;
END;
GO

-- Get inventory item cost efficiency (revenue generated per unit)
CREATE OR ALTER FUNCTION dbo.fn_InventoryEfficiency(@InventoryID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalRevenue DECIMAL(12,2);
    DECLARE @TotalUsed DECIMAL(10,2);
    
    SELECT @TotalRevenue = ISNULL(SUM(oi.Quantity * oi.PriceAtPurchase), 0),
           @TotalUsed = ISNULL(SUM(oi.Quantity * ri.QuantityRequired), 0.01)
    FROM ORDERITEMS oi
    JOIN RECIPE_INGREDIENTS ri ON oi.MenuItemID = ri.MenuItemID
    WHERE ri.InventoryID = @InventoryID;
    
    RETURN @TotalRevenue / @TotalUsed;
END;
GO

-- ============================================================================
-- SECTION 2: TABLE-VALUED FUNCTIONS
-- ============================================================================

-- Get top menu items by revenue in date range
CREATE OR ALTER FUNCTION dbo.fn_TopMenuItems(@StartDate DATE, @EndDate DATE, @TopN INT)
RETURNS TABLE
AS
RETURN (
    SELECT TOP (@TopN)
        mi.MenuItemID,
        mi.Name,
        mc.Name AS Category,
        COUNT(oi.OrderItemID) AS TimesSold,
        SUM(oi.Quantity) AS TotalQuantity,
        SUM(oi.Quantity * oi.PriceAtPurchase) AS TotalRevenue,
        AVG(oi.PriceAtPurchase) AS AvgPrice
    FROM ORDERITEMS oi
    JOIN MENUITEMS mi ON oi.MenuItemID = mi.MenuItemID
    JOIN MENUCATEGORIES mc ON mi.CategoryID = mc.CategoryID
    JOIN ORDERS o ON oi.OrderID = o.OrderID
    WHERE CAST(o.OrderDateTime AS DATE) BETWEEN @StartDate AND @EndDate
        AND o.PaymentStatus = 'Paid'
    GROUP BY mi.MenuItemID, mi.Name, mc.Name
    ORDER BY TotalRevenue DESC
);
GO

-- Get hourly sales distribution
CREATE OR ALTER FUNCTION dbo.fn_HourlySales(@TargetDate DATE)
RETURNS TABLE
AS
RETURN (
    SELECT 
        DATEPART(HOUR, OrderDateTime) AS HourOfDay,
        COUNT(OrderID) AS OrderCount,
        SUM(TotalAmount) AS TotalRevenue,
        AVG(TotalAmount) AS AvgOrderValue
    FROM ORDERS
    WHERE CAST(OrderDateTime AS DATE) = @TargetDate
        AND PaymentStatus = 'Paid'
    GROUP BY DATEPART(HOUR, OrderDateTime)
);
GO

-- ============================================================================
-- SECTION 3: STORED PROCEDURES
-- ============================================================================

-- Daily sales summary report
CREATE OR ALTER PROCEDURE sp_DailySalesSummary
    @ReportDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @ReportDate IS NULL SET @ReportDate = CAST(GETDATE() AS DATE);
    
    -- Overall summary
    SELECT 
        @ReportDate AS ReportDate,
        COUNT(DISTINCT OrderID) AS TotalOrders,
        SUM(TotalAmount) AS TotalRevenue,
        AVG(TotalAmount) AS AvgOrderValue,
        SUM(CASE WHEN OrderType = 'Dine-In' THEN TotalAmount ELSE 0 END) AS DineInRevenue,
        SUM(CASE WHEN OrderType = 'Takeout' THEN TotalAmount ELSE 0 END) AS TakeoutRevenue,
        SUM(CASE WHEN OrderType = 'Delivery' THEN TotalAmount ELSE 0 END) AS DeliveryRevenue
    FROM ORDERS
    WHERE CAST(OrderDateTime AS DATE) = @ReportDate
        AND PaymentStatus = 'Paid';
    
    -- Top 5 items of the day
    SELECT TOP 5
        mi.Name AS MenuItem,
        COUNT(*) AS OrderCount,
        SUM(oi.Quantity) AS TotalQuantity,
        SUM(oi.Quantity * oi.PriceAtPurchase) AS Revenue
    FROM ORDERITEMS oi
    JOIN ORDERS o ON oi.OrderID = o.OrderID
    JOIN MENUITEMS mi ON oi.MenuItemID = mi.MenuItemID
    WHERE CAST(o.OrderDateTime AS DATE) = @ReportDate
        AND o.PaymentStatus = 'Paid'
    GROUP BY mi.Name
    ORDER BY Revenue DESC;
    
    -- Peak hours
    SELECT 
        DATEPART(HOUR, OrderDateTime) AS Hour,
        COUNT(*) AS OrderCount,
        SUM(TotalAmount) AS Revenue
    FROM ORDERS
    WHERE CAST(OrderDateTime AS DATE) = @ReportDate
        AND PaymentStatus = 'Paid'
    GROUP BY DATEPART(HOUR, OrderDateTime)
    ORDER BY OrderCount DESC;
END;
GO

-- Customer loyalty analysis
CREATE OR ALTER PROCEDURE sp_CustomerLoyaltyReport
    @MinOrders INT = 5
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        c.CustomerID,
        c.FirstName + ' ' + c.LastName AS CustomerName,
        c.Email,
        COUNT(o.OrderID) AS TotalOrders,
        SUM(o.TotalAmount) AS TotalSpent,
        AVG(o.TotalAmount) AS AvgOrderValue,
        MIN(o.OrderDateTime) AS FirstOrder,
        MAX(o.OrderDateTime) AS LastOrder,
        DATEDIFF(DAY, MIN(o.OrderDateTime), MAX(o.OrderDateTime)) AS CustomerLifespanDays,
        CASE 
            WHEN COUNT(o.OrderID) >= 50 THEN 'VIP'
            WHEN COUNT(o.OrderID) >= 20 THEN 'Gold'
            WHEN COUNT(o.OrderID) >= 10 THEN 'Silver'
            ELSE 'Bronze'
        END AS LoyaltyTier
    FROM CUSTOMERS c
    JOIN ORDERS o ON c.CustomerID = o.CustomerID
    WHERE o.PaymentStatus = 'Paid'
    GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Email
    HAVING COUNT(o.OrderID) >= @MinOrders
    ORDER BY TotalSpent DESC;
END;
GO

-- Inventory reorder alert
CREATE OR ALTER PROCEDURE sp_InventoryReorderAlert
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ii.InventoryID,
        ii.Name AS Item,
        ii.Quantity AS CurrentStock,
        ii.Unit,
        ii.ReorderLevel,
        ii.Quantity - ii.ReorderLevel AS StockDifference,
        CASE 
            WHEN ii.Quantity = 0 THEN 'OUT OF STOCK'
            WHEN ii.Quantity < ii.ReorderLevel * 0.5 THEN 'CRITICAL'
            WHEN ii.Quantity < ii.ReorderLevel THEN 'LOW'
            ELSE 'OK'
        END AS StockStatus,
        COUNT(DISTINCT ri.MenuItemID) AS AffectedMenuItems
    FROM INVENTORYITEMS ii
    LEFT JOIN RECIPE_INGREDIENTS ri ON ii.InventoryID = ri.InventoryID
    WHERE ii.Quantity <= ii.ReorderLevel
    GROUP BY ii.InventoryID, ii.Name, ii.Quantity, ii.Unit, ii.ReorderLevel
    ORDER BY StockStatus, ii.Quantity;
END;
GO

-- Staff performance report
CREATE OR ALTER PROCEDURE sp_StaffPerformance
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        s.StaffID,
        s.FirstName + ' ' + s.LastName AS StaffName,
        r.RoleName,
        COUNT(DISTINCT o.OrderID) AS OrdersHandled,
        SUM(o.TotalAmount) AS TotalSales,
        AVG(o.TotalAmount) AS AvgOrderValue,
        COUNT(DISTINCT CAST(o.OrderDateTime AS DATE)) AS DaysWorked,
        CAST(COUNT(DISTINCT o.OrderID) AS FLOAT) / NULLIF(COUNT(DISTINCT CAST(o.OrderDateTime AS DATE)), 0) AS AvgOrdersPerDay
    FROM STAFF s
    JOIN ROLES r ON s.RoleID = r.RoleID
    LEFT JOIN ORDERS o ON s.StaffID = o.StaffID 
        AND CAST(o.OrderDateTime AS DATE) BETWEEN @StartDate AND @EndDate
        AND o.PaymentStatus = 'Paid'
    GROUP BY s.StaffID, s.FirstName, s.LastName, r.RoleName
    ORDER BY TotalSales DESC;
END;
GO

-- Monthly trend analysis
CREATE OR ALTER PROCEDURE sp_MonthlyTrends
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        MONTH(OrderDateTime) AS Month,
        DATENAME(MONTH, OrderDateTime) AS MonthName,
        COUNT(DISTINCT OrderID) AS TotalOrders,
        SUM(TotalAmount) AS Revenue,
        AVG(TotalAmount) AS AvgOrderValue,
        COUNT(DISTINCT CustomerID) AS UniqueCustomers,
        SUM(CASE WHEN OrderType = 'Dine-In' THEN 1 ELSE 0 END) AS DineInOrders,
        SUM(CASE WHEN OrderType = 'Takeout' THEN 1 ELSE 0 END) AS TakeoutOrders,
        SUM(CASE WHEN OrderType = 'Delivery' THEN 1 ELSE 0 END) AS DeliveryOrders
    FROM ORDERS
    WHERE YEAR(OrderDateTime) = @Year
        AND PaymentStatus = 'Paid'
    GROUP BY MONTH(OrderDateTime), DATENAME(MONTH, OrderDateTime)
    ORDER BY MONTH(OrderDateTime);
END;
GO

-- Menu item profitability analysis
CREATE OR ALTER PROCEDURE sp_MenuProfitability
AS
BEGIN
    SET NOCOUNT ON;
    
    WITH ItemCosts AS (
        SELECT 
            mi.MenuItemID,
            mi.Name,
            mi.Price,
            ISNULL(SUM(ri.QuantityRequired * soi.AvgCost), 0) AS EstimatedCost
        FROM MENUITEMS mi
        LEFT JOIN RECIPE_INGREDIENTS ri ON mi.MenuItemID = ri.MenuItemID
        LEFT JOIN (
            SELECT 
                InventoryID, 
                AVG(CostPerUnit) AS AvgCost
            FROM SUPPLYORDERITEMS
            GROUP BY InventoryID
        ) soi ON ri.InventoryID = soi.InventoryID
        GROUP BY mi.MenuItemID, mi.Name, mi.Price
    ),
    ItemSales AS (
        SELECT 
            mi.MenuItemID,
            COUNT(oi.OrderItemID) AS TimesSold,
            SUM(oi.Quantity) AS TotalQuantitySold,
            SUM(oi.Quantity * oi.PriceAtPurchase) AS TotalRevenue
        FROM MENUITEMS mi
        LEFT JOIN ORDERITEMS oi ON mi.MenuItemID = oi.MenuItemID
        LEFT JOIN ORDERS o ON oi.OrderID = o.OrderID AND o.PaymentStatus = 'Paid'
        GROUP BY mi.MenuItemID
    )
    SELECT 
        ic.MenuItemID,
        ic.Name AS MenuItem,
        ic.Price AS CurrentPrice,
        ic.EstimatedCost,
        ic.Price - ic.EstimatedCost AS ProfitPerUnit,
        CAST((ic.Price - ic.EstimatedCost) / NULLIF(ic.Price, 0) * 100 AS DECIMAL(5,2)) AS ProfitMargin,
        ISNULL(s.TimesSold, 0) AS TimesSold,
        ISNULL(s.TotalQuantitySold, 0) AS TotalQuantitySold,
        ISNULL(s.TotalRevenue, 0) AS TotalRevenue,
        ISNULL(s.TotalRevenue - (s.TotalQuantitySold * ic.EstimatedCost), 0) AS TotalProfit
    FROM ItemCosts ic
    LEFT JOIN ItemSales s ON ic.MenuItemID = s.MenuItemID
    ORDER BY TotalProfit DESC;
END;
GO

-- ============================================================================
-- SECTION 4: TRIGGERS
-- ============================================================================

-- Automatically update order total when order items change
CREATE OR ALTER TRIGGER trg_UpdateOrderTotal
ON ORDERITEMS
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Update totals for affected orders
    UPDATE o
    SET TotalAmount = ISNULL(calc.Total, 0)
    FROM ORDERS o
    INNER JOIN (
        SELECT OrderID, SUM(Quantity * PriceAtPurchase) AS Total
        FROM ORDERITEMS
        WHERE OrderID IN (
            SELECT DISTINCT OrderID FROM inserted
            UNION
            SELECT DISTINCT OrderID FROM deleted
        )
        GROUP BY OrderID
    ) calc ON o.OrderID = calc.OrderID;
END;
GO

-- Log low inventory warnings
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'InventoryAlerts')
CREATE TABLE InventoryAlerts (
    AlertID INT IDENTITY(1,1) PRIMARY KEY,
    InventoryID INT NOT NULL,
    ItemName VARCHAR(100),
    Quantity INT,
    ReorderLevel INT,
    AlertDateTime DATETIME DEFAULT GETDATE(),
    AlertMessage VARCHAR(500)
);
GO

CREATE OR ALTER TRIGGER trg_LowInventoryAlert
ON INVENTORYITEMS
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO InventoryAlerts (InventoryID, ItemName, Quantity, ReorderLevel, AlertMessage)
    SELECT 
        i.InventoryID,
        i.Name,
        i.Quantity,
        i.ReorderLevel,
        CASE 
            WHEN i.Quantity = 0 THEN 'CRITICAL: Item is out of stock!'
            WHEN i.Quantity < i.ReorderLevel * 0.5 THEN 'WARNING: Item below 50% of reorder level'
            WHEN i.Quantity < i.ReorderLevel THEN 'NOTICE: Item below reorder level'
        END
    FROM inserted i
    WHERE i.Quantity <= i.ReorderLevel
        AND NOT EXISTS (
            SELECT 1 FROM InventoryAlerts a
            WHERE a.InventoryID = i.InventoryID
                AND a.Quantity = i.Quantity
                AND DATEDIFF(HOUR, a.AlertDateTime, GETDATE()) < 24
        );
END;
GO

-- ============================================================================
-- SECTION 5: KEY ANALYTICAL QUERIES
-- ============================================================================

-- Query 1: Revenue by day of week
CREATE OR ALTER VIEW vw_RevenueByDayOfWeek AS
SELECT 
    DATENAME(WEEKDAY, OrderDateTime) AS DayOfWeek,
    DATEPART(WEEKDAY, OrderDateTime) AS DayNumber,
    COUNT(OrderID) AS TotalOrders,
    SUM(TotalAmount) AS TotalRevenue,
    AVG(TotalAmount) AS AvgOrderValue
FROM ORDERS
WHERE PaymentStatus = 'Paid'
GROUP BY DATENAME(WEEKDAY, OrderDateTime), DATEPART(WEEKDAY, OrderDateTime);
GO

-- Query 2: Customer retention rate
CREATE OR ALTER VIEW vw_CustomerRetention AS
WITH MonthlyCustomers AS (
    SELECT 
        c.CustomerID,
        YEAR(o.OrderDateTime) AS Year,
        MONTH(o.OrderDateTime) AS Month
    FROM CUSTOMERS c
    JOIN ORDERS o ON c.CustomerID = o.CustomerID
    WHERE o.PaymentStatus = 'Paid'
    GROUP BY c.CustomerID, YEAR(o.OrderDateTime), MONTH(o.OrderDateTime)
)
SELECT 
    mc1.Year,
    mc1.Month,
    COUNT(DISTINCT mc1.CustomerID) AS TotalCustomers,
    COUNT(DISTINCT mc2.CustomerID) AS ReturnedCustomers,
    CAST(COUNT(DISTINCT mc2.CustomerID) AS FLOAT) / NULLIF(COUNT(DISTINCT mc1.CustomerID), 0) * 100 AS RetentionRate
FROM MonthlyCustomers mc1
LEFT JOIN MonthlyCustomers mc2 
    ON mc1.CustomerID = mc2.CustomerID 
    AND mc2.Year = mc1.Year 
    AND mc2.Month = mc1.Month + 1
GROUP BY mc1.Year, mc1.Month;
GO

-- Query 3: Table utilization
CREATE OR ALTER VIEW vw_TableUtilization AS
SELECT 
    t.TableNumber,
    t.Capacity,
    COUNT(DISTINCT r.ReservationID) AS TotalReservations,
    AVG(CAST(r.NumGuests AS FLOAT)) AS AvgGuestsPerReservation,
    AVG(CAST(r.NumGuests AS FLOAT)) / t.Capacity * 100 AS UtilizationRate,
    COUNT(DISTINCT CASE WHEN r.Status = 'Completed' THEN r.ReservationID END) AS CompletedReservations,
    COUNT(DISTINCT CASE WHEN r.Status = 'No-Show' THEN r.ReservationID END) AS NoShows
FROM TABLES t
LEFT JOIN RESERVATIONS r ON t.TableID = r.TableID
GROUP BY t.TableNumber, t.Capacity;
GO

-- Query 4: Supply cost trends
CREATE OR ALTER VIEW vw_SupplyCostTrends AS
SELECT 
    s.Name AS Supplier,
    YEAR(so.OrderDate) AS Year,
    MONTH(so.OrderDate) AS Month,
    COUNT(so.SupplyOrderID) AS OrderCount,
    SUM(so.TotalCost) AS TotalSpent,
    AVG(so.TotalCost) AS AvgOrderCost
FROM SUPPLIERS s
JOIN SUPPLYORDERS so ON s.SupplierID = so.SupplierID
GROUP BY s.Name, YEAR(so.OrderDate), MONTH(so.OrderDate);
GO

PRINT 'Restaurant analytics objects created successfully!';
PRINT 'Use sp_DailySalesSummary, sp_CustomerLoyaltyReport, sp_InventoryReorderAlert, sp_StaffPerformance, sp_MonthlyTrends, sp_MenuProfitability for insights.';
GO