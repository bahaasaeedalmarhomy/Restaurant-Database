/*
    Restaurant Analytics Testing Script
    Comprehensive examples for testing all functions, procedures, views, and triggers
*/
USE RestaurantDB;
GO

PRINT '========================================';
PRINT 'TESTING RESTAURANT ANALYTICS COMPONENTS';
PRINT '========================================';
GO

-- ============================================================================
-- SECTION 1: TESTING SCALAR FUNCTIONS
-- ============================================================================

PRINT '';
PRINT '--- Testing Scalar Functions ---';
PRINT '';

-- Test 1: Calculate revenue for a specific date range
PRINT '1. Testing fn_GetRevenue - Calculate revenue for last 30 days: ';
DECLARE @StartDate DATE = DATEADD(DAY, -30, GETDATE());
DECLARE @EndDate DATE = GETDATE();
DECLARE @Revenue DECIMAL(12,2);

SELECT @Revenue = dbo.fn_GetRevenue(@StartDate, @EndDate);
PRINT 'Revenue for last 30 days: $' + CAST(@Revenue AS VARCHAR(20));

-- Alternative:  Show in result set
SELECT 
    'Last 30 Days' AS Period,
    @StartDate AS StartDate,
    @EndDate AS EndDate,
    dbo.fn_GetRevenue(@StartDate, @EndDate) AS TotalRevenue;
GO

-- Test 2: Calculate revenue for specific months
PRINT '';
PRINT '2. Testing fn_GetRevenue - Compare revenue across different months:';
SELECT 
    DATENAME(MONTH, DATEADD(MONTH, -n. Number, GETDATE())) AS Month,
    DATEADD(MONTH, -n. Number, DATEADD(DAY, -DAY(GETDATE())+1, GETDATE())) AS StartDate,
    EOMONTH(DATEADD(MONTH, -n.Number, GETDATE())) AS EndDate,
    dbo.fn_GetRevenue(
        DATEADD(MONTH, -n.Number, DATEADD(DAY, -DAY(GETDATE())+1, GETDATE())),
        EOMONTH(DATEADD(MONTH, -n.Number, GETDATE()))
    ) AS MonthlyRevenue
FROM (SELECT 0 AS Number UNION SELECT 1 UNION SELECT 2 UNION SELECT 3) n
ORDER BY StartDate DESC;
GO

-- Test 3: Customer lifetime value
PRINT '';
PRINT '3. Testing fn_CustomerLifetimeValue - Top 10 customers by lifetime value: ';
SELECT TOP 10
    c.CustomerID,
    c. FirstName + ' ' + c. LastName AS CustomerName,
    c.Email,
    dbo. fn_CustomerLifetimeValue(c.CustomerID) AS LifetimeValue,
    (SELECT COUNT(*) FROM ORDERS WHERE CustomerID = c.CustomerID AND PaymentStatus = 'Paid') AS TotalOrders
FROM CUSTOMERS c
ORDER BY dbo.fn_CustomerLifetimeValue(c.CustomerID) DESC;
GO

-- Test 4: Test CLV for a specific customer
PRINT '';
PRINT '4. Testing fn_CustomerLifetimeValue - Specific customer analysis:';
DECLARE @TestCustomerID INT = (SELECT TOP 1 CustomerID FROM CUSTOMERS ORDER BY CustomerID);
SELECT 
    @TestCustomerID AS CustomerID,
    dbo.fn_CustomerLifetimeValue(@TestCustomerID) AS LifetimeValue,
    (SELECT COUNT(*) FROM ORDERS WHERE CustomerID = @TestCustomerID) AS TotalOrders,
    (SELECT MAX(OrderDateTime) FROM ORDERS WHERE CustomerID = @TestCustomerID) AS LastOrderDate;
GO

-- Test 5: Inventory efficiency
PRINT '';
PRINT '5. Testing fn_InventoryEfficiency - Inventory item performance:';
SELECT TOP 10
    ii. InventoryID,
    ii. Name AS ItemName,
    ii. Quantity AS CurrentStock,
    ii.Unit,
    dbo.fn_InventoryEfficiency(ii. InventoryID) AS RevenuePerUnit,
    CASE 
        WHEN dbo.fn_InventoryEfficiency(ii.InventoryID) > 100 THEN 'Excellent'
        WHEN dbo.fn_InventoryEfficiency(ii.InventoryID) > 50 THEN 'Good'
        WHEN dbo.fn_InventoryEfficiency(ii. InventoryID) > 20 THEN 'Average'
        ELSE 'Poor'
    END AS EfficiencyRating
