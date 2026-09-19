SELECT * FROM crm_cust_info;
SELECT * FROM crm_prd_info;
SELECT * FROM crm_sales_details;
 DROP TABLE silver.crm_cust_info;
 
 SELECT '>> Inserting Data Into: silver.crm_cust_info' AS Message;

	CREATE TABLE silver.crm_cust_info (
		cst_id INT,
		cst_key VARCHAR (50),
		cst_firstname VARCHAR (50),
		cst_lastname VARCHAR (50),
		cst_marital_status VARCHAR (50),
		cst_gndr VARCHAR (50),
		cst_create_date DATE
		);
		
		SELECT '>> Inserting Data Into: silver.crm_prd_info' AS Message;
        DROP TABLE silver.crm_prd_info;
        CREATE TABLE silver.crm_prd_info (
		prd_id INT,
        cat_id VARCHAR(50),
		prd_key VARCHAR (50),
		prd_nm VARCHAR (50),
		prd_cost VARCHAR (50),
		prd_line VARCHAR (50),
		prd_start_dt DATE,
		prd_end_dt DATE
		);

        SELECT '>> Inserting Data Into: silver.crm_sales_details' AS Message;
		CREATE TABLE silver.crm_sales_details (
		sls_ord_num VARCHAR (50),
		sls_prd_key VARCHAR (50),
		sls_cust_id INT,
		sls_order_dt INT,
		sls_ship_dt INT,
		sls_due_dt INT,
		sls_sales INT,
		sls_quantity INT,
		sls_price INT
		);
		
        SELECT '>> Loading ERP Table' AS Message;

        SELECT '>> Inserting Data Into: silver.erp_loc_a101' AS Message;
		CREATE TABLE silver.erp_loc_a101 (
		cid VARCHAR (50),
		cntry VARCHAR (50)
		);
		
        SELECT '>> Inserting Data Into: silver.erp_cust_az12' AS Message;
		CREATE TABLE silver.erp_cust_az12 (
		cid VARCHAR (50),
		bdate DATE,
		gen VARCHAR (50)
		);
		
        SELECT '>> Inserting Data Into: silver.erp_px_cat_g1v2' AS Message;
		CREATE TABLE silver.erp_px_cat_g1v2(
		id VARCHAR (50),
		cat VARCHAR (50),
		subcat VARCHAR (50),
		maintenace VARCHAR (50)
        );
        
        SELECT *  FROM silver.crm_cust_info;