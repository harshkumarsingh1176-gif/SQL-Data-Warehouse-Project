SELECT
id,
cat,
subcat,
maintenace
FROM bronze.erp_px_cat_g1v2;

-- Check the unwanted Space
SELECT * 
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) or subcat != TRIM(subcat) OR maintenace != TRIM(MAINTENACE);

-- Data standarization and Consistancy
SELECT DISTINCT
cat 
FROM bronze.erp_px_cat_g1v2;

-- Data standarization and Consistancy
SELECT DISTINCT
SUBcat 
FROM bronze.erp_px_cat_g1v2;

-- Data standarization and Consistancy
SELECT DISTINCT
maintenace
FROM bronze.erp_px_cat_g1v2;

SELECT *
FROM Silver.erp_px_cat_g1v2;