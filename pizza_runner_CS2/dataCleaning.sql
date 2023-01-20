-- A function to get numbers
Create Function dbo.GetNumbers(@Data VarChar(8000))
Returns VarChar(8000)
AS
Begin	
    Return Left(
             SubString(@Data, PatIndex('%[0-9.-]%', @Data), 8000), 
             PatIndex('%[^0-9.-]%', SubString(@Data, PatIndex('%[0-9.-]%', @Data), 8000) + 'X')-1)
End

GO

-- Cleaning customer_orders table
select order_id, exclusions, extras from customer_orders;

-- Clean 'exclusions' column of customer_orders table
update customer_orders
set exclusions = case when exclusions in ('', 'null') then null else exclusions end
where exclusions in ('', 'null');

-- Clean 'extras' column of customer_orders table
update customer_orders 
set extras = case when extras in ('', 'null') 
then null else extras end
where extras in ('', 'null');

-- Replace 'Null' with default of 0 to signify no exclusions or extras
update customer_orders 
set exclusions = case when exclusions is null then '0' else exclusions end;

update customer_orders 
set extras = case when extras is null then '0' else extras end;

-- Clean runner_orders table
-- Clean distance column
update runner_orders
set distance = dbo.GetNumbers(distance);
update runner_orders 
set distance = round(distance, 0);

-- Clean duration column
update runner_orders
set duration = dbo.GetNumbers(duration);
update runner_orders 
set duration = round(duration, 0);

-- Clean Cancellation column
update runner_orders 
set cancellation = case when cancellation in ('', 'null') then 'confirmed' else cancellation end;

update runner_orders 
set cancellation = coalesce(cancellation, 'confirmed');

update runner_orders 
set cancellation = lower(cancellation);

-- Change pizza_name column to varchar
ALTER TABLE pizza_names
ALTER COLUMN pizza_name varchar(100);

-- Adding default value of 0 to pizza_toppings to signify none.
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (0, 'None');

-- Cleaning pizza_recipes
Alter Table pizza_recipes
alter column toppings varchar(max);