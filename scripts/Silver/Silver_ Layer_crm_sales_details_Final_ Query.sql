INSERT INTO silver.crm_sales_details
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
DATE(sls_order_dt) AS sls_order_dt,
DATE(sls_ship_dt) AS sls_ship_dt,
DATE(sls_due_dt) AS sls_due_dt,
CASE 	
		WHEN sls_sales IS NULL OR sls_sales = 0 OR sls_sales <> sls_quantity * ABS(sls_price)
				THEN sls_quantity * ABS(sls_price)
			ELSE sls_sales
		END sls_sales,
sls_quantity,
 CASE 
        WHEN sls_price IS NULL OR sls_price <= 0
            THEN CAST(sls_sales / NULLIF(sls_quantity, 0) AS SIGNED)
        ELSE CAST(sls_price AS SIGNED)
    END AS sls_price
FROM bronze.crm_sales_details;