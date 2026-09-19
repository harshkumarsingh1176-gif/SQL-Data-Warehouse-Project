-- Check for nulls and duplicates in primary Key
-- Expectation: No Result

SELECT
prd_Id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_Id IS NULL;

-- Extraction the Category id
SELECT 
Prd_Id,
prd_key,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS Cat_id,
prd_nm,
prd_cost,
prd_Line,
prd_start_dt,
prd_end_dt
FROM crm_prd_info
WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN 
(SELECT DISTINCT id FROM bronze.epr_px_cat_g1v2);

-- Extraction the Category id and product key
SELECT 
Prd_Id,
prd_key,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS Cat_id,
SUBSTRING(prd_key, 7, length(prd_key)) AS prd_key,
prd_nm,
prd_cost,
prd_Line,
prd_start_dt,
prd_end_dt
FROM crm_prd_info;

-- Check for Unwanted space
-- Expectation: No Result
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for negative cost
-- Expectation: No Result
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR Prd_cost IS NULL;

-- Data standarization & consistancy
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Check the invalid order dates
SELECT * 
FROM silver.crm_prd_info
WHERE prd_end_dt< prd_start_dt;

-- Correction of prd_end_dt
SELECT
    Prd_Id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_Line,
    STR_TO_DATE(prd_start_dt, '%m/%d/%Y') AS prd_start_dt,
    DATE_SUB(
        LEAD(STR_TO_DATE(prd_start_dt, '%m/%d/%Y')) 
            OVER (PARTITION BY prd_key ORDER BY STR_TO_DATE(prd_start_dt, '%m/%d/%Y')),
        INTERVAL 1 DAY
    ) AS prd_end_dt
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');