-- Check missing values
SELECT COUNT(*) AS 'Missing Values'
FROM online_retail
WHERE InvoiceNo IS NULL OR StockCode IS NULL OR Description IS NULL OR Quantity IS NULL OR InvoiceDate IS NULL OR UnitPrice IS NULL OR CustomerID IS NULL OR Country IS NULL OR Revenue IS NULL;

-- Remove duplicate records
SELECT DISTINCT * 
FROM online_retail;

-- Calculate total revenue by country
SELECT Country, SUM(Revenue) AS 'Total Revenue'
FROM online_retail
GROUP BY Country;

-- Find top 10 most popular products by quantity sold
SELECT Description, SUM(Quantity) AS 'Total Quantity Sold'
FROM online_retail
GROUP BY Description
ORDER BY SUM(Quantity) DESC
LIMIT 10;

-- Identify the top 10 customers with the highest spending
SELECT CustomerID, SUM(Revenue) AS 'Total Spending'
FROM online_retail
GROUP BY CustomerID
ORDER BY SUM(Revenue) DESC
LIMIT 10;

-- Get average unit price for each product
SELECT Description, AVG(UnitPrice) AS 'Avg Unit Price'
FROM online_retail
GROUP BY Description;

-- Find the most expensive products
SELECT Description, UnitPrice
FROM online_retail
ORDER BY UnitPrice DESC
LIMIT 10;

-- Get total revenue by month and year
SELECT YEAR(InvoiceDate) AS 'Year', MONTH(InvoiceDate) AS 'Month', SUM(Revenue) AS 'Total Revenue'
FROM online_retail
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY YEAR(InvoiceDate) DESC, MONTH(InvoiceDate) DESC;

-- Calculate average revenue per customer: 
SELECT AVG(Revenue) AS 'Average Revenue per Customer'
FROM (
    SELECT CustomerID, SUM(Revenue) AS 'Revenue'
    FROM online_retail
    GROUP BY CustomerID
) AS temp;

-- Find the most popular product categories: 
SELECT SUBSTRING(StockCode, 1, 2) AS 'Category', SUM(Quantity) AS 'Total Quantity Sold'
FROM online_retail
GROUP BY Category
ORDER BY SUM(Quantity) DESC;