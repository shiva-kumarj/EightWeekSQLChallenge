-- C. Ingredient Optimisation
-- 1. What are the standard ingredients for each pizza?

-- Convert the comma-delimited row "toppings" into individual rows.
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

-- DROP unique_recipes
IF EXISTS 
    (SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[unique_recipes]')
            AND type IN (N'U')) DROP TABLE [dbo].[unique_recipes] GO 
-- 2. What was the most commonly added extra?

with split_extras(order_id, singles, extras) 
as 
(
    select order_id,
    left(extras, charindex(',', extras + ',')-1),
    stuff(extras, 1, charindex(',', extras + ','), '')
    from customer_orders
    
    union all

    select order_id,
    left(extras, charindex(',', extras + ',')-1),
    stuff(extras, 1, charindex(',', extras + ','), '')
    from split_extras

where extras > '')

select order_id, 
cast(singles as int) as single_toppings 
into extra_toppings 
from split_extras;

select topping_name, topping_count
from 
(
    select single_toppings, 
    count(single_toppings) as topping_count
    from extra_toppings
    where single_toppings != 0
    group by single_toppings
) as popular_toppings
join 
(select * from pizza_toppings) as pt
on popular_toppings.single_toppings = pt.topping_id;

-- DROP extra_toppings
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[extra_toppings]') AND type in (N'U'))
DROP TABLE [dbo].[extra_toppings]
GO


-- 3. What was the most common exclusion?

-- Convert the comma delimited "exclusions" column into single values
with exclusions(order_id, topping_id, exclusions) 
as 
(
    select order_id, 
    left(exclusions, charindex(',', exclusions + ',')-1),
    stuff(exclusions, 1, charindex(',', exclusions + ','), '')
    from customer_orders

    union all 
    
    select order_id,
    left(exclusions, charindex(',', exclusions + ',')-1),
    stuff(exclusions, 1, charindex(',', exclusions + ','), '')
    from exclusions

    where exclusions > ''
)

-- select order_id and cast the topping_id as int before 
-- writing the result to a new table
select order_id, cast(topping_id as int) as topping_id 
into common_exclusions 
from exclusions;

-- join the previous table with the "pizza_toppings" table to 
-- get the topping_name
select topping_name, count(ce.topping_id) as times_excluded
from common_exclusions as ce, pizza_toppings
where ce.topping_id = pizza_toppings.topping_id 
and ce.topping_id != 0
group by topping_name
order by times_excluded desc;

-- DROP common_exclusions
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[common_exclusions]') AND type in (N'U'))
DROP TABLE [dbo].[common_exclusions]
GO

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

-- CTE to convert all EXCLUDED toppings into a single line each.
with cte_exclude(order_id, exclude_topping, exclusions) as 
(
    select order_id,
    left(exclusions, charindex(',', exclusions+',') - 1),
    stuff(exclusions, 1, charindex(',', exclusions + ','), '')
    from customer_orders

    union all 

    select order_id, 
    left(exclusions, charindex(',', exclusions + ',') - 1),
    stuff(exclusions, 1, charindex(',', exclusions + ','), '')
    from cte_exclude
    where exclusions > ''
)
select order_id, cast(exclude_topping as int) as exclude_topping
into exclude_table
from cte_exclude;

-- CTE to covert all EXTRA toppings into a single line each.
with cte_extras(order_id, extra_topping, extras) as 
(
    select order_id,
    left(extras, charindex(',', extras + ',') - 1),
    stuff(extras, 1, charindex(',', extras + ','), '')
    from customer_orders

    union all
    
    select order_id,
    left(extras, charindex(',', extras + ',') - 1),
    stuff(extras, 1, charindex(',', extras + ','), '')
    from cte_extras

    where extras > ''
)
select order_id, cast(extra_topping as int) as extra_topping
into extra_table
from cte_extras;


-- Incorporate topping_name along with EXTRA_TABLE
SELECT order_id,
         extra_topping,
         topping_name AS extra_top_name into extra_table_new
FROM extra_table
LEFT JOIN pizza_toppings
    ON extra_table.extra_topping = pizza_toppings.topping_id;

-- Incorporate topping_name along with EXCLUDE_TABLE
SELECT order_id,
         exclude_topping,
         topping_name AS exclude_top_name into exclude_table_new
FROM exclude_table
LEFT JOIN pizza_toppings
    ON exclude_table.exclude_topping = pizza_toppings.topping_id; 
    
select * from customer_orders;
select * from pizza_toppings;

-- joining the extra_table and exclude_table
with cte1 as 
(
    select extra_table_new.order_id, extra_top_name, exclude_top_name
    from extra_table_new 
    left join exclude_table_new
    on extra_table_new.order_id = exclude_table_new.order_id
)

select order_id, extra_top_name, exclude_top_name 
into xtra_xclud_tbl
from
(
    select *, 
    row_number() over(
        partition by order_id, extra_top_name, exclude_top_name
        order by order_id) as row_num
from cte1
) as subq
where row_num < 2;

-- join the individual extra and exclusions table with customer_orders table
SELECT *
FROM 
    (SELECT x.order_id,
         customer_id,
         extra_top_name,
         exclude_top_name,
         order_time,
         row_number()
        OVER ( partition by x.order_id, extra_top_name, exclude_top_name, order_time
    ORDER BY  x.order_id ) AS row_num
    FROM xtra_xclud_tbl AS x
    RIGHT JOIN customer_orders AS c
        ON x.order_id = c.order_id ) AS sub1
WHERE row_num < 2; 


-- DROP extra_table
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[extra_table]') AND type in (N'U'))
DROP TABLE [dbo].[extra_table]
GO


-- DROP extra_table_new
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[extra_table_new]') AND type in (N'U'))
DROP TABLE [dbo].[extra_table_new]
GO

-- DROP exclude_table_new
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[exclude_table_new]') AND type in (N'U'))
DROP TABLE [dbo].[exclude_table_new]
GO

-- DROP xtra_xclud_tbl
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xtra_xclud_tbl]') AND type in (N'U'))
DROP TABLE [dbo].[xtra_xclud_tbl]
GO

-- DROP exclude_table
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[exclude_table]') AND type in (N'U'))
DROP TABLE [dbo].[exclude_table]
GO


-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?