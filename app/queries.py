"""
SQL Analytics Queries for Restaurant Database
"""

QUERIES = {
    "top_menu_items_daily": {
        "name": "Top 5 Menu Items (Daily)",
        "description": "Shows the top 5 selling menu items for a specific date with revenue",
        "query": """
            SELECT TOP 5
                mi.Name AS MenuItem,
                COUNT(*) AS OrderCount,
                SUM(oi.Quantity) AS TotalQuantity,
                SUM(oi.Quantity * oi.PriceAtPurchase) AS Revenue
            FROM ORDERITEMS oi
            JOIN ORDERS o ON oi.OrderID = o.OrderID
            JOIN MENUITEMS mi ON oi.MenuItemID = mi.MenuItemID
            WHERE CAST(o.OrderDateTime AS DATE) = :date
                AND o.PaymentStatus = 'Paid'
            GROUP BY mi.Name
            ORDER BY Revenue DESC
        """,
        "params": ["date"]
    },
    
    "menu_item_performance": {
        "name": "Menu Item Performance",
        "description": "Complete performance breakdown of all menu items by category",
        "query": """
            SELECT 
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
            WHERE o.PaymentStatus = 'Paid'
            GROUP BY mi.MenuItemID, mi.Name, mc.Name
            ORDER BY TotalRevenue DESC
        """,
        "params": []
    },
    
    "customer_loyalty": {
        "name": "Customer Loyalty Analysis",
        "description": "Customer segmentation based on order history and spending",
        "query": """
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
            HAVING COUNT(o.OrderID) >= 5
            ORDER BY TotalSpent DESC
        """,
        "params": []
    },
    
    "staff_performance": {
        "name": "Staff Performance",
        "description": "Sales and order metrics for each staff member",
        "query": """
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
                AND o.PaymentStatus = 'Paid'
            GROUP BY s.StaffID, s.FirstName, s.LastName, r.RoleName
            ORDER BY TotalSales DESC
        """,
        "params": []
    },
    
    "monthly_trends": {
        "name": "Monthly Revenue Trends",
        "description": "Revenue and order breakdown by month for a given year",
        "query": """
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
            WHERE YEAR(OrderDateTime) = :year
                AND PaymentStatus = 'Paid'
            GROUP BY MONTH(OrderDateTime), DATENAME(MONTH, OrderDateTime)
            ORDER BY MONTH(OrderDateTime)
        """,
        "params": ["year"]
    },
    
    "profit_analysis": {
        "name": "Menu Item Profit Analysis",
        "description": "Profit margins and cost analysis for each menu item",
        "query": """
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
            ORDER BY TotalProfit DESC
        """,
        "params": []
    },
    
    "hourly_orders": {
        "name": "Hourly Order Distribution",
        "description": "Order count and revenue by hour for a specific date",
        "query": """
            SELECT 
                DATEPART(HOUR, OrderDateTime) AS Hour,
                COUNT(*) AS OrderCount,
                SUM(TotalAmount) AS Revenue
            FROM ORDERS
            WHERE CAST(OrderDateTime AS DATE) = :date
                AND PaymentStatus = 'Paid'
            GROUP BY DATEPART(HOUR, OrderDateTime)
            ORDER BY Hour
        """,
        "params": ["date"]
    },
    
    "weekday_analysis": {
        "name": "Day of Week Analysis",
        "description": "Order patterns and revenue by day of the week",
        "query": """
            SELECT 
                DATENAME(WEEKDAY, OrderDateTime) AS DayOfWeek,
                DATEPART(WEEKDAY, OrderDateTime) AS DayNumber,
                COUNT(OrderID) AS TotalOrders,
                SUM(TotalAmount) AS TotalRevenue,
                AVG(TotalAmount) AS AvgOrderValue
            FROM ORDERS
            WHERE PaymentStatus = 'Paid'
            GROUP BY DATENAME(WEEKDAY, OrderDateTime), DATEPART(WEEKDAY, OrderDateTime)
            ORDER BY DayNumber
        """,
        "params": []
    },
    
    "table_utilization": {
        "name": "Table Utilization",
        "description": "Reservation statistics and utilization rate per table",
        "query": """
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
            GROUP BY t.TableNumber, t.Capacity
        """,
        "params": []
    },
    
    "customer_retention": {
        "name": "Customer Retention Rate",
        "description": "Monthly customer retention metrics",
        "query": """
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
                AND (mc2.Year * 12 + mc2.Month) = (mc1.Year * 12 + mc1.Month + 1)
            GROUP BY mc1.Year, mc1.Month
            ORDER BY mc1.Year, mc1.Month
        """,
        "params": []
    }
}
