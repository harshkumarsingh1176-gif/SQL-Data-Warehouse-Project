DROP VIEW Gold.dim_customers;
CREATE VIEW Gold.dim_customers AS
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

SELECT * FROM gold.dim_customers