
--TO LOAD THE DATA AFTER THE CLEANING AND STANDARDIZED DATA 

---1.SELECT * FROM silver_crm_customer_info
CREATE OR ALTER PROCEDURE silver.load AS 

BEGIN
		DECLARE @START_TIME DATETIME , @END_TIME  DATETIME ,  @BATCH_START DATETIME, @BATCH_END DATETIME 
		
	BEGIN TRY 
		BEGIN TRANSACTION 
	 SET @BATCH_START = GETDATE();
	 PRINT '=========================';
	 PRINT ' LOADING SILVER LAYER';
	 PRINT '=========================';
	 
	 PRINT'------------------------------';
	 PRINT 'LOADING CRM TABLES';
	 PRINT'------------------------------';
	 
SET @START_TIME = GETDATE();
PRINT '>> Truncating the silver_crm_customer_info' ;   --PRINT WILL NOT WORK EITHER IN SQL LITE
TRUNCATE TABLE silver_crm_customer_info   --TRUNCAT5E WILL NOT WORK IN SQLITE SO USED THE DELETE
PRINT  '>> Inserting Data Into : silver_crm_customer_info ' ;


INSERT INTO silver_crm_customer_info (
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date
)

select
cst_id,
cst_key,
TRIM(cst_firstname),
TRIM (cst_lastname),
CASE WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'SINGLE'
     WHEN UPPER(TRIM(cst_marital_status)) ='M' THEN 'MARRIED'
     ELSE 'NA'
     END AS cst_marital_status,
CASE WHEN UPPER(TRIM(cst_gndr))='F' THEN 'FEMALE'
     WHEN UPPER(TRIM(cst_gndr)) ='M' THEN 'MALE'
     ELSE 'NA'
     END AS cst_gndr,
     
 cst_create_date    

from 
(

SELECT * ,
Row_number ()over (Partition by cst_id order by cst_create_date DESC ) as Rn

FROM 
bronze_crm_customer_info
) T
where  rn =1 ;

SET @END_TIME = GETDATE();
PRINT 'LOADING COMPLETED FOR silver_crm_customer_info'+ CAST (DATEDIFF(SECOND, @START_TIME,@END_TIME) AS VARCHAR) +'SECOND'
PRINT'------------------------------';


---2nd --SELECT * FROM silver_crm_prd_info scpi 

SET @START_TIME  = GETDATE();
PRINT '>> Truncating the silver_crm_prd_info' ;   --PRINT WILL NOT WORK EITHER IN SQL LITE
TRUNCATE TABLE silver_crm_prd_info   --TRUNCAT5E WILL NOT WORK IN SQLITE SO USED THE DELETE
PRINT  '>> Inserting Data Into : silver_crm_prd_info ' ;


INSERT INTO silver_crm_prd_info  (

prd_id,
cat_id,  ---ADDED NOW DURING THE STANDARDIZATON
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)


SELECT 
prd_id,
REPLACE(SUBSTRING (prd_key,1,5), '-','_' ) AS cat_id,  -- in select distinct id from bronze_erp_PX_CAT_G1V2;  have _ 
SUBSTRING (prd_key,7,LENGTH(prd_key)) AS prd_key , -- IN SELECT sls_prd_key FROM bronze_crm_sales_details;
TRIM(prd_nm)prd_nm,
IFNULL(prd_cost,0) AS prd_cost,
CASE  UPPER (TRIM(prd_line))
WHEN 'M' THEN 'Mountain'
WHEN 'R' THEN 'Road'
WHEN 'S' THEN 'Other Sales'
WHEN 'T' THEN 'Touring'
else 'n/a'
end as prd_line,

DATE(prd_start_dt)prd_start_dt,
DATE (LEAD (PRD_START_DT) OVER (PARTITION BY PRD_KEY ORDER BY  PRD_START_DT ASC ), '-1 DAY' ) AS prd_end_dt
--cast (LEAD (PRD_START_DT) OVER (PARTITION BY PRD_KEY ORDER BY  PRD_START_DT ASC )-1 AS DATE) AS LIKE_TUTORAIL,
from 
bronze_crm_prd_info;

SET @END_TIME = GETDATE();
PRINT 'LOADING COMPLETED FOR silver_crm_prd_info'+ CAST (DATEDIFF(SECOND, @START_TIME,@END_TIME) AS VARCHAR) +'SECOND'
PRINT'------------------------------';




----3RD SILVER  crm_sales_details

SET  @START_TIME  = GETDATE();
PRINT '>> Truncating the silver_crm_sales_details' ;  --PRINT WILL NOT WORK EITHER IN SQL LITE
TRUNCATE TABLE silver_crm_sales_details   --TRUNCAT5E WILL NOT WORK IN SQLITE SO USED THE DELETE
PRINT  '>> Inserting Data Into : silver_crm_sales_details ' ;


INSERT INTO silver_crm_sales_details 
(

sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price

)

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
    END AS sls_price  ---THERE WERE EMPTY STRING SO UPDATED THOSE TO NULL 
    
FROM bronze_crm_sales_details

SET @END_TIME =  GETDATE();
PRINT 'Loading completed for silver_crm_sales_details' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS VARCHAR) + 'SECOND'
PRINT '-------------------------------'

--4TH  select * from silver_erp_CUST_AZ12 seca 

--TRUNCATE TABLE silver_erp_CUST_AZ12

/*
CREATE TABLE silver_erp_CUST_AZ12
(

CID TEXT,
BDATE NUMERIC,
GEN TEXT,
dwh_create_date DEFAULT CURRENT_TIMESTAMP

); 
*/

