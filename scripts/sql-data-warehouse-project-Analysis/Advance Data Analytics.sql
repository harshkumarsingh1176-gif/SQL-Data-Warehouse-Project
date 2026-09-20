-- ====================================================================
-- Change-Over-Time: How a measure evolves over time. 
-- Helps track trends and identify seasonality in your data.
-- ====================================================================

-- Analyse sales performance over time.
SELECT
YEAR(Order_date) Order_Years,
SUM(sales_amount) Total_Sales,
COUNT(Customer_key) AS Total_Customers,
SUM(Quantity) AS Total_Quantity
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(Order_date)
ORDER BY YEAR(Order_date);

-- month
SELECT
YEAR(order_date) Order_Year,
Month(Order_date) Order_Month,
SUM(sales_amount) Total_Sales,
COUNT(Customer_key) AS Total_Customers,
SUM(Quantity) AS Total_Quantity
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY  YEAR(order_date), Month(Order_date)
ORDER BY YEAR(order_date), Month(Order_date);

-- 
SELECT
DATE_FORMAT(order_date, '%Y-%m-01') AS Order_Month,
SUM(sales_amount) Total_Sales,
COUNT(Customer_key) AS Total_Customers,
SUM(Quantity) AS Total_Quantity
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%m-01')
ORDER BY DATE_FORMAT(order_date, '%Y-%m-01');

-- ====================================================================
-- Cumlative Analysis: Aggrigate the data progressivly over the time. 
-- Helps to understand whether our business is growing or declining.
-- ====================================================================

-- Formula: 
-- Summation [cumulativeMeasure] By [Date Dimension]
-- Running Total sales By Year
-- Moving Average of sales by Month

-- Calculate the total sales per month.
-- The running total of sales over time.
SELECT  
Order_date,
Total_sales,
SUM(Total_sales) OVER(ORDER BY Order_date) AS Running_Total_sales1,
SUM(Total_sales) OVER(PARTITION BY Order_date ORDER BY Order_date) AS Running_Total_sales2,
ROUND(Avg(Avg_price) OVER(ORDER BY Order_date),0) AS Moving_Average_price
FROM (
SELECT 
DATE_FORMAT(ORDER_date, '%Y-%m-01') Order_date,
SUM(sales_amount) Total_sales,
AVG(PRICE) AS Avg_price
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(ORDER_date, '%Y-%m-01')
ORDER BY DATE_FORMAT(ORDER_date, '%Y-%m-01'))t;

-- ====================================================================
-- Performance Analysis: Comparing the current value to a taget value. 
-- Helps measure success and compare performance.
-- ====================================================================

-- Formula: 
-- Current [Measure] - Target[Measure]
-- Current sales - Average sales
-- Current year sales - Previous year sales -- YOY analysis
-- Current sales - Lowest sales
-- Current sales - Highest sales

-- Analyse the yearly performance of products.
SELECT 
YEAR(order_date) Order_Year, 
product_name,
SUM(sales_amount) Total_sales
FROM fact_sales f 
LEFT JOIN dim_products p
ON f.product_key = p.product_Key
WHERE Order_date IS NOT NULL
GROUP BY YEAR(order_date), product_name;


-- By comparing each product's sales to both Its average sales performance and the previous year's sales 
WITH Yearly_Product_sales AS (
SELECT 
YEAR(order_date) Order_Year, 
product_name,
SUM(sales_amount) Current_sales
FROM fact_sales f 
LEFT JOIN dim_products p
ON f.product_key = p.product_Key
WHERE Order_date IS NOT NULL
GROUP BY YEAR(order_date), product_name)
SELECT 
Order_year,
Product_Name,
current_sales,
ROUND(AVG(current_sales) OVER(ORDER BY product_name),0) AS Avg_sales,
Current_sales - ROUND(AVG(current_sales) OVER(ORDER BY product_name),0) AS Diff_Avg,
CASE WHEN Current_sales - ROUND(AVG(current_sales) OVER(ORDER BY product_name),0) > 0 THEN 'Above_Avg'
	 WHEN Current_sales - ROUND(AVG(current_sales) OVER(ORDER BY product_name),0) < 0 THEN 'Below_Avg'
     ELSE 'Avg'
