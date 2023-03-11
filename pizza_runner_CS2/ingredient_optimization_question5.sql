-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

-- This joins the pizza orders from customers with the pizza recipes
with cte1 as 
(
    -- This case statement concatenates the extras with the toppings, separating them with a comma
    -- If there are no extras, it simply uses the toppings
    select c.pizza_id, extras, exclusions, 
    case when extras = '0' then toppings
    else concat(extras, ',', toppings)
    end as toppings_intr 
    from customer_orders as c
    join pizza_recipes as p
    on c.pizza_id = p.pizza_id
)

-- This query returns the final list of toppings for each pizza order, excluding any toppings specified in the exclusions list
select pizza_id,
(
    -- This subquery uses the STRING_SPLIT function to split the toppings_intr and exclusions columns into separate values
    -- It then filters out any values that appear in the exclusions list
    select string_agg(value, ',') 
    from
    (
        select value from string_split(toppings_intr, ',')
        where value not in (select value from string_split(exclusions, ','))
    ) as t
) as final_pizza_toppings
from cte1;





-- 1. Using result of above query form a list of final ingredients in each order_id
-- 2. convert comma separated values of topping_id into ingredient names
-- 3. Sort the ingredient names alphabetically.
-- 4. Use window function of width 2 and if 2 elements in the window are the same then, 
-- shorten that into "2x<ingredient>"


