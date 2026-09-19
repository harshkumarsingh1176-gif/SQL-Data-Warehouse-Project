INSERT INTO silver.erp_loc_a101
SELECT
REPLACE (cid, '-', '') cid, 					-- Remove '-' from cid
CASE 
	WHEN TRIM(cntry) = 'DE' THEN 'Germany'
    WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	WHEN TRIM(cntry) = '' OR NULL THEN 'N/A'
    ELSE TRIM(cntry) 
END AS cntry									-- Normalize and Handle the missing or blank country codes
FROM bronze.erp_loc_a101;

SELECT *
FROM Silver.erp_loc_a101;

