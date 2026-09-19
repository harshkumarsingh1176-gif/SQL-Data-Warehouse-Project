-- Check Duplicates
SELECT cst_Id, COUNT(*) FROM(
SELECT 
		ci.cst_id, 
		ci.cst_key,
		ci.cst_firstname,
		ci.cst_lastname,
		ci.cst_marital_status,
		ci.cst_gndr,
		ci.cst_create_date,
        ca.bdate,
        ca.gen,
        la.cntry
FROM silver.crm_cust_info ci
LEFT JOIN Silver.erp_cust_az12 ca
ON 			ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON 			ci.cst_key = la.cid)t
GROUP BY cst_id
HAVING COUNT(*)>1
;

-- Check the gender in crm_cust and erp_cust

SELECT DISTINCT 					-- TAKE THE EXPERT OPINION IF DATA IS MISMATCH FROM THE BOTH TABLE
		ci.cst_gndr,
        ca.gen,
	CASE WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr -- CRM is master for gender Info
		ELSE COALESCE (ca.gen, 'N/A')
	END AS New_Gen
FROM silver.crm_cust_info ci
LEFT JOIN Silver.erp_cust_az12 ca
ON 			ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON 			ci.cst_key = la.cid
ORDER BY 1,2;


-- Create Surrogate Key by using Cst_id
SELECT 
		ROW_NUMBER () OVER (ORDER BY cst_id) AS Customer_Key,
		ci.cst_id AS Customer_Id, 
		ci.cst_key AS Customer_Number,
		ci.cst_firstname AS First_name,
		ci.cst_lastname AS Last_name,
        la.cntry AS Country,
		ci.cst_marital_status AS Marital_status,
		CASE WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr -- CRM is master for gender Info
				ELSE COALESCE (ca.gen, 'N/A')
		END AS Gender,
        ca.bdate AS Birthdate,
		ci.cst_create_date AS Create_Date
FROM silver.crm_cust_info ci
LEFT JOIN Silver.erp_cust_az12 ca
ON 			ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON 			ci.cst_key = la.cid;

SELECT DISTINCT gender FROM gold.dim_customers