INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
SELECT
id,
cat,
subcat,
maintenace AS maintenance
FROM bronze.erp_px_cat_g1v2;

SELECT *
FROM Silver.erp_px_cat_g1v2;