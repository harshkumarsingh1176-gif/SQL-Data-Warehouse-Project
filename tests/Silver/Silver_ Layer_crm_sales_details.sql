SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details;

-- Check the unwanted space in sls_ord_num
-- Expectation: No Result
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details 
WHERE sls_ord_num != TRIM(sls_ord_num);


-- Check the product key from the sales details and product information
-- Expectation: No issue and both can be use and connected with each other
SELECT
sls_prd_key
FROM silver.crm_sales_details 
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info); -- No Result means (No issue and both can be use and connected with each other)


-- Check the product key from the sales details and Customer information
-- Expectation: No issue and both can be use and connected with each other
SELECT
sls_cust_id
FROM silver.crm_sales_details 
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info); -- No Result means (No issue and both can be use and connected with each other)


-- Check the invalid dates
SELECT 
sls_due_dt
FROM silver.crm_sales_details 
WHERE sls_due_dt <= 0
OR sls_due_dt >20500101
OR sls_due_dt <19000101;

-- Chech the invalid order dates
SELECT *
FROM silver.crm_sales_details 
WHERE sls_order_dt > sls_order_dt OR sls_order_dt > sls_due_dt;


-- Update a quantity 
UPDATE bronze.crm_sales_details
SET sls_quantity =1 
Where sls_quantity = 1320;


-- Check the data consistency: Between sales, Quantity, Price
-- >> Sales = Quantity * Price
-- >> Value must not be NULL, Zero, or Negative
SELECT DISTINCT
sls_ord_num,
sls_sales,
sls_quantity,
sls_price 
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0;

SELECT DISTINCT
sls_sales AS Old_sls_sales,
sls_quantity,
sls_price AS Old_sls_price,
CASE 	
		WHEN sls_sales IS NULL OR sls_sales = 0 OR sls_sales != sls_quantity * ABS(sls_price)
				THEN sls_quantity * ABS(sls_price)
			ELSE sls_sales
		END sls_sales,
 CASE 
        WHEN sls_price IS NULL OR sls_price <= 0
            THEN CAST(sls_sales / NULLIF(sls_quantity, 0) AS SIGNED)
        ELSE CAST(sls_price AS SIGNED)
    END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0;