END AS Avg_Change,
-- YEAR- OVER- YEAR ANALYSIS
LAG(Current_sales) OVER(PARTITION BY product_name ORDER BY order_year) py_sales,
current_sales - LAG(Current_sales) OVER(PARTITION BY product_name ORDER BY order_year) Diff_Py,
CASE WHEN current_sales - LAG(Current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	 WHEN current_sales - LAG(Current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
     ELSE 'No_change'
END AS Py_Change
FROM  Yearly_Product_sales
ORDER BY  product_name, order_year;

-- ====================================================================
-- PART TO WHOLE OR PROPORTIONAL ANALYSIS: Analyse how an individual part is performing in compared to the overall. 
-- Allowing us to understand which category has the greatest impact on the business.
-- ====================================================================

-- Formula: 
-- ([MEASURE]/TOTAL[MEASURE] * 100 BY [DIMENSION]
-- (SALES/ TOTAL SALES) * 1OO BY CATEGORY
-- (QUANTITY/ TOTAL QUANTITY) * 100 BY COUNTRY

-- Which category contribute the most overall sales?
WITH category_sales AS(
SELECT 
Categroy, 
SUM(sales_amount) Total_sales
FROM fact_sales f
LEFT JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY Categroy)
SELECT 
categroy,
Total_sales,
SUM(Total_sales) OVER() Overall_sales,
CONCAT(ROUND(Total_sales / SUM(Total_sales) OVER() * 100,2), '%')AS Percentage_of_Total
FROM Category_sales;

-- ====================================================================
-- DATA SAGMENTATION: Group the data based on specific range. 
-- Helps understand correlation between two measures.
-- ====================================================================

-- Formula: 
-- [MEASURE] BY [MEASURE]
-- Total products by Sales Range
-- Total Customers by Age;

-- Segment products into cost ranges and how many products fall into each segment
WITH Product_segment AS(
SELECT 
product_key,
product_Name,
cost,
CASE WHEN Cost < 500 THEN 'Below 500'
	WHEN Cost BETWEEN 500 AND 1000 THEN '500-1000'
    WHEN cost BETWEEN 1000 AND 2000 THEN '1000-2000'
    ELSE 'Above2000'
END AS Cost_range
FROM dim_products)

SELECT 
Cost_range,
COUNT(Product_key) Total_products
FROM Product_segment
GROUP BY Cost_range
ORDER BY total_products DESC;

-- Group customers into three segments based on their spending behaviour
-- VIP: Atleast 12 months of history and spending more than $5000
-- Regular: Atleast 12 months of history and spending less than $5000.alter
-- New: Lifespan less than 12 months
-- Find the total number of customers by each group.
WITH Customer_spending AS(
SELECT 
c.Customer_key,
SUM(f.sales_amount) AS Total_spending,
MAX(Order_date) AS First_order,
MIN(Order_date) AS Last_order,
TIMESTAMPDIFF(MONTH, Min(Order_date), Max(Order_date)) Lifespan
FROM fact_sales F
LEFT JOIN dim_customers c
ON F.customer_key = c.customer_key
Group by c.Customer_key)

SELECT
Customer_key,
Total_spending,
Lifespan,
CASE WHEN Lifespan >= 12 AND Total_spending > 5000 THEN 'VIP'
	WHEN Lifespan >= 12  AND Total_spending <= 5000 THEN 'Regular'
    ELSE 'NEW'
END customer_segments
FROM Customer_spending;

-- Find the total number of customers by each group.
WITH Customer_spending AS(
SELECT 
c.Customer_key,
SUM(f.sales_amount) AS Total_spending,
MAX(Order_date) AS First_order,
MIN(Order_date) AS Last_order,
TIMESTAMPDIFF(MONTH, Min(Order_date), Max(Order_date)) Lifespan
FROM fact_sales F
LEFT JOIN dim_customers c
ON F.customer_key = c.customer_key
Group by c.Customer_key)

SELECT
Customer_segments,
COUNT(Customer_key) AS Total_customers
FROM(
SELECT 
customer_key,
	CASE WHEN Lifespan >= 12 AND Total_spending > 5000 THEN 'VIP'
		WHEN Lifespan >= 12  AND Total_spending <= 5000 THEN 'Regular'
		ELSE 'NEW'
	END customer_segments
	FROM Customer_spending)t
GROUP BY Customer_segments
ORDER BY Total_customers DESC


