--Step_4

--считает общее количество покупателей из таблицы customers
select count(distinct customer_id) as customers_count from customers;


--Step_5

--отчет с продавцами у которых наибольшая выручка
select
    concat(e.first_name, ' ', e.last_name) as seller,
    count(s.product_id) as operations,
    floor(sum(p.price * s.quantity)) as income
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by s.sales_person_id, seller
order by income desc
limit 10;


--отчет с продавцами, чья выручка ниже средней выручки всех продавцов
with seller_avg as (
    select
        concat(e.first_name, ' ', e.last_name) as seller,
        floor(avg(p.price * s.quantity)) as average_income
    from sales as s
    inner join employees as e
        on s.sales_person_id = e.employee_id
    inner join products as p
        on s.product_id = p.product_id
    group by s.sales_person_id, seller
)

select * from seller_avg
where
    average_income < (
        select floor(avg(p.price * s.quantity)) as average_income
        from sales as s
        inner join products as p
            on s.product_id = p.product_id
    )
order by average_income;


--отчет с данными по выручке по каждому продавцу и дню недели
with seller_day_of_week as (
    select
        s.sale_date,
        concat(e.first_name, ' ', e.last_name) as seller,
        to_char(s.sale_date, 'id') as num_day,
        to_char(s.sale_date, 'day') as day_of_week,
        sum(p.price * s.quantity) as income
    from sales as s
    inner join employees as e
        on s.sales_person_id = e.employee_id
    inner join products as p
        on s.product_id = p.product_id
    group by
        seller,
        day_of_week,
        s.sale_date
    order by
        seller,
        num_day
)

select
    seller,
    day_of_week,
    floor(sum(income)) as income
from seller_day_of_week
group by
    day_of_week,
    seller,
    num_day
order by
    num_day, seller;

--Step_6

--отчет о количестве покупателей в разных возрастных группах: 16-25, 26-40 и 40+
select
    case
        when c.age >= 16 and c.age <= 25 then '16-25'
        when c.age > 25 and c.age <= 40 then '26-40'
        when c.age > 40 then '40+'
    end as age_category,
    count(c.customer_id) as age_count
from customers as c
group by age_category
order by age_category;


--отчет о количестве уникальных покупателей и выручке, которую они принесли
with p_s as (
    select
        s.sale_date,
        s.customer_id,
        p.price,
        s.quantity
    from sales as s
    inner join products as p
        on s.product_id = p.product_id
)

select
    case
        when
            extract(month from p_s.sale_date) < 10
            then
                concat(
                    extract(year from p_s.sale_date),
                    '-0',
                    extract(month from p_s.sale_date)
                )
        when
            extract(month from p_s.sale_date) >= 10
            then
                concat(
                    extract(year from p_s.sale_date),
                    '-',
                    extract(month from p_s.sale_date)
                )
    end as selling_month,
    count(distinct p_s.customer_id) as total_customers,
    floor(sum(p_s.price * p_s.quantity)) as income
from p_s
group by selling_month
order by selling_month;

--отчет о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0)
with first_sale as (
    select
        s.sale_date,
        concat(e.first_name, ' ', e.last_name) as seller,
        concat(c.first_name, ' ', c.last_name) as customer,
        row_number()
            over (partition by s.customer_id order by s.sale_date)
            as rn
    from sales as s
    inner join employees as e
        on s.sales_person_id = e.employee_id
    inner join products as p
        on s.product_id = p.product_id
    inner join customers as c
        on s.customer_id = c.customer_id
    where price = 0
    order by c.customer_id
)

select
    customer,
    sale_date,
    seller
from first_sale
where rn = 1;

