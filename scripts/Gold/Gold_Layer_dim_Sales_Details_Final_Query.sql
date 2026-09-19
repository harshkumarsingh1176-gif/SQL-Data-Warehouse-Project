DROP VIEW Gold.fact_sales;
CREATE VIEW Gold.fact_sales AS
SELECT 
		sd.sls_ord_num AS Order_Number,
		pr.Product_Key,
		cu.Customer_Key,
		sd.sls_order_dt AS Order_Date,
		sd.sls_ship_dt AS Shipping_Date,
		sd.sls_due_dt AS Due_Date,
		sd.sls_sales AS Sales_Amount,
		sd.sls_quantity AS Quantity,
		sd.sls_price AS Price
FROM silver.crm_sales_details sd
LEFT JOIN Gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN Gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id;

SELECT * FROM gold.fact_sales
