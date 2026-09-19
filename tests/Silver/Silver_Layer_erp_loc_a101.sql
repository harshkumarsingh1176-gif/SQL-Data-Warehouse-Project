SELECT
REPLACE (cid, '-', '') cid,
cntry
FROM bronze.erp_loc_a101;

-- Data Standarization and Consistancy
SELECT DISTINCT 
CASE 
	WHEN TRIM(cntry) = 'DE' THEN 'Germany'
    WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	WHEN TRIM(cntry) = '' OR NULL THEN 'N/A'
    ELSE TRIM(cntry) 
END AS cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

SELECT * FROM silver.erp_loc_a101