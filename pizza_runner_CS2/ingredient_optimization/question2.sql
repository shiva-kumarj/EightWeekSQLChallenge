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