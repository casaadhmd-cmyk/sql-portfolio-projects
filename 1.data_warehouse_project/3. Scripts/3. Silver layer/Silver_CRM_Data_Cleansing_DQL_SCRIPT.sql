SELECT NAME FROM sqlite_master


---- 1ST CRM TABLE bronze_crm_customer_info INTO SILVER
SELECT * FROM bronze_crm_customer_info;


--TO CHECK THE DUPLICATE'S IN PRIMARY KEY
select 
cst_id,
count(*)
from bronze_crm_customer_info
Group by bronze_crm_customer_info.cst_id 
Having count(*)>1 OR cst_id is NULL;


--To check the unwanted spaces--

SELECT
cst_firstname
from bronze_crm_customer_info
where cst_firstname != trim (cst_firstname);



SELECT
cst_lastname
from bronze_crm_customer_info
where cst_lastname != trim (cst_lastname);


SELECT
cst_marital_status
from bronze_crm_customer_info
where cst_marital_status != trim (cst_marital_status);


---Data Standardization & Consistency --


SELECT DISTINCT 
cst_gndr
from bronze_crm_customer_info



-----2 CRM table  bronze_crm_prd_info INTO SILVER 

select * from bronze_crm_prd_info;

select 
prd_id,
count(*)
from bronze_crm_prd_info
group by prd_id
having count (*)>1 or prd_id is null;



select distinct id from bronze_erp_PX_CAT_G1V2;  ----to have new column


--=-- TO CHECK HOW MANY OR NOT THERE IN 
SELECT 
prd_id,
prd_key,
REPLACE(SUBSTRING (prd_key,1,5), '-','_' ) AS cat_id,  -- in select distinct id from bronze_erp_PX_CAT_G1V2;  have _ 
SUBSTRING (prd_key,7,LENGTH(prd_key)) AS prd_key , -- IN SELECT sls_prd_key FROM bronze_crm_sales_details;
prd_nm,
IFNULL(prd_cost,0) AS prd_cost,
CASE  UPPER (TRIM(prd_line))
WHEN 'M' THEN 'Mountain'
WHEN 'R' THEN 'Road'
WHEN 'S' THEN 'Other Sales'
WHEN 'T' THEN 'Touring'
else 'n/a'
end as prd_line,
prd_start_dt,
DATE (LEAD (PRD_START_DT) OVER (PARTITION BY PRD_KEY ORDER BY  PRD_START_DT ASC ), '-1 DAY' ) AS prd_end_dt,
prd_end_dt

from 
bronze_crm_prd_info
--where REPLACE(SUBSTRING (prd_key,1,5), '-','_' )  
--NOT IN (select distinct id from bronze_erp_PX_CAT_G1V2)
--where SUBSTRING (prd_key,7,LENGTH(prd_key))
--NOT IN (SELECT sls_prd_key FROM bronze_crm_sales_details);




SELECT
prd_nm
from bronze_crm_prd_info
where prd_nm != trim (prd_nm);

-- check for the NULL or the negative numbers

SELECT 
prd_cost
FROM bronze_crm_prd_info 
where prd_cost < 0 or  prd_cost is null;

--- CHECK INVALID DATE ORDER'S 
SELECT 
prd_id,
prd_cost,
prd_key,
prd_nm,
prd_start_dt,
DATE (LEAD (PRD_START_DT) OVER (PARTITION BY PRD_KEY ORDER BY  PRD_START_DT ASC ), '-1 DAY' ) AS test_prd_end_dt
--cast (LEAD (PRD_START_DT) OVER (PARTITION BY PRD_KEY ORDER BY  PRD_START_DT ASC )-1 AS DATE) AS LIKE_TUTORAIL,
--prd_end_dt 
FROM bronze_crm_prd_info
WHERE PRD_START_DT > PRD_END_DT
AND PRD_KEY IN ('AC-HE-HL-U509','AC-HE-HL-U509-R')  --sample
ORDER BY prd_start_dt 


---- CRM 3RD TABLE bronze_crm_sales_details  INTO SILVER ----


