-- EXECUTE THE dataCleaning.sql script before executing these queries.
-- A. Pizza Metrics
-- 1. How many pizzas were ordered?
select count(order_id) as num_pizzas_ordered from customer_orders;

-- 2. How many unique customer orders were made?
select count(distinct order_id) as unique_orders
from customer_orders;

-- 3. How many successful orders were delivered by each runner?

select runner_id, count(*) as orders_delivered 
from runner_orders
where pickup_time not like 'null'
group by runner_id;

-- 4. How many of each type of pizza was delivered?

select pizza_name, count(runner_orders.order_id) as order_count
from customer_orders 
left join runner_orders on customer_orders.order_id = runner_orders.order_id
join pizza_names on pizza_names.pizza_id = customer_orders.pizza_id
where pickup_time not like 'null'
group by pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

select customer_id, pizza_name, count(*) as count
from customer_orders 
join pizza_names on pizza_names.pizza_id = customer_orders.pizza_id
group by customer_id, pizza_name
order by customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?

select order_id, count(*) as max_pizzas_in_one_order 
from customer_orders
group by order_id
order by 2 desc;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select customer_id, 
count(
    case when exclusions like '0' and extras like '0' 
    then 1 
    else null end) as original, 
count(
    case when exclusions not like '0' or extras not like '0' 
    then 1 
    else null end) as modified
from customer_orders 
left join runner_orders on customer_orders.order_id = runner_orders.order_id
where cancellation like 'confirmed'
group by customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?

select count(*) as count 
from customer_orders
where exclusions not like '0' and extras not like '0';

-- 9. What was the total volume of pizzas ordered for each hour of the day?
select hour, count(*) as volume from 
(select datepart(hour, order_time) as hour, order_id from customer_orders) as sub
group by hour;

-- 10. What was the volume of orders for each day of the week?
select day_of_week, count(*) as volume from 
(select datepart(weekday, order_time) as day_of_week, order_id from customer_orders) as sub
group by day_of_week;