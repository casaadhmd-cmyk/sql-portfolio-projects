
/*
 * Data Base exploration in debeaver sqlite as information shcema table/cloumns and sp help (table name will not work here)
 * 
 */


select * from sqlite_master;


--To Explore the data type of the each columns 

SELECT
    m.name AS table_name,
    p.name AS column_name,
    p.type AS data_type,
    p.pk AS primary_key
FROM sqlite_master m
JOIN pragma_table_info(m.name) p
WHERE m.type = 'table'
ORDER BY m.name, p.cid;


---TO EXLORE THE DATA IN THE TABLES

SELECT * FROM DIM_CUSTOMERS LIMIT 5 ;

SELECT * FROM dim_products LIMIT 5 ;

SELECT * FROM fact_sales LIMIT 5 ;