FROM INVENTORYITEMS ii
WHERE EXISTS (
    SELECT 1 FROM RECIPE_INGREDIENTS WHERE InventoryID = ii. InventoryID
)
ORDER BY dbo.fn_InventoryEfficiency(ii. InventoryID) DESC;
GO

-- ============================================================================
-- SECTION 2: TESTING TABLE-VALUED FUNCTIONS
-- ============================================================================

PRINT '';
PRINT '--- Testing Table-Valued Functions ---';
PRINT '';

-- Test 6: Top menu items for last 30 days
PRINT '6. Testing fn_TopMenuItems - Top 10 menu items in last 30 days:';
SELECT * FROM dbo.fn_TopMenuItems(DATEADD(DAY, -30, GETDATE()), GETDATE(), 10);
GO

-- Test 7: Top menu items for different periods
PRINT '';
PRINT '7. Testing fn_TopMenuItems - Compare top 5 items across different periods:';
PRINT 'Last 7 days: ';
SELECT * FROM dbo.fn_TopMenuItems(DATEADD(DAY, -7, GETDATE()), GETDATE(), 5);

PRINT '';
PRINT 'Last 30 days:';
SELECT * FROM dbo.fn_TopMenuItems(DATEADD(DAY, -30, GETDATE()), GETDATE(), 5);

PRINT '';
PRINT 'Last 90 days:';
SELECT * FROM dbo.fn_TopMenuItems(DATEADD(DAY, -90, GETDATE()), GETDATE(), 5);
GO

-- Test 8: Hourly sales distribution
PRINT '';
PRINT '8. Testing fn_HourlySales - Sales distribution by hour for today:';
SELECT 
    HourOfDay,
    CASE 
        WHEN HourOfDay < 12 THEN CAST(HourOfDay AS VARCHAR) + ' AM'
        WHEN HourOfDay = 12 THEN '12 PM'
        WHEN HourOfDay < 24 THEN CAST(HourOfDay - 12 AS VARCHAR) + ' PM'
    END AS TimeDisplay,
    OrderCount,
    TotalRevenue,
    AvgOrderValue,
    CASE 
        WHEN OrderCount >= 20 THEN 'Peak Hour'
        WHEN OrderCount >= 10 THEN 'Busy'
        WHEN OrderCount >= 5 THEN 'Moderate'
        ELSE 'Slow'
    END AS ActivityLevel
FROM dbo.fn_HourlySales(CAST(GETDATE() AS DATE))
ORDER BY HourOfDay;
GO

-- Test 9: Hourly sales for yesterday
PRINT '';
PRINT '9. Testing fn_HourlySales - Yesterday''s hourly distribution:';
SELECT * FROM dbo.fn_HourlySales(DATEADD(DAY, -1, CAST(GETDATE() AS DATE)))
ORDER BY HourOfDay;
GO

-- ============================================================================
-- SECTION 3: TESTING STORED PROCEDURES
-- ============================================================================

PRINT '';
PRINT '--- Testing Stored Procedures ---';
PRINT '';

-- Test 10: Daily sales summary for today
PRINT '10. Testing sp_DailySalesSummary - Today''s summary:';
EXEC sp_DailySalesSummary;
GO

-- Test 11: Daily sales summary for specific date
PRINT '';
PRINT '11. Testing sp_DailySalesSummary - Specific date:';
EXEC sp_DailySalesSummary @ReportDate = '2024-01-15';
GO

-- Test 12: Daily sales summary for yesterday
PRINT '';
PRINT '12. Testing sp_DailySalesSummary - Yesterday: ';
EXEC sp_DailySalesSummary @ReportDate = NULL; -- Uses today by default
GO

-- Test 13: Customer loyalty report - default (min 5 orders)
PRINT '';
PRINT '13. Testing sp_CustomerLoyaltyReport - Customers with 5+ orders:';
EXEC sp_CustomerLoyaltyReport;
GO

