INSERT INTO silver.erp_cust_az12
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
FROM bronze.erp_cust_az12;

SELECT * FROM silver.erp_cust_az12