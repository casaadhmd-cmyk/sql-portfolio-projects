/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value >> Formula : Total Sales / Total no of orders
		- average monthly spend
===============================================================================
*/

--CREATE VIEW customer_report AS 

with base_query as (
select
s.order_number,
s.product_key,
s.order_date,
s.sales_amount,
s.quantity,
c.customer_key,
c.customer_number,
CONCAT (c.first_name ,' ',c.last_name)as customer_name,
birthdate,
CAST(STRFTIME('%Y','now') AS INTEGER) 
- CAST(STRFTIME('%Y', birthdate) AS INTEGER)
- (STRFTIME('%m-%d','now') < STRFTIME('%m-%d', birthdate))
AS age

from 
fact_sales s
left join dim_customers c 
on s.customer_key =c.customer_key 

)

,customer_aggregation as  (

select 
customer_key,
customer_number,
customer_name,
age,
count(distinct order_number) as total_orders,
SUM(sales_amount) AS total_sales,
sum(quantity) as total_quantity,
count (distinct product_key) as total_products,
max (order_date) as last_order_date,
(
CAST(STRFTIME('%Y', MAX(order_date)) AS INTEGER) - 
CAST(STRFTIME('%Y', MIN(order_date)) AS INTEGER)
) * 12 +

(
CAST(STRFTIME('%m', MAX(order_date)) AS INTEGER) - 
CAST(STRFTIME('%m', MIN(order_date)) AS INTEGER)
) as lifespan
 
From base_query

group by
customer_key,
customer_number,
customer_name,
age

) 

select 
customer_key,
customer_number,
customer_name,
age,

CASE 
	 WHEN age < 20 THEN 'Under 20'
	 WHEN age between 20 and 29 THEN '20-29'
	 WHEN age between 30 and 39 THEN '30-39'
	 WHEN age between 40 and 49 THEN '40-49'
	 ELSE '50 and above'
END AS age_group,

CASE 
    WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
    WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
    ELSE 'New'
END AS customer_segment,

last_order_date,
(
CAST(STRFTIME('%Y','now') AS INTEGER) - CAST(STRFTIME('%Y', last_order_date) AS INTEGER)
) * 12 +

(
CAST(STRFTIME('%m','now') AS INTEGER) - CAST(STRFTIME('%m', last_order_date) AS INTEGER)
) AS recency_months,

Total_orders,
total_sales,
total_quantity,
total_products
lifespan,
-- Compuate average order value (AVO)
CASE WHEN total_sales = 0 THEN 0
	 ELSE total_sales / total_orders
END AS avg_order_value,

-- Compuate average monthly spend
CASE WHEN lifespan = 0 THEN total_sales
     ELSE total_sales / lifespan
END AS avg_monthly_spend
FROM customer_aggregation

