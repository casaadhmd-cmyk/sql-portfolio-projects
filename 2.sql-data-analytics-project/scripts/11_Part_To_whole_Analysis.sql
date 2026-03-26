/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.
     - FORMULA:  Measure /Total Measure * 100  By dimension

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/
-- Which categories contribute the most to overall sales?

with category_sales as (
Select 
category,
sum (Sales_amount) as Total_sales
From 
dim_products P
left join fact_sales s ON P.product_key = S.product_key  
where category != '' 
Group by 
category
)

select 
category,
Total_sales,
sum(Total_sales) over () as Overall_sales,  ---To Get the Total sales of all category

ROUND (cast (Total_sales as Float)/sum(Total_sales) over () * 100,2) as Percentage


From 
category_sales
order by Total_sales desc;


