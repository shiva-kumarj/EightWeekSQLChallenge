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
