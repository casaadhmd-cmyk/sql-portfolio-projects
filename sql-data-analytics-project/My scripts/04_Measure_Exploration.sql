


select 
m.name as 'Table_Name',
p.name  as 'column_name',
p.type as 'data_type',
P.pk as primary_key


from 
sqlite_master m 
join pragma_table_info(m.name) P
where m.type='table'
and p.type='INTEGER'  -- TO KNOW THE MEASURE (INTEGER)
order by   m.name, p.cid


select * from fact_sales limit 5 ;
select * from dim_products limit 5 ;
select * from dim_customers  limit 5 ;

-- Find the Total sales ;
select sum(sales_amount ) as total_sales from fact_sales;

-- Find the How many items are sold ;
select sum(quantity) as total_item_sold from fact_sales;

--find the averge selling price 
select AVG (price) AS Average_selling_price from fact_sales;


-- find the total number od orders
select count (order_number) as total_orders from fact_sales;

select count (distinct order_number) as total_orders from fact_sales;


-- find the Total number of products
select count(distinct product_name) from dim_products;


-- find the total number of customers
select count (distinct customer_number) as total_customer from dim_customers;


-- customer that placed an order ;
select count (distinct customer_key) as total_customer_placed from fact_sales;



-- To generate a Report Count of the summary :

select 'Total_Sales'  as Measure_name ,sum(sales_amount ) As Measure_Value from fact_sales
UNION ALL
select 'Total_Quantity' ,sum(quantity)  from fact_sales
UNION ALL 
select 'Total_Orders',count (distinct order_number)  from fact_sales
UNION ALL 
select 'Total_Product',count(distinct product_name) from dim_products
UNION ALL 
select 'Total_customer', count (distinct customer_number) from dim_customers
UNION ALL 
select 'Total_customer_placed',count (distinct customer_key)   from fact_sales;










