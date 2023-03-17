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



-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for 
-- extras and each runner is paid $0.30 per kilometre traveled - how much money does 
-- Pizza Runner have left over after these deliveries?