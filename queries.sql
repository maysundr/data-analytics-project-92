#Step_4

#считает общее количество покупателей из таблицы customers
select count(distinct customer_id) as customers_count from customers;


#Step_5

#отчет с продавцами у которых наибольшая выручка
select concat(e.first_name, ' ',e.last_name) as seller,
COUNT(s.product_id) as operation,
floor(sum(p.price * s.quantity)) as income
from sales s
inner join employees e
on s.sales_person_id = e.employee_id
inner join products p 
on s.product_id = p.product_id
group by s.sales_person_id, seller
order by income desc
limit 10;

#отчет с продавцами, чья выручка ниже средней выручки всех продавцов
with seller_avg as (
select concat(e.first_name, ' ',e.last_name) as seller,
floor(AVG(p.price * s.quantity)) as average_income
from sales s
inner join employees e
on s.sales_person_id = e.employee_id
inner join products p 
on s.product_id = p.product_id
group by s.sales_person_id, seller
)

select * from seller_avg where average_income < (select
floor(AVG(p.price * s.quantity)) as average_income
from sales s
inner join products p 
on s.product_id = p.product_id)
order by average_income;

#отчет с данными по выручке по каждому продавцу и дню недели
with seller_day_of_week as (
select concat(e.first_name, ' ',e.last_name) as seller,
EXTRACT(DOW FROM s.sale_date) as num_day,
TO_CHAR(sale_date + 1, 'day') as day_of_week,
s.sale_date,
floor(sum(p.price * s.quantity)) as income
from sales s
inner join employees e
on s.sales_person_id = e.employee_id
inner join products p 
on s.product_id = p.product_id
group by day_of_week, s.sale_date, seller
order by seller, num_day
)

select seller, day_of_week, SUM(income) from seller_day_of_week
group by seller, day_of_week, num_day
order by num_day, seller;