-- Test 14: Customer loyalty report - VIP customers only
PRINT '';
PRINT '14. Testing sp_CustomerLoyaltyReport - VIP customers (20+ orders):';
EXEC sp_CustomerLoyaltyReport @MinOrders = 20;
GO

-- Test 15: Customer loyalty report - all customers
PRINT '';
PRINT '15. Testing sp_CustomerLoyaltyReport - All customers with orders:';
EXEC sp_CustomerLoyaltyReport @MinOrders = 1;
GO

-- Test 16: Inventory reorder alerts
PRINT '';
PRINT '16. Testing sp_InventoryReorderAlert - Items needing reorder:';
EXEC sp_InventoryReorderAlert;
GO

-- Test 17: Staff performance - last 30 days
PRINT '';
PRINT '17. Testing sp_StaffPerformance - Last 30 days:';
EXEC sp_StaffPerformance 
    @StartDate = DATEADD(DAY, -30, GETDATE()),
    @EndDate = GETDATE();
GO

-- Test 18: Staff performance - specific month
PRINT '';
PRINT '18. Testing sp_StaffPerformance - January 2024:';
EXEC sp_StaffPerformance 
    @StartDate = '2024-01-01',
    @EndDate = '2024-01-31';
GO

-- Test 19: Monthly trends for current year
PRINT '';
PRINT '19. Testing sp_MonthlyTrends - Current year: ';
EXEC sp_MonthlyTrends @Year = YEAR(GETDATE());
GO

-- Test 20: Monthly trends for previous year
PRINT '';
PRINT '20. Testing sp_MonthlyTrends - Previous year: ';
EXEC sp_MonthlyTrends @Year = YEAR(GETDATE()) - 1;
GO

-- Test 21: Menu profitability analysis
PRINT '';
PRINT '21. Testing sp_MenuProfitability - Full analysis:';
EXEC sp_MenuProfitability;
GO

-- Test 22: Menu profitability - filtered for high-profit items
PRINT '';
PRINT '22. Menu profitability - Top 10 most profitable items:';
CREATE TABLE #TempProfit (
    MenuItemID INT,
    MenuItem VARCHAR(100),
    CurrentPrice DECIMAL(10,2),
    EstimatedCost DECIMAL(10,2),
    ProfitPerUnit DECIMAL(10,2),
    ProfitMargin DECIMAL(5,2),
    TimesSold INT,
    TotalQuantitySold INT,
    TotalRevenue DECIMAL(12,2),
    TotalProfit DECIMAL(12,2)
);

INSERT INTO #TempProfit
EXEC sp_MenuProfitability;

SELECT TOP 10 * FROM #TempProfit
ORDER BY TotalProfit DESC;

DROP TABLE #TempProfit;
GO

-- ============================================================================
-- SECTION 4: TESTING VIEWS
-- ============================================================================

PRINT '';
PRINT '--- Testing Analytical Views ---';
PRINT '';

-- Test 23: Revenue by day of week
PRINT '23. Testing vw_RevenueByDayOfWeek: ';
SELECT * FROM vw_RevenueByDayOfWeek
ORDER BY DayNumber;
GO

-- Test 24: Customer retention analysis
PRINT '';
PRINT '24. Testing vw_CustomerRetention - Last 6 months:';
SELECT TOP 6 * FROM vw_CustomerRetention
ORDER BY Year DESC, Month DESC;
GO

-- Test 25: Table utilization
PRINT '';
PRINT '25. Testing vw_TableUtilization - All tables:';
SELECT * FROM vw_TableUtilization
ORDER BY TotalReservations DESC;
GO

-- Test 26: Supply cost trends
PRINT '';
PRINT '26. Testing vw_SupplyCostTrends - Last 6 months:';
SELECT TOP 6 * FROM vw_SupplyCostTrends
ORDER BY Year DESC, Month DESC;
GO

-- ============================================================================
-- SECTION 5: TESTING TRIGGERS
-- ============================================================================

PRINT '';
PRINT '--- Testing Triggers ---';
PRINT '';

-- Test 27: Test order total update trigger
PRINT '27. Testing trg_UpdateOrderTotal: ';
PRINT 'Creating a test order and adding items... ';

