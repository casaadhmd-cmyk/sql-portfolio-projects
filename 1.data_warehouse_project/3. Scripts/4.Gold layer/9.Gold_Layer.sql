--SELECT CST_ID, COUNT(*) AS COUNT_ FROM (

CREATE VIEW gold_dim_customers AS 

SELECT 
ROW_NUMBER () OVER (ORDER BY cst_id) as customer_key,
CI.cst_id as customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as frist_name,
ci.cst_lastname as last_name,
la.cntry as country,

ci.cst_marital_status as marital_status,
CASE 
WHEN UPPER(ci.cst_gndr) NOT IN ('NA','N/A')
THEN UPPER(ci.cst_gndr)

ELSE UPPER(COALESCE(ca.gen,'N/A'))

END AS gender,
ca.bdate as birthdate,
ci.cst_create_date as create_date


FROM silver_crm_customer_info ci 
left join silver_erp_CUST_AZ12 ca on ci.cst_key= ca.cid
left join silver_erp_LOC_A101 la on  ci.cst_key= la.cid

--) T  GROUP BY CST_ID HAVING COUNT(*) > 1



/*
SELECT name, type
FROM sqlite_master
WHERE type = 'view';

SELECT * FROM sqlite_master

*/


SELECT *  FROM gold_dim_customers gdc 


SELECT 
DISTINCT
ci.cst_gndr,
ca.gen,
CASE 
WHEN UPPER(ci.cst_gndr) NOT IN ('NA','N/A')
THEN UPPER(ci.cst_gndr)

ELSE UPPER(COALESCE(ca.gen,'N/A'))

END AS new_gen

FROM silver_crm_customer_info ci 
left join silver_erp_CUST_AZ12 ca on ci.cst_key= ca.cid
left join silver_erp_LOC_A101 la on  ci.cst_key= la.cid

ORDER BY 1,2




--2nd table

--drop view gold_dim_product
	--SELECT PRD_KEY, COUNT(*) AS COUNT_ FROM (
CREATE VIEW gold_dim_product as
SELECT 
ROW_NUMBER () OVER (ORDER BY p.PRD_START_DT,P.PRD_KEY) as product_key,
P.PRD_ID AS product_id,
P.PRD_KEY as product_number, 
P.PRD_NM as product_name,

P.CAT_ID as category_id,
PR.CAT as category,
PR.SUBCAT as subcategory,
PR.MAINTENANCE,

P.PRD_COST as cost,
P.PRD_LINE as prodcut_line,
P.PRD_START_DT as start_date
--P.PRD_END_DT,



FROM silver_crm_prd_info P
LEFT JOIN silver_erp_PX_CAT_G1V2 PR ON P.CAT_ID = PR.ID
where prd_end_dt is null  --TO FILTER OUT THE NULL AS WE NEED THE CURRENT PRODUCT
--) T GROUP BY PRD_KEY HAVING COUNT(*) >1

/*
SELECT * FROM  silver_crm_prd_info LIMIT 5;

SELECT * FROM silver_erp_PX_CAT_G1V2 LIMIT 5 ;
*/

select * from gold_dim_product

SELECT 
distinct
P.CAT_ID,
PR.ID
FROM silver_crm_prd_info P
LEFT JOIN silver_erp_PX_CAT_G1V2 PR ON P.CAT_ID = PR.ID
where prd_end_dt is null;
order by  1,2



--3rd  gold layer [ THIS IS THE FACTS]

create view gold_facts_sales AS 
select 
s.sls_ord_num As order_number,
pr.product_key,
cu.customer_key,
s.sls_order_dt AS order_date,
s.sls_ship_dt AS shipping_date,
s.sls_due_dt AS due_dt,
s.sls_sales AS sales_amount,
s.sls_quantity  AS quantity,
s.sls_price  AS price

from silver_crm_sales_details s

LEFT JOIN gold_dim_product pr on 
s.sls_prd_key = pr.product_number

LEFT JOIN  gold_dim_customers cu on 
s.sls_cust_id=cu.customer_id



--select * from silver_crm_sales_details limit 5;

--select * from gold_dim_product limit 5;

/*
select * 

from gold_facts_sales f
left join gold_dim_customers c on f.customer_key=c.customer_key 
where c.customer_key  is null


select * 

from gold_facts_sales f
left join gold_dim_product p  on f.product_key=p.product_key 
where p.product_key is null
*/



