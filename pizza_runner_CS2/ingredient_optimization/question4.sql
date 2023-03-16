
-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

-- Create a function to 
-- 1. concatenate pizza_name - "exclude" and the respective toppings, and '' if the toppings is "None"
-- 2. "extra" and the respective toppings, and '' if the toppings are "None"

select order_id, customer_id,
    c.pizza_id,
    exclusions,
    extras,
    order_time,
    dbo.readablePizzaOrder(dbo.getPizzaName(p.pizza_id), c.exclusions, c.extras) as readable_pizza_order
from pizza_names as p
    join customer_orders as c
    on p.pizza_id = c.pizza_id;