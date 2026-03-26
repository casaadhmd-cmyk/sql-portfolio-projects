/*

Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.
    - FORMULA : Current  Measure - Target Measure


===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */


WITH yearly_product_sales as (

select
dp.product_name,
STRFTIME('%Y',fs.order_date) as Order_year,
sum(fs.sales_amount) as current_sales
from 
fact_sales fs 
left join dim_products dp on dp.product_key = fs.product_key 
where fs.order_date !=''
GROUP  by dp.product_name,
STRFTIME('%Y',fs.order_date)
order by  product_name,Order_year

)

select 
product_name,
Order_year,
current_sales,
AVG (current_sales) over (partition by product_name) as Avg_sales,

current_sales -AVG (current_sales) over (partition by product_name order by order_year) as diff_avg,
CASE 
	WHEN current_sales -AVG (current_sales) over (partition by product_name order by order_year)  > 0 Then 'Above Avg'
	WHEN  current_sales -AVG (current_sales) over (partition by product_name order by order_year) < 0 Then 'Below Avg'
	ELSE 'Avg'
END AS Avg_Flag,


LAG(current_sales) OVER (partition by product_name order by order_year) as py_sales,
current_sales - LAG (current_sales) OVER (partition by product_name order by order_year)  as Different_Sales,
CASE 
	WHEN current_sales - LAG(current_sales) OVER (partition by product_name order by order_year)  > 0 Then 'Increase'
	WHEN current_sales - LAG(current_sales) OVER (partition by product_name order by order_year)  < 0 Then 'Decrease'
	ELSE 'No Change'
END AS PY_Sales_Flag

From 
yearly_product_sales
order by product_name,
Order_year





