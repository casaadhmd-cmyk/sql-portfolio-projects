/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/*Segment products into cost ranges and 
count how many products fall into each segment*/

with cost_segementation as (
select 

product_key,
product_name,
cost,
case 
	when  cost < 100 then 'Below 100 '
	when  cost between 100 and 500 then '100-500'
	when  cost between 500 and 1000 then '500-1000'
	else  'Above 1000'
end as cost_range

from 
   dim_products 
)

select 
cost_range,
count(product_name) as total_products
from cost_segementation
group by cost_range
order by  total_products



/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/

with customer_spending AS (
select 
fs.customer_key,
SUM(fs.sales_amount) as Customer_spending,
MIN(fs.order_date)as first_order_dt,
MAX(fs.order_date) as last_order_dt,

(
CAST(STRFTIME('%Y', MAX(fs.order_date)) AS INTEGER) - 
CAST(STRFTIME('%Y', MIN(fs.order_date)) AS INTEGER)
) * 12 +

(
CAST(STRFTIME('%m', MAX(fs.order_date)) AS INTEGER) - 
CAST(STRFTIME('%m', MIN(fs.order_date)) AS INTEGER)
) as life_span_months

from fact_sales fs 
left join dim_customers dc on fs.customer_key =dc.customer_key 
Group by fs.customer_key
)

select 
count (customer_key) as total_customers,
customer_segment
From 
(

select 
customer_key,
case 
	When life_span_months >=12  and Customer_spending > 5000 Then 'VIP'
	when life_span_months >= 12 and customer_spending <= 5000 Then 'Regular'
	else 'New'
	
end As customer_segment
from customer_spending
)
Group by customer_segment
Order by total_customers;





