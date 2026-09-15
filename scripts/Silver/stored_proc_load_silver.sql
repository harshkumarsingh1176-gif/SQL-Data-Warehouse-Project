/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    call Silver.load_silver;
===============================================================================
*/
SELECT '>> Silver_Layer Stored Procedure'

DELIMITER //

CREATE PROCEDURE Silver.load_Silver()
BEGIN
	SELECT '>> TRUNCATE Table: Silver.crm_cust_info' AS message;
	TRUNCATE TABLE Silver.crm_cust_info;
	SELECT '>> INSERT INTO TABLE Table: Silver.crm_cust_info' AS message;
	INSERT INTO Silver.crm_cust_info(
		cst_id, 
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
		)
		
	SELECT 
		cst_id, 
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,
		CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			  WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		END cst_marital_status,
		CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			  WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		END cst_gndr,
		cst_create_date
		FROM(
		SELECT *,
		ROW_NUMBER() OVER(PARTITION BY cst_Id ORDER BY cst_create_date DESC) AS Flag_Last
		FROM bronze.crm_cust_info
		)t 
		WHERE FLAG_last = 1;

	SELECT '>> TRUNCATE Table: Silver.crm_prd_info' AS message;
	TRUNCATE TABLE Silver.crm_prd_info;
	SELECT '>> INSERT INTO TABLE Table: Silver.crm_prd_info' AS message;
	INSERT INTO Silver.crm_prd_info(
		Prd_Id,
		Cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
		)
	SELECT 
	Prd_Id,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS Cat_id, 	-- Extract Category ID
	SUBSTRING(prd_key, 7, length(prd_key)) AS prd_key, 		-- Extract product Key
	prd_nm,
	COALESCE (prd_cost, 0) AS prd_cost,						-- Missing product cost is 0
	CASE UPPER(TRIM(prd_line)) 								-- Data Normalization
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'N/A'
	END AS prd_line,
	 STR_TO_DATE(prd_start_dt, '%m/%d/%Y') AS prd_start_dt,
		DATE_SUB(
			LEAD(STR_TO_DATE(prd_start_dt, '%m/%d/%Y')) 
				OVER (PARTITION BY prd_key ORDER BY STR_TO_DATE(prd_start_dt, '%m/%d/%Y')),
			INTERVAL 1 DAY
		) AS prd_end_dt
	FROM bronze.crm_prd_info
	;
	SELECT '>> TRUNCATE Table: silver.crm_sales_details' AS message;
	TRUNCATE TABLE silver.crm_sales_details;
	SELECT '>> INSERT INTO TABLE Table: silver.crm_sales_details' AS message;
	INSERT INTO silver.crm_sales_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
		)
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

	SELECT '>> TRUNCATE Table: silver.epr_cust_az12' AS message;
	TRUNCATE TABLE silver.epr_cust_az12;
	SELECT '>> INSERT INTO TABLE Table: silver.epr_cust_az12' AS message;
	INSERT INTO silver.epr_cust_az12(
		cid,
		bdate,
		gen
		)
	SELECT 
	CASE 
			WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid)) -- Remove 'NAS' Prefix if present
				ELSE cid
			END AS cid,
	CASE WHEN bdate > CURRENT_DATE() THEN NULL 						
		ELSE bdate
		END bdate,													-- Set future Birthday to NULL
	CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		ELSE 'N/A'
	END gen															-- Normalize the Gender values and handle Unknown cases
	FROM bronze.epr_cust_az12;

	SELECT '>> TRUNCATE Table: silver.epr_loc_a101' AS message;
	TRUNCATE TABLE silver.epr_loc_a101;
	SELECT '>> INSERT INTO TABLE Table: silver.epr_loc_a101' AS message;
	INSERT INTO silver.epr_loc_a101(
		cid,
		cntry
		)
	SELECT
	REPLACE (cid, '-', '') cid, 					-- Remove '-' from cid
	CASE 
		WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
		WHEN TRIM(cntry) = '' OR NULL THEN 'N/A'
		ELSE TRIM(cntry) 
	END AS cntry									-- Normalize and Handle the missing or blank country codes
	FROM bronze.epr_loc_a101;

	SELECT '>> TRUNCATE Table: silver.epr_px_cat_g1v2' AS message;
	TRUNCATE TABLE silver.epr_px_cat_g1v2;
	SELECT '>> INSERT INTO TABLE Table: silver.epr_px_cat_g1v2' AS message;
	INSERT INTO silver.epr_px_cat_g1v2 (
		id, 
		cat, 
		subcat, 
		maintenance
		)
	SELECT
	id,
	cat,
	subcat,
	maintenance
	FROM bronze.epr_px_cat_g1v2;
      
      SELECT '>> Silver layer load complete' AS message;

END //

DELIMITER ;

CALL Silver.load_Silver();
