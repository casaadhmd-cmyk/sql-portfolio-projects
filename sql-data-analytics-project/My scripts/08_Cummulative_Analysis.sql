
/*
 * Cummulative Analysis : 
 * Formula : Cummulative measure / Date Dimension
 * Running Total sales Analysis  by year (Y-O-Y)
 * Moving Average Analysis
 * Calculate the Total sales per month and running total of sales over the time
 * Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

 */

SELECT
order_date,
total_sales,
SUM(total_sales) OVER (order by order_date ) As Running_Total, ---partition by order_date  for the year it will start as 1st
AVG (avg_price) over ( order by order_date) AS Moving_Average

From 
(
SELECT 
date(order_date, 'start of Month')as order_date, ---IN SSMS DATETRUNC(MONTH/YEAR , ORDER DATE)
SUM (sales_amount) AS total_sales,
ROUND(AVG(PRICE),1) as avg_price
FROM fact_sales
where order_date !=''
group  by 
 date(order_date, 'start of month')
 ) A 
