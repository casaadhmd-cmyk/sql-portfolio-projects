
/*
 * Analyse sales performance over time.
 * Formual Measure By Date 
 * YEAR, MONTH & DATETRUNC is used on the SSMS in Sqlite strftime('%Y',DATE_COLUMN),strftime('%m',DATE_COLUMN)  is used
 */


-- Analyse sales performance over time
-- Quick Date Functions
SELECT
    strftime('%Y', order_date) AS order_year,
    strftime('%m', order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY strftime('%Y', order_date), strftime('%m', order_date)
ORDER BY order_year, order_month;

--- DATE WISE GROUPING 
SELECT 
ORDER_DATE,
SUM(SALES_AMOUNT) AS SALES 

FROM 
fact_sales fs 
GROUP BY ORDER_DATE;


---YEAR WISE GRPUPING OF SALES 

SELECT 
STRFTIME('%Y',order_date) as Order_year ,
SUM (sales_amount) AS total_sales
FROM fact_sales
where order_date !=''
group  by STRFTIME('%Y',order_date)
order by total_sales desc;


---Month WISE GRPUPING OF SALES 

SELECT 
STRFTIME('%m',order_date) as Order_month ,
SUM (sales_amount) AS total_sales
FROM fact_sales
where order_date !=''
group  by STRFTIME('%m',order_date)
order by total_sales desc;

---- YEAR and MONTH WISE  SALES  GROUPING with customers  count and sum of quantity: 

SELECT 
STRFTIME('%Y', ORDER_DATE) AS order_year,
STRFTIME('%m', ORDER_DATE) AS order_month,
SUM(SALES_AMOUNT) AS Total_sales,
count (distinct customer_key) as Total_customers,
SUM (quantity) as Total_Quantity

FROM FACT_SALES
where ORDER_DATE <>''
group by
STRFTIME('%Y', ORDER_DATE), 
STRFTIME('%m', ORDER_DATE)
ORDER BY order_year ,order_month ;