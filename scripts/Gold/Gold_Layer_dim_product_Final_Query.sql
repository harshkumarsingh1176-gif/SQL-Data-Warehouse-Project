DROP view GOLD.DIM_products;
CREATE VIEW Gold.dim_products AS
SELECT
	ROW_NUMBER() OVER(ORDER BY prd_start_dt, pn.prd_key) AS Product_Key,
	pn.Prd_Id AS Product_id,
    pn.prd_key AS Product_Number,
    pn.prd_nm AS Product_Name,
	pn.Cat_id AS Category_id,
	pc.cat AS Category,
    pc.subcat AS Subcategory,
    pc.maintenance AS Maintenance,
	pn.prd_cost AS Cost,
	pn.prd_line AS Product_Line,
	pn.prd_start_dt AS Start_Date
FROM silver.crm_prd_info pn
LEFT JOIN Silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL;

SELECT * FROM Gold.dim_products