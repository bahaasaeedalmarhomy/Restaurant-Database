USE master;
GO

-- 1. Kick everyone else off by setting the DB to Single User mode
-- WITH ROLLBACK IMMEDIATE kills open transactions instantly
ALTER DATABASE RestaurantDB 
SET SINGLE_USER 
WITH ROLLBACK IMMEDIATE;
GO

-- 2. Drop the database
DROP DATABASE RestaurantDB;
GO