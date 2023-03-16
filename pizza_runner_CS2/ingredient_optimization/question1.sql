
-- 1. What are the standard ingredients for each pizza?

-- Convert the comma-delimited row "toppings" into individual rows.
with
    split_recipes(pizza_id, ingredient, toppings)
    as
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
select pizza_id, cast(ingredient as int) as ingredient
into unique_recipes
from split_recipes
order by pizza_id;

-- separate the pizza_ids into 2 different tables and join them on the ingredient.
-- This will give us only the ingredients that are common between the pizzas. 
SELECT topping_name AS common_ingredients
FROM
    (SELECT pizza_2.ingredient
    FROM
        (SELECT pizza_id,
            ingredient
        FROM unique_recipes
        WHERE pizza_id = 1 ) AS pizza_1
        INNER JOIN
        (SELECT pizza_id,
            ingredient
        FROM unique_recipes
        WHERE pizza_id = 2 ) AS pizza_2
        ON pizza_1.ingredient = pizza_2.ingredient) AS basic_ingredients
    JOIN pizza_toppings
    ON pizza_toppings.topping_id = basic_ingredients.ingredient;
