/* 
 * CREATE DATABASES DWH_ANALYTICS 
 * As this is done in Debeaver the above will not work
 *  BULK INSERT TABLE NAME 
     FROM  : C:\Users\mohammed.saadh.ASCENDION\OneDrive - ascendion\Desktop\SQL ASSINGMENTS\sql-data-analytics-project\datasets\flat-files\ _file name.csv_.
     (
     firstrow = 2,
     delimeter =',',  
     tablock )
     
     The above will not work as its NOT the SSMS so import the csv file from the folder this tables
 */



CREATE TABLE dim_customers (

customer_key   INTEGER PRIMARY KEY,
customer_id  INTEGER,
customer_number  TEXT,
first_name  TEXT,
last_name  TEXT,
country  TEXT ,
marital_status  TEXT,
gender TEXT,
birthdate  NUMERIC,
create_date  NUMERIC CURRENT_TIMESTAMP
) ;

GO

--DROP TABLE dim_customers

--SELECT * FROM dim_customers

CREATE TABLE dim_products
(

product_key INTEGER PRIMARY KEY ,
product_id INTEGER ,
product_number TEXT ,
product_name TEXT,
category_id TEXT,
category TEXT,
subcategory TEXT,
maintenance TEXT,
cost NUMERIC
product_line TEXT,
start_date NUMERIC

);

GO 
--SELECT * FROM dim_products





CREATE TABLE fact_sales (

order_number TEXT PRIMARY KEY,
product_key INTEGER,
customer_key INTEGER ,
order_date NUMERIC,
shipping_date NUMERIC,
due_date NUMERIC,
sales_amount INTEGER,
quantity INTEGER ,
price INTEGER

)
;

--select * from fact_sales

---DROP TABLE fact_sales