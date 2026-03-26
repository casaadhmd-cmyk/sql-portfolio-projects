/*

* Exploration of the of the Data which is Dimensions 
* How To identity the Dimension or a Measure /
* Is the Data type is numeric and is it ok to aggregate it ( if it does not satisfy the above then its dimension)



*/

SELECT
    m.name AS table_name,
    p.name AS column_name,
    p.type AS data_type,
    p.pk AS primary_key
FROM sqlite_master m
JOIN pragma_table_info(m.name) p
WHERE m.type = 'table'
and p.type like '%CHAR%'  ---TO GET THE DIMENSIONS
ORDER BY m.name, p.cid;


--TO EXPLORE THE COUNTRY

SELECT DISTINCT  country from dim_customers dc ;


--TO explore  the products table

select distinct dp.product_name, dp.category,dp.subcategory    
from dim_products dp ;