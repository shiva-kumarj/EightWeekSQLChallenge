-- Analyzing diner sales using SQL
use diner_sales;
-- 1. what is the total amount each customer spent at the restaurant?
select customer_id, sum(menu.price) as total_spent
from menu as menu
join sales as sales
on menu.product_id = sales.product_id
group by customer_id
order by total_spent desc;

-- 2. how many days has each customer visited the restaurant
select customer_id, count(distinct order_date) as days_visited
from sales
group by customer_id;

-- 3. what was the first item from the menu purchased by each customer?
select customer_id, product_id from 
		(select customer_id, product_id, 
		row_number() over (partition by customer_id order by order_date) as rank
		from sales) as sub
where rank = 1
order by customer_id;

-- 4. what is the most purchased item on the menu and how many times was it purchased by all customers
with cte1 as 
(
	select product_id, count(*) as freq
	from sales
	group by product_id
),

cte2 as 
(
	select product_id, freq from cte1
	where freq = (select max(freq) from cte1)
)

select customer_id, product_name, count(*) as freq 
from sales
join menu on menu.product_id = sales.product_id
where menu.product_id = (select product_id from cte2)
group by customer_id, product_name;

-- 5. which item was the most popular for each customer
select top(3) * from 
	(
		select customer_id, product_id, count(product_id) as times_ordered
		from sales
		group by customer_id, product_id
	) as sub
order by times_ordered desc;

-- 6. which item was purchased first by the customer after they became a member
select 
	customer_id, 
	product_id, 
	order_date, 
	join_date
from  
	(select 
		members.customer_id, 
		product_id, 
		join_date, 
		order_date,
		row_number() over (partition by members.customer_id order by order_date) as order_number
	from sales
	join members on sales.customer_id = members.customer_id
	where order_date > join_date) as sub
where order_number = 1;

-- 7. which item was purchased just before the customer became a member
select customer_id, product_id, order_date, join_date
from  
	(select 
		members.customer_id, 
		product_id, 
		join_date, 
		order_date,
		row_number() over (partition by members.customer_id order by order_date) as order_number
	from sales
	join members on sales.customer_id = members.customer_id
	where order_date <= join_date) as sub
where order_number = 3;

-- 8. what is the total items and amount spend for each member before they become a member
select sales.customer_id, count(menu.product_id) as items_bought, sum(price) as total_spent
from sales 
join members on members.customer_id = sales.customer_id
join menu on menu.product_id = sales.product_id
where order_date <= join_date
group by sales.customer_id

-- 9. if each $1 spent equates to 10 points and suchi has 2x points multiplier - how many points would each customer have
select customer_id, sum(points) as total_points 
from
	(select 
		customer_id, 
		case when menu.product_name = 'sushi' then price*10*2
		else price*10*1 end as points
	from sales
	join menu on sales.product_id = menu.product_id) as sub
group by customer_id
order by total_points desc;

-- 10. In the first week after a customer joins the program they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

with jan_orders as 
(select 
	sales.customer_id, 
	sales.product_id, 
	menu.product_name,
	price, 
	order_date, 
	join_date
from sales 
join menu on menu.product_id = sales.product_id
join members on members.customer_id = sales.customer_id
where month(order_date) = 1),

points as 
(select customer_id, order_date, join_date,
case 
	when 
	order_date between join_date and dateadd(week, 1, join_date) then price*10*2
	when product_name = 'sushi' then price*10*2
	else price*10
	end as points
from jan_orders)

select customer_id, sum(points) as total_points 
from points 
group by customer_id;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Join all the things
select 
	sub_1.customer_id, 
	order_date, 
	product_name, 
	price, 
	case when join_date is not null and order_date >= join_date then 'Y' 
	else 'N' end as member
from
(
	select sales.customer_id, order_date, product_name, price
	from sales 
	join menu on menu.product_id = sales.product_id
) as sub_1
left join 
(
	select customer_id, join_date 
	from members
) as sub_2
on sub_2.customer_id = sub_1.customer_id;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Rank all things
select *, 
case when sub_3.member = 'Y' 
then rank() over 
	(
	partition by sub_3.customer_id, sub_3.member 
	order by order_date
	) 
else Null 
end as ranking
from 
(select 
	sub_1.customer_id, 
	order_date, 
	product_name, 
	price, 
	case when join_date is not null and order_date >= join_date then 'Y' 
	else 'N' end as member
	from
	(
		select sales.customer_id, order_date, product_name, price
		from sales 
		join menu on menu.product_id = sales.product_id
	) as sub_1
	left join 
	(
		select customer_id, join_date 
		from members
	) as sub_2
on sub_2.customer_id = sub_1.customer_id
) sub_3;

