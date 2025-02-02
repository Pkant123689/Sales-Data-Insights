
select * from df_orders
--1.find top 10 highest reveue generating products 
select top 10  product_id, sum(sale_price) as total_sale
from df_orders
group by product_id
order by total_sale desc

--2.find top 5 highest selling products in each region
with reg_prod_sales as(
select region, product_id, sum(sale_price) as total_sales
from df_orders
group by region, product_id
),
rank_sales as (
 select *, row_number() over(partition by region order by total_sales desc) as ranking
 from reg_prod_sales
 )
 select *  from rank_sales
 where ranking <=5

 --3.find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

with cte as (
select year(order_date) as order_year, month(order_date) as order_month, sum(sale_price) as sales_total
from df_orders
group by year(order_date), month(order_date)
)
select order_month, sum(case when order_year = 2023 then sales_total else 0 end) as sale_2023,
sum(case when order_year = 2022 then sales_total else 0 end) as sale_2022
from
cte
group by order_month
order by order_month 

--4.for each category which month had highest sales 

with cat_month_sales as(
select category, format(order_date,'yyyyMM') as order_year_month, sum(sale_price) as sales_total
from df_orders
group by category, format(order_date,'yyyyMM') 
),
rank_sales as(
select *, row_number() over(partition by category order by sales_total desc) as ranking
from cat_month_sales
)
select * from rank_sales
where ranking = 1


--5. which sub category had highest growth by profit in 2023 compare to 2022

 with cte as (
select sub_category,year(order_date) as order_year,
sum(sale_price) as sales
from df_orders
group by sub_category,year(order_date)
)
, cte2 as (
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
select top 1 *
,(sales_2023-sales_2022)
from  cte2
order by (sales_2023-sales_2022) desc