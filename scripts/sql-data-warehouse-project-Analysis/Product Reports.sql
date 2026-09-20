-- ====================================================================
-- Product Reports
-- ====================================================================

-- Purpose:
-- This report consolidates the key Product matrics and behaviors

-- Highlights
-- 1. Gethers essential fields such as names, ages, and transaction details.
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

-- ====================================================================
-- Customer Reports
-- ====================================================================

-- Purpose:
-- This report consolidates the key customer matrics and behaviors

-- Highlights
-- 1. Gethers essential fields such as names, Category, Subcategory and Cost.
-- 2. segments customers into categories High-Performance, Mid-Range and Low-Performance.
-- 3. Aggregates Product-levels matrics:
   -- Total orders
   -- Total sales
   -- Total quantity sold
   -- Total customers (Unique)
   -- Lifespane (in Months)
-- 4. Calculate Valubles KPIs:
	-- recency (month since last order)
    -- Average Order values (AOR)
    -- Average Monthly spends
-- ===========================================================================

CREATE VIEW gold.report_product  AS
-- 1.Base Query: Retrive core columns from tables;
WITH Base_Query AS(
-- 1.Base Query: Retrive core columns from tables
SELECT 
f.order_number,
f.order_date,
f.customer_key,
f.sales_amount,
f.quantity,
p.product_key,
p.product_name,
p.category,
p.subcategory, 
p.cost
FROM fact_sales f
LEFT JOIN dim_products p 
ON f.Product_key = p.product_Key
WHERE Order_date IS NOT NULL) -- Only consider valid sales dates
, product_aggregation AS(

-- ===========================================================================
-- * 2. Product Aggregations: Summrizes the key matrics at the product level
-- ===========================================================================

SELECT 
product_key,
product_name,
category,
subcategory, 
cost,
TIMESTAMPDIFF(MONTH, Min(Order_date), Max(Order_date)) Lifespan,
MAX(Order_date) AS Last_sale_date,
COUNT(DISTINCT order_number) AS Total_orders,
COUNT(DISTINCT Customer_key) Total_Customers,
SUM(Sales_amount) Total_sales,
SUM(Quantity) Total_Quantity,
ROUND(AVG(Sales_amount/ NULLIF(QUANTITY,0))) AS Avg_Selling_Price
FROM Base_query
GROUP BY 
	product_key,
	product_name,
	category,
	subcategory, 
	cost)
-- ========================================================================
-- 3. Final Query: Combine all product results into one output
-- ======================================================================== 
SELECT 
product_key,
product_name,
category,
subcategory, 
cost,
Last_sale_date,
TIMESTAMPDIFF(MONTH, Last_sale_date, CURDATE()) AS Recency, -- Recency
CASE 
	 WHEN Total_sales > 50000 THEN 'High_Performer'
     WHEN Total_sales >= 10000 THEN 'Mid_Range'
	 ELSE 'Low_Performer'
END Product_Segment,
Total_orders,
Total_sales,
Total_Quantity,
Lifespan, 
Avg_selling_price,

-- Compuate average order revenue (AOR)
CASE WHEN total_orders = 0 THEN 0
	ELSE ROUND(Total_sales / Total_orders,0)
 END Avg_order_revenue,

-- compuate average Monthly revenue
CASE WHEN Lifespan = 0 THEN Total_sales
	ELSE ROUND(Total_sales/ Lifespan,0)
END Avg_Monthly_revneue
FROM Product_aggregation;

SELECT * FROM gold.report_product;



















