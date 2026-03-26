/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================
--create view  Product_Report as 

with customer_matrics as (
select 
s.order_number,
s.order_date,
s.customer_key,
s.sales_amount,
s.quantity,
p.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost
From 
fact_sales s
left join dim_products p on s.product_key =p.product_key 
where s.order_date  !=''
)

,Aggergate_product_matrics as (

select 
product_key,
product_name,
category,
subcategory,
cost,
(
CAST(STRFTIME('%Y', MAX(order_date)) AS INTEGER) - 
CAST(STRFTIME('%Y', MIN(order_date)) AS INTEGER)
) * 12 +

(
CAST(STRFTIME('%m', MAX(order_date)) AS INTEGER) - 
CAST(STRFTIME('%m', MIN(order_date)) AS INTEGER)
) AS lifespan,
max(order_date) as last_sale_date,
count (distinct order_number) as total_orders,
count (distinct customer_key) as total_customers,
sum (sales_amount) as total_sales,
sum  (quantity) as Total_quantity,
ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price

FROM customer_matrics

GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    cost
)

/*---------------------------------------------------------------------------
  3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------*/
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	 -- Recency in Months (SQLite version)
    (
    CAST(STRFTIME('%Y','now') AS INTEGER) - 
    CAST(STRFTIME('%Y', last_sale_date) AS INTEGER)
    ) * 12 +
    (
    CAST(STRFTIME('%m','now') AS INTEGER) - 
    CAST(STRFTIME('%m', last_sale_date) AS INTEGER)
    ) AS recency_in_months,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	-- Average Order Revenue (AOR)
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue,

	-- Average Monthly Revenue
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_revenue

FROM Aggergate_product_matrics 