-- Get test data
DECLARE @TestOrderID INT;
DECLARE @TestMenuItemID INT;
DECLARE @TestCustomerID INT;
DECLARE @TestTableID INT;
DECLARE @TestStaffID INT;

SELECT TOP 1 @TestMenuItemID = MenuItemID FROM MENUITEMS;
SELECT TOP 1 @TestCustomerID = CustomerID FROM CUSTOMERS;
SELECT TOP 1 @TestTableID = TableID FROM TABLES;
SELECT TOP 1 @TestStaffID = StaffID FROM STAFF;

-- Create test order
INSERT INTO ORDERS (CustomerID, TableID, StaffID, OrderDateTime, OrderType, PaymentStatus, TotalAmount)
VALUES (@TestCustomerID, @TestTableID, @TestStaffID, GETDATE(), 'Dine-In', 'Pending', 0);

SET @TestOrderID = SCOPE_IDENTITY();

PRINT 'Test Order ID: ' + CAST(@TestOrderID AS VARCHAR);
PRINT 'Initial Total: $0. 00';

-- Add first item
INSERT INTO ORDERITEMS (OrderID, MenuItemID, Quantity, PriceAtPurchase)
SELECT @TestOrderID, MenuItemID, 2, Price
FROM MENUITEMS
WHERE MenuItemID = @TestMenuItemID;

SELECT 
    'After adding 2 items' AS Action,
    TotalAmount AS OrderTotal
FROM ORDERS WHERE OrderID = @TestOrderID;

-- Add second item
INSERT INTO ORDERITEMS (OrderID, MenuItemID, Quantity, PriceAtPurchase)
SELECT TOP 1 @TestOrderID, MenuItemID, 1, Price
FROM MENUITEMS
WHERE MenuItemID != @TestMenuItemID;

SELECT 
    'After adding 1 more item' AS Action,
    TotalAmount AS OrderTotal
FROM ORDERS WHERE OrderID = @TestOrderID;

-- Update quantity
UPDATE ORDERITEMS
SET Quantity = 3
WHERE OrderID = @TestOrderID
AND MenuItemID = @TestMenuItemID;

SELECT 
    'After updating quantity' AS Action,
    TotalAmount AS OrderTotal
FROM ORDERS WHERE OrderID = @TestOrderID;

-- Delete an item
DELETE FROM ORDERITEMS
WHERE OrderID = @TestOrderID
AND MenuItemID = @TestMenuItemID;

SELECT 
    'After deleting an item' AS Action,
    TotalAmount AS OrderTotal
FROM ORDERS WHERE OrderID = @TestOrderID;

PRINT 'Trigger test complete!  Order total updated automatically.';
GO

-- Test 28: Test low inventory alert trigger
PRINT '';
PRINT '28. Testing trg_LowInventoryAlert:';
PRINT 'Before test - Current alerts: ';
SELECT COUNT(*) AS AlertCount FROM InventoryAlerts;

-- Update an inventory item to trigger alert
DECLARE @TestInventoryID INT;
DECLARE @OriginalQty INT;
DECLARE @ReorderLvl INT;

SELECT TOP 1 
    @TestInventoryID = InventoryID,
    @OriginalQty = Quantity,
    @ReorderLvl = ReorderLevel
FROM INVENTORYITEMS
WHERE Quantity > ReorderLevel;

IF @TestInventoryID IS NOT NULL
BEGIN
    PRINT 'Testing with InventoryID: ' + CAST(@TestInventoryID AS VARCHAR);
    PRINT 'Original Quantity: ' + CAST(@OriginalQty AS VARCHAR);
    PRINT 'Reorder Level: ' + CAST(@ReorderLvl AS VARCHAR);
    
    -- Reduce quantity below reorder level
    UPDATE INVENTORYITEMS
    SET Quantity = @ReorderLvl - 5
    WHERE InventoryID = @TestInventoryID;
    
    PRINT 'After update - New alerts:';
    SELECT TOP 5 * FROM InventoryAlerts
    ORDER BY AlertDateTime DESC;
    
    -- Restore original quantity
    UPDATE INVENTORYITEMS
    SET Quantity = @OriginalQty
    WHERE InventoryID = @TestInventoryID;
    
    PRINT 'Inventory restored to original quantity. ';
