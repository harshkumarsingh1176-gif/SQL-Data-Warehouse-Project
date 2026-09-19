-- Data load into silver Layer
INSERT INTO Silver.crm_cust_info
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

SELECT * FROM silver.crm_cust_info;
SELECT *
FROM bronze.crm_cust_info;
SHOW CREATE TABLE silver.crm_cust_info;
TRUNCATE TABLE silver.crm_cust_info;