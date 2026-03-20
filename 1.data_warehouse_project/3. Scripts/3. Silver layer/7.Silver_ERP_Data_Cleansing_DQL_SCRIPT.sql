--1ST TABLE OF THE ERP 

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

--SELECT * FROM silver_crm_customer_info;

--INCORRECT BIRTH DATE 
SELECT 
DISTINCT  
BDATE
FROM bronze_erp_CUST_AZ12
WHERE BDATE <'1924-01-01' OR BDATE > CURRENT_TIMESTAMP
OR BDATE IS NULL OR BDATE=''


-- INCORRECT 
SELECT 
DISTINCT
GEN,
CASE WHEN UPPER (TRIM (GEN)) IN ('MALE','M') Then 'Male'
     WHEN UPPER (TRIM (GEN)) IN ('FEMALE','F') Then 'Female'
     ELSE 'n/a'
     END AS GEN
     
FROM bronze_erp_CUST_AZ12


----2ND ERP TABLE  silver_erp_LOC_A101


SELECT 
REPLACE (CID,'-','')AS CID,
CASE WHEN UPPER (TRIM (CNTRY))='DE' THEN 'Germany'
 WHEN UPPER (TRIM (CNTRY)) IN ('US','USA') THEN 'United States'
 WHEN  TRIM (CNTRY)= '' OR TRIM (CNTRY) IS NULL THEN 'N/A'  ----make sureto trim the empty string column it might have '' ,' ','  '
 ELSE TRIM(CNTRY)
 END AS CNTRY
FROM 
bronze_erp_LOC_A101   

---select *  from bronze_crm_customer_info;
 
 
 select 
 distinct 
 CNTRY OLD_DATA,
 CASE WHEN UPPER (TRIM (CNTRY))='DE' THEN 'Germany'
 WHEN UPPER (TRIM (CNTRY)) IN ('US','USA') THEN 'United States'
 WHEN  TRIM (CNTRY)= '' OR TRIM (CNTRY) IS NULL THEN 'N/A'  ----make sureto trim the empty string column it might have '' ,' ','  '
 ELSE TRIM(CNTRY)
 END AS CNTRY
 
 from
 bronze_erp_LOC_A101
 ORDER BY CNTRY


 
---3rd ERP table 
 
 
 SELECT 
 ID,
 TRIM(CAT) AS CAT,
 TRIM(SUBCAT) AS SUBCAT,
 TRIM (MAINTENANCE) AS MAINTENANCE
 FROM bronze_erp_PX_CAT_G1V2 bepcgv;
--WHERE ID  not IN (SELECT CAT_ID FROM silver_crm_prd_info scpi )
 where  
 CAT != TRIM(CAT)  
 OR SUBCAT != trim(subcat)
 or MAINTENANCE != trim (maintanence)
 
 
 SELECT distinct 
 --CAT 
 --SUBCAT
 MAINTENANCE
 FROM bronze_erp_PX_CAT_G1V2

 
 