END
ELSE
BEGIN
    PRINT 'No suitable inventory item found for testing.';
END
GO

-- ============================================================================
-- SECTION 6: ADVANCED ANALYTICAL QUERIES
-- ============================================================================

PRINT '';
PRINT '--- Advanced Analytics Examples ---';
PRINT '';

-- Test 29: Revenue trends with year-over-year comparison
PRINT '29. Year-over-year revenue comparison:';
WITH MonthlyRevenue AS (
    SELECT 
        YEAR(OrderDateTime) AS Year,
        MONTH(OrderDateTime) AS Month,
        SUM(TotalAmount) AS Revenue
    FROM ORDERS
    WHERE PaymentStatus = 'Paid'
    GROUP BY YEAR(OrderDateTime), MONTH(OrderDateTime)
)
SELECT 
    curr.Month,
    DATENAME(MONTH, DATEFROMPARTS(2024, curr.Month, 1)) AS MonthName,
    curr.Revenue AS CurrentYearRevenue,
    prev. Revenue AS PreviousYearRevenue,
    curr.Revenue - ISNULL(prev.Revenue, 0) AS Difference,
    CASE 
        WHEN prev.Revenue IS NULL THEN 0
        ELSE CAST((curr.Revenue - prev.Revenue) / prev.Revenue * 100 AS DECIMAL(10,2))
    END AS PercentageChange
FROM MonthlyRevenue curr
LEFT JOIN MonthlyRevenue prev 
    ON curr.Month = prev.Month 
    AND curr.Year = prev.Year + 1
WHERE curr.Year = YEAR(GETDATE())
ORDER BY curr.Month;
GO

-- Test 30: Customer segmentation analysis
PRINT '';
PRINT '30. Customer segmentation by spending: ';
WITH CustomerStats AS (
    SELECT 
        c.CustomerID,
        c. FirstName + ' ' + c.LastName AS CustomerName,
        COUNT(o.OrderID) AS OrderCount,
        SUM(o.TotalAmount) AS TotalSpent,
        AVG(o.TotalAmount) AS AvgOrderValue,
        DATEDIFF(DAY, MIN(o.OrderDateTime), MAX(o.OrderDateTime)) AS DaysSinceFirst
    FROM CUSTOMERS c
    JOIN ORDERS o ON c.CustomerID = o.CustomerID
    WHERE o.PaymentStatus = 'Paid'
    GROUP BY c.CustomerID, c.FirstName, c.LastName
)
SELECT 
    CASE 
        WHEN TotalSpent >= 1000 THEN 'High Value'
        WHEN TotalSpent >= 500 THEN 'Medium Value'
        WHEN TotalSpent >= 100 THEN 'Low Value'
        ELSE 'Minimal'
    END AS CustomerSegment,
    COUNT(*) AS CustomerCount,
    AVG(TotalSpent) AS AvgLifetimeValue,
    AVG(OrderCount) AS AvgOrders,
    AVG(AvgOrderValue) AS AvgOrderValue,
    SUM(TotalSpent) AS TotalRevenue
FROM CustomerStats
GROUP BY 
    CASE 
        WHEN TotalSpent >= 1000 THEN 'High Value'
        WHEN TotalSpent >= 500 THEN 'Medium Value'
        WHEN TotalSpent >= 100 THEN 'Low Value'
        ELSE 'Minimal'
    END
ORDER BY TotalRevenue DESC;
GO

