/*
 * Exploration of Date For Analytics 
 * dim_customers  - birthdate is Dimnension but if we convert that to age then its Measure 
 * dim_products  -   start_date - When the product started selling and what it was the price
 * fact_sales - order_date , shipping_date , due_date 
 */

---------------------------------------------------------------------------------

select * from  dim_customers dc limit 5;

select distinct customer_number, birthdate,
DATEDIFF(year,birthdate,CURRENT_TIMESTAMP) AS AGE   ---work in SSMS
from dim_customers;


---------------------------------------------------------------------------------

select * from dim_products dp  limit 5 ;

SELECT 
/*
PRODUCT_NUMBER,
PRODUCT_NAME,
CATEGORY,
SUBCATEGORY,
PRODUCT_LINE,
*/
MIN (START_DATE) AS FIRST_START_DATE,
MAX(START_DATE) AS  RECENT_START_DATE

from dim_products

---------------------------------------------------------------------------------


select 
MIN (ORDER_DATE) AS FIRST_ORDER_DATE,
MAX (ORDER_DATE) AS RECENT_ORDER_DATE,

MIN (SHIPPING_DATE) AS FIRST_SHIPPING_DATE,
MAX (SHIPPING_DATE) AS RECENT_SHIPPING__DATE,


MIN (DUE_DATE) AS FIRST_DUE_DATE,
MAX (DUE_DATE) AS RECENT_DUE_DATE

from fact_sales fs

limit 5 ;
