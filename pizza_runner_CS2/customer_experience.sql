-- B. Runner and Customer Experience
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

with cte as 
(select runner_id, registration_date, 
datepart(week, registration_date) - datepart(week, '2021-01-01') as week_num
from runners)
select week_num, count(*) as num_runners 
from cte 
group by week_num
order by week_num;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

with cte as 
(select runner_id, order_time, pickup_time
from customer_orders as co
join runner_orders as ro
on ro.order_id = co.order_id
where pickup_time not like 'null')
select runner_id, avg(datediff(minute, order_time, cast(pickup_time as datetime))) as avg_time_minutes
from cte
group by runner_id;

-- Without using CTE
select runner_id, avg(datediff(minute, order_time, cast(pickup_time as datetime))) as avg_time_minutes
from customer_orders as co
join runner_orders as ro
on ro.order_id = co.order_id
where pickup_time != 'null'
group by runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

select distinct order_counts.order_id, num_orders, prep_time_minute from 
(select order_id, count(order_id) as num_orders
from customer_orders
group by order_id) as order_counts
join 
(select co.order_id, datediff(minute, order_time, pickup_time) as prep_time_minute
from customer_orders as co 
join runner_orders as ro 
on co.order_id = ro.order_id
where pickup_time != 'null') as prep_times
on order_counts.order_id = prep_times.order_id
order by num_orders desc;


-- 4. What was the average distance travelled for each customer?

select co.customer_id, avg(cast(distance as int)) as avg_dist_km
from customer_orders as co
join runner_orders as ro
on co.order_id = ro.order_id
where distance != 0
group by co.customer_id
order by customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders? 
-- Note: delivery time = prep_time + drive_duration(duration)

select order_id, (prep_time_minute + cast(duration as int)) as delivery_time
from 
(select co.order_id as ord_id, datediff(minute, order_time, pickup_time) as prep_time_minute
from customer_orders as co 
join runner_orders as ro 
on co.order_id = ro.order_id
where pickup_time not like 'null') as sub1
join 
(select order_id, duration 
from runner_orders
where pickup_time not like 'null') as sub2
on sub1.ord_id = sub2.order_id;

-- Optimized code
with cte1 as 
(select co.order_id, datediff(minute, order_time, pickup_time) + cast(duration as int) as delivery_time_min
from customer_orders as co
join runner_orders as ro
on co.order_id = ro.order_id
where pickup_time not like 'null')

select (max(delivery_time_min) - min(delivery_time_min)) as max_time_diff
from cte1;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
select runner_id, order_id, (cast(distance as float)*60/cast(duration as float)) as avg_speed from runner_orders
where pickup_time not like 'null'
order by pickup_time;

-- 7. What is the successful delivery percentage for each runner?

with cte1 as  
(select runner_id, count(*) as total_deliveries 
from runner_orders
group by runner_id),

cte2 as (select runner_id, count(*) as success_deliveries 
from runner_orders
where pickup_time not like 'null'
group by runner_id)

select cte1.runner_id, (success_deliveries * 100 /total_deliveries) as deli_percentage
from cte1 
join cte2 on cte1.runner_id = cte2.runner_id;

-- Optimized code
with cte1 as 
(select runner_id, 
count(*) as total_deliveries,
count(case when pickup_time not like 'null' then 1 end) as success_deliveries
from runner_orders
group by runner_id)

select runner_id, (success_deliveries * 100/total_deliveries) as success_percent 
from cte1;