-- Test 31: Peak hours and staffing recommendations
PRINT '';
PRINT '31. Peak hours analysis with staffing recommendations:';
WITH HourlyStats AS (
    SELECT 
        DATEPART(HOUR, OrderDateTime) AS Hour,
        COUNT(*) AS OrderCount,
        SUM(TotalAmount) AS Revenue,
        COUNT(DISTINCT StaffID) AS StaffCount
    FROM ORDERS
    WHERE PaymentStatus = 'Paid'
        AND OrderDateTime >= DATEADD(DAY, -30, GETDATE())
    GROUP BY DATEPART(HOUR, OrderDateTime)
)
SELECT 
    Hour,
    CASE 
        WHEN Hour < 12 THEN CAST(Hour AS VARCHAR) + ' AM'
        WHEN Hour = 12 THEN '12 PM'
        ELSE CAST(Hour - 12 AS VARCHAR) + ' PM'
    END AS TimeDisplay,
    OrderCount,
    CAST(Revenue AS DECIMAL(10,2)) AS Revenue,
    StaffCount AS CurrentStaff,
    CASE 
        WHEN OrderCount >= 30 THEN CEILING(OrderCount / 10. 0)
        WHEN OrderCount >= 20 THEN CEILING(OrderCount / 12.0)
        WHEN OrderCount >= 10 THEN CEILING(OrderCount / 15.0)
        ELSE 2
    END AS RecommendedStaff,
    CASE 
        WHEN OrderCount >= 30 THEN 'Peak - Need More Staff'
        WHEN OrderCount >= 20 THEN 'Busy - Monitor Staffing'
        WHEN OrderCount >= 10 THEN 'Moderate - Adequate'
        ELSE 'Slow - Can Reduce Staff'
    END AS StaffingRecommendation
FROM HourlyStats
ORDER BY Hour;
GO

-- Test 32: Menu item combination analysis
PRINT '';
PRINT '32. Popular menu item combinations (items ordered together):';
SELECT TOP 10
    mi1.Name AS Item1,
    mi2.Name AS Item2,
    COUNT(*) AS TimesOrderedTogether,
    AVG(o.TotalAmount) AS AvgOrderValue
FROM ORDERITEMS oi1
JOIN ORDERITEMS oi2 ON oi1.OrderID = oi2.OrderID AND oi1.MenuItemID < oi2.MenuItemID
JOIN MENUITEMS mi1 ON oi1.MenuItemID = mi1.MenuItemID
JOIN MENUITEMS mi2 ON oi2.MenuItemID = mi2.MenuItemID
JOIN ORDERS o ON oi1.OrderID = o.OrderID
WHERE o.PaymentStatus = 'Paid'
GROUP BY mi1.Name, mi2.Name
ORDER BY TimesOrderedTogether DESC;
GO

-- Test 33: Supplier performance analysis
PRINT '';
PRINT '33. Supplier performance analysis:';
SELECT 
    s.Name AS Supplier,
    s.ContactName,
    COUNT(DISTINCT so. SupplyOrderID) AS TotalOrders,
    SUM(so.TotalCost) AS TotalSpent,
    AVG(so.TotalCost) AS AvgOrderCost,
    MIN(so.OrderDate) AS FirstOrder,
    MAX(so.OrderDate) AS LastOrder,
    DATEDIFF(DAY, MAX(so.OrderDate), GETDATE()) AS DaysSinceLastOrder,
    CASE 
        WHEN DATEDIFF(DAY, MAX(so.OrderDate), GETDATE()) <= 7 THEN 'Active'
        WHEN DATEDIFF(DAY, MAX(so.OrderDate), GETDATE()) <= 30 THEN 'Recent'
        WHEN DATEDIFF(DAY, MAX(so.OrderDate), GETDATE()) <= 90 THEN 'Occasional'
        ELSE 'Inactive'
    END AS SupplierStatus
FROM SUPPLIERS s
LEFT JOIN SUPPLYORDERS so ON s.SupplierID = so.SupplierID
GROUP BY s. SupplierID, s.Name, s.ContactName
ORDER BY TotalSpent DESC;
GO

-- ============================================================================
-- SECTION 7: COMPREHENSIVE DASHBOARD QUERY
-- ============================================================================

PRINT '';
PRINT '--- Executive Dashboard Summary ---';
PRINT '';

-- Test 34: Complete business metrics dashboard
PRINT '34. Executive dashboard - Key business metrics:';

-- Overall metrics
SELECT 'OVERALL BUSINESS METRICS' AS Section;
SELECT 
    'Today' AS Period,
    COUNT(DISTINCT OrderID) AS TotalOrders,
    CAST(SUM(TotalAmount) AS DECIMAL(12,2)) AS TotalRevenue,
    CAST(AVG(TotalAmount) AS DECIMAL(10,2)) AS AvgOrderValue,
    COUNT(DISTINCT CustomerID) AS UniqueCustomers
