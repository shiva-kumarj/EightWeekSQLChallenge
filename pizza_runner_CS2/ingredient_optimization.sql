-- C. Ingredient Optimisation
-- 1. What are the standard ingredients for each pizza?
select * from pizza_toppings;

with split_recipes(pizza_id, ingredient, toppings) as 
(
    select pizza_id, 
            left(toppings, charindex(',', toppings + ',') - 1),
            stuff(toppings, 1, charindex(',', toppings + ','), '')
            from pizza_recipes

    union all

    select pizza_id, 
            left(toppings, charindex(',', toppings + ',') - 1),
            stuff(toppings, 1, charindex(',', toppings + ','), '')
            from split_recipes
    where toppings > ''
)
select pizza_id, ingredient into unique_recipes
from split_recipes
order by pizza_id;

select * from unique_recipes;

select pizza_id, cast(ingredient as int) as ing, ingredient 
from unique_recipes;
-- 2. What was the most commonly added extra?
-- 3. What was the most common exclusion?
-- 4. .Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?