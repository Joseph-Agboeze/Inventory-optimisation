CREATE DATABASE tech_electro;

USE tech_electro; 

-- DATA EXPLORATION
-- MAKING USE OF MYSQL TABLE DATA IMPORT WIZARD TO IMPORT DATA AND INSPECTING THE DATA IN TABLE
SELECT * FROM external_factors;
SELECT * FROM sales_data;
SELECT * FROM product_information;

-- CHECKING THE STRUCTURE OF THE IMPORTED DATA IN TABLES TO  KNNOW IF THEY ARE IN THEIR RIGHT DATA TYPES
SHOW COLUMNS FROM external_factors;
SHOW COLUMNS FROM sales_data;
SHOW COLUMNS FROM product_information;

-- DATA CLEANING
-- CHANGING THE IMPORTED DATA IN EACH TABLES TO THEIR RIGHT DATA TYPES 

-- EXTERNAL_FACTORS TABLE
-- SalesData DATE,
-- GDP DECIMAL(10,2),
-- InflationRate DECIMAL(5,2),
-- SeasonalFactor DECIMAL (5,2)
ALTER TABLE external_factors
ADD COLUMN New_SalesDate DATE;
SET SQL_SAFE_UPDATES = 0;
UPDATE external_factors
SET New_SalesDate = STR_TO_DATE(SalesDate, "%d/%m/%Y");
ALTER TABLE external_factors
DROP COLUMN SalesDate;
ALTER TABLE external_factors
CHANGE COLUMN New_SalesDate SalesDate DATE;

-- MODIFYING GDP COLUMN TO ITS RIGHT DATA TYPES
ALTER TABLE external_factors
MODIFY COLUMN GDP DECIMAL(10,2);

-- MODIFYING INFLATION_RATE COLUMN TO ITS RIGHT DATA TYPES
ALTER TABLE external_factors
MODIFY COLUMN Inflation_Rate DECIMAL(5,2);

-- MODIFYING SEASONAL_FACTOR COLUMN TO ITS RIGHT DATA TYPES
ALTER TABLE external_factors
MODIFY COLUMN Seasonal_Factor DECIMAL(5,2);



-- PRODUCT_INFORMATION TABLE
-- PRODUCT_ID INT NOT NULL,
-- PRODUCT_CATERGORY VARCHAR(20),
-- PROMOTIONS ENUM("YES",NO)
ALTER TABLE product_information
MODIFY COLUMN Product_Category VARCHAR(20);

ALTER TABLE product_information
ADD COLUMN New_Promotions ENUM("Yes","No");
UPDATE product_information
SET New_Promotions = CASE
WHEN Promotions = "Yes" THEN "Yes"
WHEN Promotions = "No" THEN "No"
ELSE NULL
END;
ALTER TABLE product_information
DROP COLUMN Promotions;
ALTER TABLE product_information
CHANGE COLUMN New_Promotions Promotions ENUM("Yes","No");

-- SALES_DATA TABLE
-- Product_ID INT NOT NULL
-- Sales_Date DATE
-- Inventory_Quantity INT
-- Product_Cost DECIMAL (15,2)
ALTER TABLE sales_data
ADD COLUMN New_Sales_Date DATE;
SET SQL_SAFE_UPDATES = 0;
UPDATE sales_data
SET New_Sales_Date = STR_TO_DATE(Sales_Date, "%d/%m/%Y");
ALTER TABLE sales_data
DROP COLUMN Sales_Date;
ALTER TABLE sales_data
CHANGE COLUMN New_Sales_Date Sales_Date DATE;

-- MODIFYING Product_Cost COLUMN TO ITS RIGHT DATA TYPES
ALTER TABLE sales_data
MODIFY COLUMN Product_Cost DECIMAL(15,2);


