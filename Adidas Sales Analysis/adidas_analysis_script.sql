-- ----------------------------------- ADIDAS SALES ANALYSIS -----------------------------------
-- 1.) DUPLICATE DATASET 
-- 2.) FIX Retail Name
-- 3.) FIX DATE FORMAT
-- 4.) FIX PRODUCT - Men's "aparel" to Men's Apparel
-- 5.) Determine the 0 value in price per unit && find why there is 0 in total sales, operating profit
-- 6.) CHANGED DATA TYPES OF DATE, TEXT TO VARCHAR
-- 7.) CLEAN THE OUTLIERS such as NEGATIVE Values
-- 8.) ADD COLUMN "Operating Margin" = (operating profit/price per unit) x 100
-- 9.) ANSWER EVERY QUESTION FOR ANALYSIS


-- ----------------------------------- START -----------------------------------

SELECT @@sql_mode;
SET sql_mode = '';

-- ----------------------------------- 1.) DUPLICATE DATASET -----------------------------------

USE adidas_analysis;
SELECT * FROM adidas_sales;


CREATE TABLE adidas_dt_dupli LIKE adidas_sales;
INSERT adidas_dt_dupli SELECT * FROM adidas_sales;

SELECT * FROM adidas_dt_dupli;


-- ----------------------------------- 2.) FIX Retail Name -----------------------------------

SELECT DISTINCT(ï»¿Retailer) FROM adidas_dt_dupli;

ALTER TABLE adidas_dt_dupli
CHANGE COLUMN ï»¿Retailer Retailer VARCHAR(50);


-- ----------------------------------- 3.) FIX DATE FORMAT -----------------------------------

SELECT DISTINCT(`Invoice Date`) FROM adidas_dt_dupli;

SELECT * 
FROM adidas_dt_dupli 
WHERE `Invoice Date` IS NULL OR `Invoice Date` = '';


UPDATE adidas_dt_dupli
SET `Invoice Date` = CASE
	WHEN `Invoice Date` LIKE '%/%' THEN date_format(str_to_date(`Invoice Date`, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN `Invoice Date` LIKE '%-%' THEN date_format(str_to_date(`Invoice Date`, '%m-%d-%Y'), '%Y-%m-%d')
	ELSE NULL
END;

ALTER TABLE adidas_dt_dupli
MODIFY COLUMN `Invoice Date` DATE;

-- ------------------------------------- 4.) FIX PRODUCT -----------------------------------

SELECT DISTINCT(Product) FROM adidas_dt_dupli;

SELECT * 
FROM adidas_dt_dupli 
WHERE Product = 'Men''s aparel';

UPDATE adidas_dt_dupli
SET Product = 'Men''s Apparel'
WHERE Product = 'Men''s aparel';


-- ------------------------------------- 5.) DETERMINE 0'S -----------------------------------

-- 5.) Determine the 0 value in price per unit && find why there is 0 in total sales, operating profit


SELECT DISTINCT(Units_Sold_New) FROM adidas_dt_dupli;
-- Units_Sold_New

SELECT * FROM adidas_dt_dupli WHERE Units_Sold_new = 0;

-- ------------------------------------- 6.) CHANGE DATA TYPES -----------------------------------


ALTER TABLE adidas_dt_dupli
MODIFY COLUMN `Price per Unit` VARCHAR(50);

ALTER TABLE adidas_dt_dupli
MODIFY COLUMN `Total Sales` VARCHAR(50);

ALTER TABLE adidas_dt_dupli
MODIFY COLUMN `Operating Profit` VARCHAR(50);


-- ------------------------------------- 7.) NO NEGATIVE VALUES -----------------------------------
-- -------------------------- 8.) ADD COLUMN "Operating Margin" = (operating profit/price per unit) x 100 -----------------------------------
SELECT * FROM adidas_dt_dupli;

-- Add a new column to store the operating margin
ALTER TABLE adidas_dt_dupli
ADD COLUMN Operating_Margin DECIMAL(10, 2); -- Change VARCHAR to DECIMAL for numerical operations

UPDATE adidas_dt_dupli
SET `Operating Profit` = REPLACE(REPLACE(`Operating Profit`, '$', ''), ',', ''),
    `Price per Unit` = REPLACE(REPLACE(`Price per Unit`, '$', ''), ',', ''),
    `Total Sales` = REPLACE(`Total Sales`, ',', '');


-- Update the new column with calculated values
UPDATE adidas_dt_dupli
SET Operating_Margin = 
    CASE 
        WHEN `Total Sales` = 0 THEN NULL
        ELSE (`Operating Profit` / `Total Sales`) * 100
    END;



-- ------------------------------------- ANSWER QUESTIONS -----------------------------------
SELECT * FROM adidas_dt_dupli;

-- Total Sales by Month (Area Chart):
-- Visualize the monthly distribution of total sales to identify peak periods.

SELECT 
    DATE_FORMAT(`Invoice Date`, '%Y-%m') AS Month, 
    SUM(CAST(REPLACE(REPLACE(`Total Sales`, ',', ''), '$', '') AS UNSIGNED)) AS Total_Sales
FROM adidas_dt_dupli
GROUP BY Month
ORDER BY Month;


-- Total Sales by State (Filled Map):
-- Geographically represent total sales across different states using a filled map.

SELECT 
    `State`, 
    SUM(`Total Sales`) AS Total_Sales
FROM adidas_dt_dupli
GROUP BY `State`;


-- Total Sales by Region (Donut Chart):
-- Use a donut chart to represent the contribution of different regions to total sales.

SELECT 
	Region, 
    SUM(`Total Sales`) AS Region_TS
FROM adidas_dt_dupli
GROUP BY Region;


-- Total Sales by Product (Bar Chart):
-- Analyze the sales distribution among various Adidas products using a bar chart.

SELECT
	Product,
    SUM(`Total Sales`) AS Products_TS
FROM adidas_dt_dupli
GROUP BY Product;


-- Total Sales by Retailer (Bar Chart):
-- Visualize the contribution of different retailers to total sales using a bar chart.

SELECT 
	Retailer,
    SUM(`Total Sales`) AS Retailers_TS
FROM adidas_dt_dupli
GROUP BY Retailer;


-- /////////////////////////////////////////////////////////////// TOTAL Operating Profit

SELECT SUM(`Operating Profit`) AS Operating_Profit_Total FROM adidas_dt_dupli;
SELECT * FROM your_table_name LIMIT 9641;


-- /////////////////////////////////////////////////////////////// AVERAGE Price per unit

SELECT ROUND(AVG(`Price per Unit`), 0) AS Price_per_Unit FROM adidas_dt_dupli;

SELECT ROUND(AVG(Operating_Margin), 0) AS Operating_margin FROM adidas_dt_dupli;