SELECT 

sls_ord_num,
sls_prd_key,
sls_cust_id,

CASE 
	WHEN sls_order_dt <=0 OR LENGTH(sls_order_dt)!=8 THEN NULL
    ELSE CAST ( CAST (sls_order_dt AS VARCHAR) AS DATE) 
END AS sls_order_dt,


CASE 
	WHEN sls_ship_dt <=0 OR LENGTH(sls_ship_dt)!=8 THEN NULL
    ELSE CAST ( CAST (sls_ship_dt AS VARCHAR) AS DATE) 
END AS sls_ship_dt,


CASE 
	WHEN sls_due_dt <=0 OR LENGTH(sls_due_dt)!=8 THEN NULL
    ELSE CAST ( CAST (sls_due_dt AS VARCHAR) AS DATE) 
END AS sls_due_dt,

  CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,

    sls_quantity,

    CASE WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE ABS(sls_price)
    END AS sls_price
    
FROM bronze_crm_sales_details





SELECT 
NULLIF (sls_order_dt,0)sls_order_dt
FROM bronze_crm_sales_details
WHERE sls_order_dt <=0
OR  LENGTH (sls_order_dt) !=8
OR sls_order_dt >20500101  ---LETS SAY BUSINESS END DATE 
OR sls_order_dt < 1900101  --LET SAY BUSINESS START DATE 


SELECT 
NULLIF (sls_ship_dt,0)sls_ship_dt
FROM bronze_crm_sales_details
WHERE sls_ship_dt <=0
OR  LENGTH (sls_ship_dt) !=8
OR sls_ship_dt >20500101  ---LETS SAY BUSINESS END DATE 
OR sls_ship_dt < 1900101  --LET SAY BUSINESS START DATE 



SELECT 
NULLIF (sls_due_dt,0)sls_due_dt
FROM bronze_crm_sales_details
WHERE sls_due_dt <=0
OR  LENGTH (sls_due_dt) !=8
OR sls_due_dt >20500101  ---LETS SAY BUSINESS END DATE 
OR sls_due_dt < 1900101  --LET SAY BUSINESS START DATE 


--checking of invalid date order 

select * from 
bronze_crm_sales_details 
where sls_order_dt > sls_ship_dt
or sls_order_dt > sls_due_dt


--- SALES RULE = QUANTITY * PRICE 
--- NEGATIVE , ZERO, NULL  ARE NOT ALLOWED


--CHECK WITH THE EXPERT TO CORRECT THE SOURCE SYSTEM ITSLEF
--IF NOT THEN WE CAN TRANSFORM HERE BUT NOW WE CAN TRANSFORM IT 

-- RULES : 
 --1. IF SALES IS NEGATIVE , ZERO OR NULL DRIVE IT FROM ( PRICE * QUANTITY)
--2.IF PRICE IS NULL OR NEGATIVE ( CALCUALTE WITH THE SALES AND QUANTITY)
--3.IF PRICE IS NEGATIVE CONVERT IT WITH POSTIVE VALUE



SELECT 
    sls_sales,
    sls_quantity,
    sls_price
    from bronze_crm_sales_details
WHERE sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
   OR sls_sales != sls_quantity * sls_price
ORDER BY sls_sales, sls_quantity, sls_price;


-----The root cause was empty string '' stored as price, not actual NULL.
--So sls_price IS NULL never matched those rows. The fix was adding TRIM(CAST(sls_price AS TEXT)) = '' to catch empty strings too.

-----------IMPORTANT------------------
UPDATE bronze_crm_sales_details
SET sls_price = NULL
WHERE TRIM(CAST(sls_price AS TEXT)) = '';


SELECT
DISTINCT 
sls_sales old_sls_sales,
sls_quantity,
sls_price AS old_sls_price,


    CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,

    sls_quantity,

    CASE WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE ABS(sls_price)
    END AS sls_price
    
    FROM bronze_crm_sales_details
    WHERE sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
       OR TRIM(CAST(sls_price AS TEXT)) = ''
       OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
       OR sls_sales != sls_quantity * sls_price





