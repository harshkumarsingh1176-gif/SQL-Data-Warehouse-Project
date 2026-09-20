-- Purpose:
-- This report consolidates the key customer matrics and behaviors

-- Highlights
-- 1 Gethers essential fields such as names, ages, and transaction details.
-- 2. segments customers into categories (VIP, Regular, New) and age groups.
-- 3. Aggregates customer-levels matrics:
   -- Total orders
   -- Total sales
   -- Total quantity purchased
   -- Total products
   -- Lifespane (in Months)
-- 4. Calculate Valubles KPIs:
	-- recency (month since last order)
    -- Average Order values
    -- Average Monthly spends
-- ===========================================================================
CREATE VIEW gold.report_customer AS
-- 1.Base Query: Retrive core columns from tables;
WITH Base_Query AS(
-- 1.Base Query: Retrive core columns from tables
SELECT 
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ', c.last_name) AS Customer_name,
c.birthdate,
TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) AS age
FROM fact_sales f
LEFT JOIN dim_customers c
ON f.customer_key = c.customer_Key
WHERE Order_date IS NOT NULL)
, Customer_aggregation AS(
-- ===========================================================================
-- * 2. Customer Aggregations: Summrizes the key matrics at the customers level
-- ===========================================================================
SELECT 
customer_key,
customer_number,
customer_name,
age,
COUNT(DISTINCT order_number) AS Total_orders,
SUM(Sales_amount) Total_sales,
SUM(Quantity) Total_Quantity,
COUNT(DISTINCT product_key) Total_product,
MAX(Order_date) AS Last_order_date,
TIMESTAMPDIFF(MONTH, Min(Order_date), Max(Order_date)) Lifespan
FROM Base_query
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age)
    
SELECT 
customer_key,
customer_number,
customer_name,
age,
CASE WHEN age < 20 THEN 'Underage'
	 WHEN AGE Between 20 AND 29 THEN '20-29'
     WHEN AGE Between 30 AND 39 THEN '30-39'
     WHEN AGE Between 40 AND 49 THEN '40-49'
     ELSE '50 or Above 50'
END Age_group,
     
CASE WHEN Lifespan >= 12 AND Total_sales > 5000 THEN 'VIP'
	WHEN Lifespan >= 12  AND Total_sales <= 5000 THEN 'Regular'
	ELSE 'NEW'
END customer_segments,
last_order_date, 
TIMESTAMPDIFF(MONTH, last_order_date, CURDATE()) AS Recency, -- Recency
Total_orders,
Total_sales,
Total_Quantity,
Total_product,
Lifespan, 
-- Compuate average order values (AOV)
CASE WHEN total_sales = 0 THEN 0
	ELSE ROUND(Total_sales / Total_orders,0)
 END Avg_order_value,
-- compuate average Monthly spend
CASE WHEN Lifespan = 0 THEN Total_sales
	ELSE ROUND(Total_sales/ Lifespan,0)
END Avg_Monthly_spend
FROM Customer_aggregation