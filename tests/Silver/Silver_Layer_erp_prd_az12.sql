-- Identify out of the range date
SELECT distinct
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1926-01-01' OR bdate > current_date();

-- Data standarization and consistancy
SELECT distinct
gen,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	ELSE 'N/A'
END gen
FROM silver.erp_cust_az12;

SELECT * FROM silver.erp_cust_az12