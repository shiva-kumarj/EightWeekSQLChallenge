-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
-- how much money has Pizza Runner made so far if there are no delivery fees?
-- 

select sum(price) as total_revenue
from 
(
    select order_id, co.pizza_id, pizza_name,
    case when pizza_name = 'Meatlovers' then 12 else
    10 end as price
    from customer_orders as co
    join pizza_names as pn
    on co.pizza_id = pn.pizza_id
) as sub;

-- 2. What if there was an additional $1 charge for any pizza extras?
--  Add cheese is $1 extra
select sum(total_revenue) as total_revenue
from
(
    select *, (price + extra_price) as total_revenue
    from
    (
        select order_id, co.pizza_id, pizza_name, extras,
        case when pizza_name = 'Meatlovers' then 12 else
        10 end as price,
        case when len(extras) > 1 then len(replace(extras, ',', ''))
        when extras = 0 then 0
        else 1 end as extra_price
        from customer_orders as co
        join pizza_names as pn
        on co.pizza_id = pn.pizza_id
    ) as sub
)sub2;


-- 3. The Pizza Runner team now wants to add an additional ratings system that allows 
-- customers to rate their runner, how would you design an additional table for this 
-- new dataset - generate a schema for this new table and insert your own data for 
-- ratings for each successful customer order between 1 to 5.
create table runner_rating
(
    "order_id" integer,
    "runner_id" integer,
    "rating" integer not null 
        check(rating > 0 and rating < 6)
)

insert into runner_rating(order_id, runner_id, rating)
values (1, 1, 4),
(2, 1, 2),
(3, 1, 5),
(4, 2, 5),
(5, 3, 1),
(6, 3, 3),
(7, 2, 4),
(8, 2, 4), 
(9, 2, 5),
(10, 1, 4);


-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas

select customer_id, co.order_id, 
runner_id, order_time, pickup_time,
cast(datepart(minute, (pickup_time - order_time)) as varchar(max)) + 
    ':' + 
cast(datepart(second, (pickup_time - order_time)) as varchar(max)) as prep_time,
duration, 
cast(distance as float)/(cast(duration as float)/60) as avg_speed,
count(co.order_id) over (order by co.order_id) as pizzas_delivered
from customer_orders as co
join runner_orders as ro
on co.order_id = ro.order_id
where pickup_time != 'null';

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for 
-- extras and each runner is paid $0.30 per kilometre traveled - how much money does 
-- Pizza Runner have left over after these deliveries?

select sum(pizza_price - delivery_charge) as final_price
from 
(
    select co.order_id, runner_id, 
    cast(distance as int) as distance,
    pizza_name,
    case when pizza_name = 'Meatlovers' then 12
    else 12 end as pizza_price,
    round(cast(distance as float) * 0.3, 2) as delivery_charge
    from runner_orders as ro
    join customer_orders as co
    on ro.order_id = co.order_id
    join pizza_names as pn
    on pn.pizza_id = co.pizza_id
    where distance != '0'
) as sub;

-- E. Bonus Questions
-- If Danny wants to expand his range of pizzas - how would this 
-- impact the existing data design? Write an INSERT statement 
-- to demonstrate what would happen if a new Supreme pizza with 
-- all the toppings was added to the Pizza Runner menu?

-- Adding supreme pizza to pizza_recipes and pizza_names tables
insert into pizza_recipes(pizza_id, toppings)
values (3, '1,2,3,4,5,6,7,8,9,10,11,12');
insert into pizza_names(pizza_id, pizza_name)
values (3, 'Supreme');

-- Additionally some customers might order these pizzas to
-- corresponding entries in the customer_order and runner_orders 
-- table must be made.