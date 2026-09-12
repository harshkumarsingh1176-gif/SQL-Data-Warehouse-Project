/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to redefine the DDL structure of 'bronze' Tables
===============================================================================
*/

DELIMITER //
CREATE PROCEDURE bronze.load_bronze ()
Begin
	SELECT ' Loading Bronze Layer' AS Message;
    
    SELECT ' Loading CRM Table' AS Message;
    
    SELECT '>> Inserting Data Into: bronze.crm_cust_info' AS Message;
	CREATE TABLE bronze.crm_cust_info (
		cst_id INT,
		cst_key VARCHAR (50),
		cst_firstname VARCHAR (50),
		cst_lastname VARCHAR (50),
		cst_material_status VARCHAR (50),
		cst_gndr VARCHAR (50),
		cst_create_date DATE
		);
		
		SELECT '>> Inserting Data Into: bronze.crm_prd_info' AS Message;
        CREATE TABLE bronze.crm_prd_info (
		prd_id INT,
		prd_key VARCHAR (50),
		prd_nm VARCHAR (50),
		prd_cost VARCHAR (50),
		prd_line VARCHAR (50),
		prd_start_dt DATETIME,
		prd_end_dt DATETIME
		);

        SELECT '>> Inserting Data Into: bronze.crm_sales_details' AS Message;
		CREATE TABLE bronze.crm_sales_details (
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
		
        SELECT '>> Loading EPR Table' AS Message;

        SELECT '>> Inserting Data Into: bronze.epr_loc_a101' AS Message;
		CREATE TABLE bronze.epr_loc_a101 (
		cid VARCHAR (50),
		cntry VARCHAR (50)
		);
		
        SELECT '>> Inserting Data Into: bronze.epr_cust_az12' AS Message;
		CREATE TABLE bronze.epr_cust_az12 (
		cid VARCHAR (50),
		bdate DATE,
		gen VARCHAR (50)
		);
		
        SELECT '>> Inserting Data Into: bronze.epr_px_cat_g1v2' AS Message;
		CREATE TABLE bronze.epr_px_cat_g1v2(
		id VARCHAR (50),
		cat VARCHAR (50),
		subcat VARCHAR (50),
		maintenance VARCHAR (50)
		);
  END //
  
  DELIMITER ;
  

    SELECT * FROM bronze.crm_cust_info;
    SELECT count(*) FROM bronze.epr_loc_a101;
    
    CALL load_bronze();

    CALL bronze.load_bronze();
