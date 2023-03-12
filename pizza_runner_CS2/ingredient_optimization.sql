use PIZZA_RESTAURANT;
GO
-- C. Ingredient Optimisation
-- Function to return the ingredientName with ingredientId as input
create function dbo.getIngredientName(@ingredient_id int)
returns varchar(50)
as 
begin
    declare @ingredient_name varchar(50) = '';
    if @ingredient_id = 0
    begin
        set @ingredient_name = '';
    end
    else
    begin
        select @ingredient_name = topping_name
        from pizza_toppings
        where topping_id = @ingredient_id
    end
    return @ingredient_name;
end
GO

-- Function that takes in the ingredient_id as a comma separated value of integers and
-- returns their respective names in a comma delimited fasion. 
create function dbo.ingredientIdtoName(@ingredients_id_csv varchar(max))
returns varchar(max)
as 
begin
    declare @ingredient_names_csv varchar(max) = ''
    while len(@ingredients_id_csv) > 0
    begin
        declare @split_id int = 0;
        declare @first_comma_index int = charindex(',', @ingredients_id_csv)
        if @first_comma_index > 0
        begin
            set @split_id = left(@ingredients_id_csv, @first_comma_index - 1);
            set @ingredients_id_csv = stuff(@ingredients_id_csv, 1, @first_comma_index, '');
            set @ingredient_names_csv = @ingredient_names_csv + dbo.getIngredientName(@split_id) + ',';
        end
        else
        begin
            set @split_id = @ingredients_id_csv;
            set @ingredients_id_csv = '';
            set @ingredient_names_csv = @ingredient_names_csv + dbo.getIngredientName(@split_id);

        end
    end
    return @ingredient_names_csv
end
go

-- Function to concatenate all the inputs into a human readable format
create function dbo.readablePizzaOrder(@pizza_name varchar(20), @exclude_toppings varchar(20), @extra_toppings varchar(20))
returns varchar(100)
as
begin
    declare @pizza_order varchar(100);
    declare @exclude_tag varchar(20) = ' - Exclude ';
    declare @extra_tag varchar(20) = ' - Extra ';
    declare @exclusions varchar(20) = dbo.ingredientIdtoName(@exclude_toppings);
    declare @extras varchar(20) = dbo.ingredientIdtoName(@extra_toppings);
    if @exclusions = ''
    begin
        set @exclude_tag = '';
    end
    if @extras = ''
    begin
        set @extra_tag =  '';
    end
    set @pizza_order = concat(@pizza_name, @exclude_tag, @exclusions, @extra_tag, @extras)
    return @pizza_order
end
go

-- Function to return the pizza name by taking the pizza id as input.
create function dbo.getPizzaName(@pizza_id int)
returns varchar(20)
as
begin
    declare @pizza_name varchar(20)
    select @pizza_name = pizza_name
    from pizza_names
    where pizza_id = @pizza_id
    return @pizza_name
end
go


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

-- 2. What was the most commonly added extra?

with
    split_extras(order_id, singles, extras)
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

            where extras > ''
    )

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
    (select *
    from pizza_toppings) as pt
    on popular_toppings.single_toppings = pt.topping_id;

-- 3. What was the most common exclusion?

-- Convert the comma delimited "exclusions" column into single values
with
    exclusions(order_id, topping_id, exclusions)
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

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?