PRINT '------------------------------------------------';
PRINT 'Loading ERP Tables';
PRINT '------------------------------------------------';

SET  @START_TIME  = GETDATE();
PRINT '>> Truncating the silver_erp_cust_az12' ;  --PRINT WILL NOT WORK EITHER IN SQL LITE
TRUNCATE TABLE silver_erp_cust_az12   --TRUNCAT5E WILL NOT WORK IN SQLITE SO USED THE DELETE
PRINT  '>> Inserting Data Into : silver_erp_cust_az12 ' ;

INSERT INTO silver_erp_cust_az12
(
CID,
BDATE,
GEN)

SELECT 

CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING (CID,4,LENGTH(CID))
ELSE CID
END AS CID,

CASE WHEN BDATE  > CURRENT_TIMESTAMP THEN NULL 
ELSE BDATE
END AS BDATE,

CASE WHEN UPPER (TRIM (GEN)) IN ('MALE','M') Then 'Male'
     WHEN UPPER (TRIM (GEN)) IN ('FEMALE','F') Then 'Female'
     ELSE 'n/a'
     END AS GEN
     
 FROM bronze_erp_CUST_AZ12 beca ;

 
SET @END_TIME =  GETDATE();
PRINT 'Loading completed for silver_erp_cust_az12' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS VARCHAR) + 'SECOND'
PRINT '-------------------------------'

 
 
 --5TH silver_erp_LOC_A101
 
-- TRUNCATE TABLE silver_erp_LOC_A101
 
/* 
 CREATE TABLE silver_erp_LOC_A101

(

CID	TEXT,
CNTRY TEXT,
dwh_create_date DEFAULT CURRENT_TIMESTAMP

);
 
 */
 
SET  @START_TIME  =  GETDATE();
PRINT '>> Truncating the silver_erp_LOC_A101' ;  --PRINT WILL NOT WORK EITHER IN SQL LITE
TRUNCATE TABLE silver_erp_LOC_A101   --TRUNCAT5E WILL NOT WORK IN SQLITE SO USED THE DELETE
PRINT  '>> Inserting Data Into : silver_erp_LOC_A101 ' ;


 INSERT INTO silver_erp_LOC_A101
 (CId,
CNTRY)
 
 
SELECT 
REPLACE (CID,'-','')AS CID,
CASE WHEN UPPER (TRIM (CNTRY))='DE' THEN 'Germany'
 WHEN UPPER (TRIM (CNTRY)) IN ('US','USA') THEN 'United States'
 WHEN  TRIM (CNTRY)= '' OR TRIM (CNTRY) IS NULL THEN 'N/A'  ----make sureto trim the empty string column it might have '' ,' ','  '
 ELSE TRIM(CNTRY)
 END AS CNTRY
FROM 
bronze_erp_LOC_A101;



 
SET @END_TIME =  GETDATE();
PRINT 'Loading completed for silver_erp_LOC_A101' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS VARCHAR) + 'SECOND'
PRINT '-------------------------------'


-- 6TH  select * from silver_erp_PX_CAT_G1V2

--TRUNCATE TABLE silver_erp_PX_CAT_G1V2
/*

CREATE TABLE silver_erp_PX_CAT_G1V2

(
ID TEXT,
CAT TEXT,
SUBCAT TEXT,
MAINTENANCE TEXT,
dwh_create_date DEFAULT CURRENT_TIMESTAMP

);
*/

SET @START_TIME = GETDATE();
 PRINT '>> Truncating the silver_erp_PX_CAT_G1V2' ;  --PRINT WILL NOT WORK EITHER IN SQL LITE
TRUNCATE TABLE silver_erp_PX_CAT_G1V2   --TRUNCAT5E WILL NOT WORK IN SQLITE SO USED THE DELETE
PRINT  '>> Inserting Data Into : silver_erp_PX_CAT_G1V2 ' ;


INSERT INTO silver_erp_PX_CAT_G1V2
(
ID,
CAT,
SUBCAT,
MAINTENANCE
)

 SELECT 
 ID,
 TRIM(CAT) AS CAT,
 TRIM(SUBCAT) AS SUBCAT,
 TRIM (MAINTENANCE) AS MAINTENANCE
 FROM bronze_erp_PX_CAT_G1V2;
 
 SET @END_TIME = GETDATE();
 PRINT 'Loading completed for silver_erp_PX_CAT_G1V2' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS VARCHAR) + 'SECOND'
 PRINT '-------------------------------'

 
 
 SET @BATCH_END = GETDATE();
	 PRINT '========================='
	 PRINT ' LOADING SILVER LAYER COMPLETED'
	 PRINT  ' DURATION OF COMPLETION' +      CAST (DATEDIFF(SECOND, BATCH_START,BATCH_END) AS NVARCHAR) + 'SECOND'
	 PRINT '========================='
    
	 
	 COMMIT TRANSACTION
	 
END TRY 

BEGIN CATCH

ROLLBACK TRANSACTION

PRINT '=================================='
PRINT  'ERROR OCCURED DURING THE SILVER LAYER'
PRINT  'ERROR MESSAGE' + ERROR_MESSAGE ();
PRINT  'ERROR MESSAGE' + CAST (ERROR_NUMBER() AS NVARCHAR);
PRINT  'ERROR MESSAGE' + CAST (ERROR_STATE() AS NVARCHAR);
PRINT '=================================='

END CATCH

END ;




