-- Check the duplicate data
SELECT prd_id, COUNT(*) FROM (
SELECT
	pn.Prd_Id,
	pn.Cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
    pc.cat,
    pc.subcat,
    pc.maintenance
FROM silver.crm_prd_info pn
LEFT JOIN Silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL)t
GROUP BY prd_id
HAVING COUNT(*)> 1; -- Filter out all Historical Data 