FROM ORDERS
WHERE CAST(OrderDateTime AS DATE) = CAST(GETDATE() AS DATE)
    AND PaymentStatus = 'Paid';

-- This week vs last week
SELECT 'WEEKLY COMPARISON' AS Section;
WITH WeeklyStats AS (
    SELECT 
        CASE 
            WHEN OrderDateTime >= DATEADD(WEEK, DATEDIFF(WEEK, 0, GETDATE()), 0) THEN 'This Week'
            WHEN OrderDateTime >= DATEADD(WEEK, DATEDIFF(WEEK, 0, GETDATE()) - 1, 0) 
                AND OrderDateTime < DATEADD(WEEK, DATEDIFF(WEEK, 0, GETDATE()), 0) THEN 'Last Week'
            ELSE 'Other'
        END AS Period,
        COUNT(OrderID) AS Orders,
        SUM(TotalAmount) AS Revenue
    FROM ORDERS
    WHERE PaymentStatus = 'Paid'
        AND OrderDateTime >= DATEADD(WEEK, DATEDIFF(WEEK, 0, GETDATE()) - 1, 0)
    GROUP BY 
        CASE 
            WHEN OrderDateTime >= DATEADD(WEEK, DATEDIFF(WEEK, 0, GETDATE()), 0) THEN 'This Week'
            WHEN OrderDateTime >= DATEADD(WEEK, DATEDIFF(WEEK, 0, GETDATE()) - 1, 0) 
                AND OrderDateTime < DATEADD(WEEK, DATEDIFF(WEEK, 0, GETDATE()), 0) THEN 'Last Week'
            ELSE 'Other'
        END
)
SELECT 
    Period,
    Orders,
    CAST(Revenue AS DECIMAL(12,2)) AS Revenue,
    CAST(Revenue / NULLIF(Orders, 0) AS DECIMAL(10,2)) AS AvgOrderValue
FROM WeeklyStats
WHERE Period IN ('This Week', 'Last Week')
ORDER BY Period DESC;

-- Top performing items
SELECT 'TOP 5 MENU ITEMS (LAST 7 DAYS)' AS Section;
SELECT * FROM dbo.fn_TopMenuItems(DATEADD(DAY, -7, GETDATE()), GETDATE(), 5);

-- Inventory alerts
SELECT 'INVENTORY ALERTS' AS Section;
SELECT TOP 5
    Name AS Item,
    Quantity AS Stock,
    ReorderLevel,
    Unit,
    CASE 
        WHEN Quantity = 0 THEN 'OUT OF STOCK'
        WHEN Quantity < ReorderLevel * 0.5 THEN 'CRITICAL'
        ELSE 'LOW'
    END AS Status
FROM INVENTORYITEMS
WHERE Quantity <= ReorderLevel
ORDER BY Quantity;

-- Customer insights
SELECT 'CUSTOMER INSIGHTS' AS Section;
SELECT 
    COUNT(DISTINCT c.CustomerID) AS TotalCustomers,
    COUNT(DISTINCT CASE WHEN o.OrderDateTime >= DATEADD(DAY, -30, GETDATE()) 
        THEN o.CustomerID END) AS ActiveLast30Days,
    AVG(dbo.fn_CustomerLifetimeValue(c.CustomerID)) AS AvgLifetimeValue
FROM CUSTOMERS c
LEFT JOIN ORDERS o ON c.CustomerID = o.CustomerID AND o.PaymentStatus = 'Paid';

PRINT '';
PRINT '========================================';
PRINT 'ALL TESTS COMPLETED SUCCESSFULLY!';
PRINT '========================================';
GO

-- ============================================================================
-- SECTION 8: CLEANUP (OPTIONAL)
-- ============================================================================

PRINT '';
PRINT 'Cleaning up test order... ';

-- Remove test order if you want to clean up
-- DECLARE @LastTestOrderID INT = (SELECT MAX(OrderID) FROM ORDERS WHERE OrderType = 'Dine-In');
-- DELETE FROM ORDERITEMS WHERE OrderID = @LastTestOrderID;
-- DELETE FROM ORDERS WHERE OrderID = @LastTestOrderID;
-- PRINT 'Test order removed.';
GO