-- CHECKING FOR MISSING VALUES
-- EXTERNAL_FACTORS 
SELECT 
SUM(CASE WHEN Sales_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Sales_Date,
SUM(CASE WHEN GDP IS NULL THEN 1 ELSE 0 END) AS Missing_GDP,
SUM(CASE WHEN Inflation_Rate IS NULL THEN 1 ELSE 0 END) AS Missing_Inflation_Rate,
SUM(CASE WHEN Seasonal_Factor IS NULL THEN 1 ELSE 0 END) AS Missing_Seasonal_Factor
FROM external_factors;

-- PRODUCT_INFORMATION
SELECT 
SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Product_ID,
SUM(CASE WHEN Product_Category IS NULL THEN 1 ELSE 0 END) AS Missing_Product_Category,
SUM(CASE WHEN Promotions IS NULL THEN 1 ELSE 0 END) AS Missing_Promotions
FROM product_information; 

-- SALES_DATA
SELECT 
SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Product_ID,
SUM(CASE WHEN Inventory_Quantity IS NULL THEN 1 ELSE 0 END) AS Missing_Inventory_Quantity,
SUM(CASE WHEN Product_Cost IS NULL THEN 1 ELSE 0 END) AS Missing_Product_Cost,
SUM(CASE WHEN Sales_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Sales_Date
FROM sales_data;

-- CHECKING FOR DUPLICATE VALUES AND HOW MANY DUPLICATES
-- EXTERNAL_FACTORS 
SELECT Sales_Date, COUNT(*) AS Count
FROM external_factors
GROUP BY Sales_Date
HAVING Count >1;

-- TOTAL DUPLICATE VALUES
SELECT COUNT(*) FROM (SELECT Sales_Date, COUNT(*) AS Count
FROM external_factors
GROUP BY Sales_Date
HAVING Count > 1) AS Duplicates;


-- PRODUCT_INFORMATION
SELECT Product_ID,Product_Category, COUNT(*) AS Count
FROM product_information
GROUP BY  Product_ID,Product_Category
HAVING Count > 1;

-- TOTAL DUPLICATE VALUES
SELECT COUNT(*) FROM (SELECT Product_ID, COUNT(*) AS Count
FROM product_information
GROUP BY Product_ID
HAVING Count > 1) AS Duplicates;


-- SALES-DATA
SELECT Product_ID, Sales_Date, COUNT(*) AS Count
FROM sales_data
GROUP BY Product_ID, Sales_Date
HAVING Count >1;

-- HANDLING DUPLICATES IN EXTERNAL_FACTORS AND PRODUCT_INFORMATION
-- EXTERNAL_FACTORS
--  (PERFORMING AN INNER JOIN THAT JOIN EXTERNAL_FACTORS TABLE WITH 
-- ANOTHER WHICH IS STILL UNDER EXTERNAL_FACTORS TABLE BUT WITH SEVERAL CONDITIONS)

DELETE e1 FROM external_factors e1
INNER JOIN (
 SELECT Sales_Date,
ROW_NUMBER() OVER (PARTITION BY Sales_Date ORDER BY Sales_Date) AS rn 
FROM external_factors 
) e2 ON e1.Sales_Date = e2.Sales_Date
WHERE e2.rn > 1;

-- PRODUCT_INFORMATION
DELETE p1 FROM product_information p1
INNER JOIN (
 SELECT Product_ID,
ROW_NUMBER() OVER (PARTITION BY Product_ID ORDER BY Product_ID) AS rn 
FROM product_information
) p2 ON p1.Product_ID = p2.Product_ID
WHERE p2.rn > 1;

-- DATE INTEGRATION
-- CREATE A VIEW (COMBINING SALES_DATA TABLE AND PRODUCT_INFORMATIONN TABLE FIRST)
CREATE VIEW Sales_product_data AS 
SELECT 
S.Product_ID,
S.Sales_Date,
S.Inventory_Quantity,
S.Product_Cost,
P.Product_Category,
P.Promotions
FROM Sales_Data S
JOIN Product_Information P 
ON S.Product_ID = P.Product_ID;

-- COMBINING SALES PRODUCT DATA WITH EXTERNAL FACTORS
CREATE VIEW Inventory_Data AS 
SELECT 
SP.Product_ID,
SP.Sales_Date,
SP.Inventory_Quantity,
SP.Product_Cost,
SP.Product_Category,
SP.Promotions,
E.GDP,
E.Inflation_Rate,
E.Seasonal_Factor
FROM Sales_product_data SP
LEFT JOIN external_factors E
ON SP.Sales_Date = E.Sales_Date;


-- DESCRIPTIVE ANALYSIS
-- BASIC STATISTICS
-- AVERAGE SALES (CALCULATED AS THE PRODUCT OF INVENTORY QUANTITY AND PRODUCT COST)
SELECT Product_ID, ROUND(AVG(Inventory_Quantity * Product_Cost),2) AS Avg_Sales
FROM Inventory_Data 
GROUP BY Product_ID
ORDER BY Avg_Sales DESC;


-- MEDIAN STOCK LEVELS ( INVENTORY QUANTITY)
SELECT Product_ID, AVG(Inventory_Quantity) AS Median_Stock
FROM (
SELECT Product_ID, 
Inventory_Quantity,
ROW_NUMBER() OVER(PARTITION BY  Product_ID ORDER BY Inventory_Quantity) AS Row_Number_Asc,
ROW_NUMBER() OVER(PARTITION BY  Product_ID ORDER BY Inventory_Quantity DESC) AS Row_Number_Desc
FROM Inventory_Data
) AS Subquery
WHERE Row_Number_Asc IN (Row_Number_Desc, Row_Number_Desc - 1, Row_Number_Desc + 1)
GROUP BY Product_ID;

-- PRODUCT PERFORMANCE METRICS (TOATL SALES PER PRODUCT)
SELECT Product_ID, ROUND(SUM(Inventory_Quantity * Product_Cost)) AS Total_Sales
FROM Inventory_Data 
GROUP BY Product_ID 
ORDER BY Total_Sales DESC;

-- IDENTIFYING HIGH DEMAND PRODUCTS BASED ON AVERAGE SALES 
WITH HighDemandProducts AS (
SELECT Product_ID, AVG(Inventory_Quantity) AS Avg_Sales
FROM Inventory_Data
GROUP BY Product_ID
HAVING Avg_Sales > (
SELECT AVG(Inventory_Quantity) * 0.95 FROM sales_data
)
)

-- CALCULATE STOCKOUT FREQUENCY FOR HIGHDEMANDPRODUCTS
SELECT S.Product_ID,
COUNT(*) AS Stockout_Frequency
FROM Inventory_data S
WHERE S.Product_ID IN (SELECT Product_ID FROM HighDemandProducts)
AND S.Inventory_Quantity = 0
GROUP BY S.Product_ID;

-- INFLUENCE OF EXTERNAL FACTORS
-- FOR GDP
SELECT Product_ID,
AVG(CASE WHEN "GDP" > 0 THEN Inventory_Quantity ELSE NULL END) AS Avg_sales_positve_gdp,
AVG(CASE WHEN "GDP" <= 0 THEN Inventory_Quantity ELSE NULL END) AS Avg_sales_non_positve_gdp
FROM Inventory_data
GROUP BY Product_ID
HAVING Avg_sales_positve_gdp IS NOT NULL;

-- FOR INFLATION RATE
SELECT Product_ID,
AVG(CASE WHEN "Inflation_Rate" > 0 THEN Inventory_Quantity ELSE NULL END) AS Avg_sales_positve_Inflation_Rate,
AVG(CASE WHEN "Inflation_Rate" <= 0 THEN Inventory_Quantity ELSE NULL END) AS Avg_sales_non_positve_Inflation_Rate
FROM Inventory_data
GROUP BY Product_ID
HAVING Avg_sales_positve_Inflation_Rate IS NOT NULL;

--  INVENTORY OPTIMIZATION
-- DETERMINE THE OPTIONAL REORDER POINT FOR EACH PRODUCT ON HISTORICAL SALES DATA AND EXTERNAL FACTORS.
-- REORDER POINT = LEAD TIME DEMAND + SAFETYE STOCK
-- LEAD TIMME DEMAND = ROLLING AVERAGE SALES * LEAD TIME
-- SAFETY STOCK = Z * LEAD TIME^-2 * STANDARD DEVIATION OF DEMAND	
-- Z = 1.645
-- A CONSTANT LEAD TIME OF 7 DAYS FOR ALL PRODUCTS.
-- WE AIM FOR A 95% SERVICE LEVEL.

WITH InventoryCalculation AS (
SELECT Product_ID,
AVG(rolling_avg_sales) AS avg_rolling_sales,
AVG(rolling_variance) AS avg_rolling_variance
FROM (
SELECT Product_ID,
AVG(daily_sales) OVER (PARTITION BY Product_ID ORDER BY Sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales,
AVG(squared_diff) OVER (PARTITION BY Product_ID ORDER BY Sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_variance
FROM (
SELECT Product_ID,Sales_Date, 
Inventory_Quantity * Product_Cost AS daily_sales,
(Inventory_Quantity * Product_Cost - AVG(Inventory_Quantity * Product_Cost) OVER (PARTITION BY Product_ID ORDER BY Sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) *
(Inventory_Quantity * Product_Cost - AVG(Inventory_Quantity * Product_Cost) OVER (PARTITION BY Product_ID ORDER BY Sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS squared_diff
FROM Inventory_Data
 ) subquery
  ) subquery2
    GROUP BY Product_ID
)
SELECT Product_ID,
avg_rolling_sales * 7 AS lead_time_demand,
1.645 * (avg_rolling_variance * 7) AS safety_stock,
(avg_rolling_sales * 7) + (1.645 * (avg_rolling_variance * 7)) AS reorder_point
FROM InventoryCalculation;

-- CREATE  INVENTORY OPTIMIZATION TABLE
CREATE TABLE Inventory_Optimization (
Product_ID INT,
Reorder_Point DOUBLE
);
 
--  RECALCULATE REORDER POINT BY CREATING STORE PROCEDURE
DELIMITER //
CREATE PROCEDURE RecalculateReorderPoint(IN productID INT)
BEGIN
DECLARE avg_rolling_sales DOUBLE;
DECLARE avg_rolling_variance DOUBLE;
DECLARE lead_time_demand DOUBLE;
DECLARE safety_stock DOUBLE;
DECLARE reorder_point DOUBLE;

SELECT AVG(rolling_avg_sales),AVG(rolling_variance)
INTO avg_rolling_sales,avg_rolling_variance
FROM (
SELECT Product_ID,
AVG(daily_sales) OVER (PARTITION BY Product_ID ORDER BY Sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales,
AVG(squared_diff) OVER (PARTITION BY Product_ID ORDER BY Sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_variance
FROM (
SELECT Product_ID, Sales_Date, 
Inventory_Quantity * Product_Cost AS daily_sales,
(Inventory_Quantity * Product_Cost - AVG(Inventory_Quantity * Product_Cost) OVER (PARTITION BY Product_ID ORDER BY Sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) *
(Inventory_Quantity * Product_Cost - AVG(Inventory_Quantity * Product_Cost) OVER (PARTITION BY Product_ID ORDER BY Sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS squared_diff
FROM Inventory_Date
WHERE Product_ID = productID
) AS inner_derived
 ) AS outer_derived;
SET lead_time_demand = avg_rolling_sales * 7;
SET safety_stock = 1.645 * SQRT(avg_rolling_variance * 7);
SET reorder_point = lead_time_demand + safety_stock;

INSERT INTO inventory_optimization (Product_ID, reorder_point)
VALUES (productID, reorder_point)
ON DUPLICATE KEY UPDATE reorder_point = reorder_point;
END //
DELIMITER ;

-- MAKE INVENTORY DATA A PERMANENT TABLE
CREATE TABLE Inventory_table AS SELECT * FROM Inventory_data;

-- CREATE TRIGGER
DELIMITER //
DROP TRIGGER IF EXISTS AfterInsertUnifiedTable;
CREATE TRIGGER AfterInsertUnifiedTable
AFTER INSERT ON Inventory_table
FOR EACH ROW
BEGIN
CALL RecalculateReorderPoint(NEW,Product_ID);
END//
DELIMITER ;

-- ANALYZING OVERSTOCK AND UNDERSTOCK PRODUCTS
WITH RollingSales AS (
SELECT Product_ID, 
Sales_Date,
AVG(Inventory_Quantity * Product_Cost) OVER (PARTITION BY Product_ID ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales
FROM inventory_table
),

-- CALCULATE NUMBERS OF DAYS A PRODUCT WAS OUT OF STOCK
StockoutDays AS (
SELECT Product_ID,COUNT(*) AS stockout_days
FROM inventory_table
WHERE Inventory_Quantity = 0
GROUP BY 
Product_ID)

-- JOIN THE ABOVE CTES WITH THE MAIN TABLE TO GET THE RESULT
SELECT f.Product_ID,
AVG(f.Inventory_Quantity * f.Product_Cost) AS avg_inventory_value,
AVG(rs.rolling_avg_sales) AS avg_rolling_sales,
COALESCE(sd.stockout_days, 0) AS stockout_days
FROM inventory_table f
JOIN RollingSales rs ON f.Product_ID = rs.Product_ID AND f.Sales_Date = rs.Sales_Date
LEFT JOIN StockoutDays sd ON f.Product_ID = sd.Product_ID
GROUP BY f.Product_ID, sd.stockout_days;

-- MONITOR AND ADJUST
-- MONITOR INVENTORY LEVELS
DELIMITER //
CREATE PROCEDURE MonitorInventorylevels()
BEGIN
SELECT Product_ID, Avg(Inventory_Quantity) as AvgInventory
FROM Inventory_table
GROUP BY Product_ID
ORDER BY AvgInventory desc;
END//
Delimiter ;
    
 --   MONITOR SALES TRENDS
 DELIMITER //
CREATE PROCEDURE MonitorSalesTrends()
BEGIN
SELECT Product_ID, Sales_Date,
AVG(Inventory_Quantity * Product_Cost) OVER (PARTITION BY Product_ID ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales
FROM Inventory_table
ORDER BY Product_ID, Sales_Date;
END//
Delimiter ;

 -- MONITOR STOCKOUT FREQUENCIES
DELIMITER //
CREATE PROCEDURE MonitorStockouts()
BEGIN
SELECT Product_ID, Count(*) as StockoutDays
FROM Inventory_table
WHERE Inventory_Quantity = 0
GROUP BY Product_ID
ORDER BY StockoutDays desc;
END//
Delimiter ;


    
