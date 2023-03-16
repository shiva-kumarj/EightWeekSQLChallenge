-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

-- This joins the pizza orders from customers with the pizza recipes
with cte1 as 
(
    -- This case statement concatenates the extras with the toppings, separating them with a comma
    -- If there are no extras, it simply uses the toppings
    select c.order_id, customer_id, c.pizza_id, exclusions, 
    extras, order_time,  
    case when extras = '0' then toppings
    else concat(extras, ',', toppings)
    end as toppings_intr 
    from customer_orders as c
    join pizza_recipes as p
    on c.pizza_id = p.pizza_id
)

-- This query returns the final list of toppings for each pizza order, excluding any toppings specified in the exclusions list
-- The result table is put into 
select *,
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
into final_pizza_ingredients
from cte1;

-- 1. Using result of above query form a list of final ingredients in each order_id
-- 2. convert comma separated values of topping_id into ingredient names
-- Adding a new column "topping_names" to hold the pizza ingredient names
alter table final_pizza_ingredients
add topping_names varchar(max);
GO

-- Put the topping names in the respective column
update final_pizza_ingredients
set topping_names = (select dbo.ingredientIdtoName(final_pizza_toppings))
where order_id in (select order_id from final_pizza_ingredients);

-- 3. Sort the ingredient names alphabetically. 
-- put the sorted ingredients in a column "ordered_toppings"

alter table final_pizza_ingredients
add ordered_toppings varchar(max);    
GO

update final_pizza_ingredients
set ordered_toppings = 
(
    select string_agg (value, ',') within group(order by value)
    from string_split(topping_names, ',')
)
GO

-- Dropping redundant columns
alter table final_pizza_ingredients
drop column toppings_intr, final_pizza_toppings, topping_names;
GO

-- Alter the table to add an identity column to it
alter table final_pizza_ingredients
add pk int identity(1, 1); 
GO

-- Joining the ordered and numbered toppings with the final_pizza_ingredients
select * from
(
    select order_id, customer_id, 
    pizza_id, exclusions, extras,
    order_time, ordered_toppings, pk
    from final_pizza_ingredients 
) as sub3

join

(
    select distinct pk, string_agg(numbered_ingredients, ',') as numbered_ingredients
    from
    (
        select pk,
        case when count(value) > 1 then concat(count(value), 'x', value)
        else value end as numbered_ingredients
        from final_pizza_ingredients
        cross apply string_split(ordered_toppings, ',')
        group by value, pk 
    ) as sub1
    group by pk
) as sub2

on sub2.pk = sub3.pk;


-- -------------------------------------------------------------------

alter table customer_orders
add pk int identity(1, 1);
GO

-- Same result but with the customer_orders table. 
select order_id, customer_id,
pizza_id, exclusions, extras, order_time, numbered_ingredients
from 
(
    select * from customer_orders
    join 

    (
        select distinct pk as temp_pk, string_agg(numbered_ingredients, ',') as numbered_ingredients
        from
        (
            select pk,
            case when count(value) > 1 then concat(count(value), 'x', value)
            else value end as numbered_ingredients
            from final_pizza_ingredients
            cross apply string_split(ordered_toppings, ',')
            group by value, pk 
        ) as sub1
        group by pk
    ) as sub2
    on customer_orders.pk = sub2.temp_pk
) as sub5;

alter table customer_orders
drop column pk;
GO