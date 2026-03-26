/*

-- Which 5 products Generating the Highest Revenue? 

-- What are the 5 worst-performing products in terms of sales?
-- Find the top 10 customers who have generated the highest revenue
*/


select 
    dp.product_name,
	sum (sales_amount) as sales
	
	from fact_sales s 
	left join dim_products dp   on s.product_key = dp.product_key 
	group by 
	dp.product_name 
	order by sales desc limit 5 
	
-- With Windows Functions : 
	
	select * from
	(
	select 
    dp.product_name,
	sum (s.sales_amount) as sales,
	dense_rank () over (order by sum (s.sales_amount) desc) as Ranking_product
	
	from fact_sales s 
	left join dim_products dp   on s.product_key = dp.product_key 
	group by 
	 dp.product_name
	 )  t 
	 where Ranking_product <=5
	 
	
	
-- What are the 5 worst-performing products in terms of sales?	
	select 
    dp.product_name,
	sum (sales_amount) as sales
	
	from fact_sales s 
	left join dim_products dp   on s.product_key = dp.product_key 
	group by 
	dp.product_name 
	order by sales asc limit 5 
	 
	 
	 
	---WITH THE WINDOW'S FUNCTIONS : 
	 	select * from
	(
	select 
    dp.product_name,
	sum (s.sales_amount) as sales,
	dense_rank () over (order by sum (s.sales_amount) asc) as Ranking_product
	
	from fact_sales s 
	left join dim_products dp   on s.product_key = dp.product_key 
	group by 
	 dp.product_name
	 )  t 
	 where Ranking_product <=5
	 
	 
	 
	 
	 -- Find the top 10 customers who have generated the highest revenue
SELECT 
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
LEFT JOIN dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC limit 10 ;

-- The 3 customers with the fewest orders placed
SELECT 
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_orders
FROM  fact_sales f
LEFT JOIN dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders limit 5 ;
	