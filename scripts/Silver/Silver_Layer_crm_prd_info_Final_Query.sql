-- Data load into silver Layer
INSERT INTO Silver.crm_prd_info
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
FROM crm_prd_info
;


SELECT * 
FROM silver.crm_prd_info;