-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

select value, count(value) as ingredient_qty 
from final_pizza_ingredients
cross apply string_split(ordered_toppings, ',')
group by value
order by ingredient_qty desc;

