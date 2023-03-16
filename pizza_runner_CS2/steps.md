# Data Cleaning and Manipulation

I wrote a SQL script that performs data cleaning and manipulation on various columns in multiple tables such as `customer_orders`, `runner_orders`, `pizza_names`, and `pizza_toppings`. I first selected specific columns and then performed various operations such as:
- Setting null values to certain columns 
- Replacing null values with a default of '0' 
- Cleaning and formatting columns by calling custom functions, and 
- Inserting a new row and altering the data type of certain columns from `text` to `varchar`.
- Removing duplicate rows

I also utilized various SQL functions such as `round`, `coalesce`, and `lower` to format and standardize the data in the columns.

## A. Pizza Analytics
1. The total number of pizzas ordered is: `14`
2. The total number of unique customer orders made is: `10`
3. The number of successful orders delivered by each runner is as follows
    | runner_id | orders_delivered |
    |---------- |------------------|
    | 2         | 3                |
    | 1         | 4                |
    | 3         | 1                |
    

4. The number of each type of pizza delivered is as follows:

    | pizza_name | order_count |
    |:-----------|:------------|
    | Meatlovers | 9           |
    | Vegetarian | 3           |
    
5. The number of Vegetarian and Meatlovers ordered by each customer is as follows:

    | customer_id | pizza_name   | count |
    |-------------|--------------|-------|
    | 101         | Meatlovers   | 2     |
    | 101         | Vegetarian   | 1     |
    | 102         | Meatlovers   | 2     |
    | 102         | Vegetarian   | 1     |
    | 103         | Meatlovers   | 3     |
    | 103         | Vegetarian   | 1     |
    | 104         | Meatlovers   | 3     |
    | 105         | Vegetarian   | 1     |
    
6. The maximum number of pizzas delivered in a single order is: 


    | order_id | max_pizzas_in_one_order |
    |----------|------------------------|
    | 4        | 3                      |
    | 3        | 2                      |
    | 10       | 2                      |
    | 1        | 1                      |
    | 2        | 1                      |
    | 5        | 1                      |
    | 6        | 1                      |
    | 7        | 1                      |
    | 8        | 1                      |
    | 9        | 1                      |
    
7. For each customer, the number of delivered pizzas with at least 1 change and the number with no changes is as follows:

    | customer_id | original | modified |
    |-------------|----------|----------|
    | 101         | 2        | 0        |
    | 102         | 3        | 0        |
    | 103         | 0        | 3        |
    | 104         | 1        | 2        |
    | 105         | 0        | 1        |
    
8. The total number of pizzas delivered that had both exclusions and extras is: `2`

9. The total volume of pizzas ordered for each hour of the day is as follows:

    | hour | volume |
    |------|--------|
    | 11   | 1      |
    | 13   | 3      |
    | 18   | 3      |
    | 19   | 1      |
    | 21   | 3      |
    | 23   | 3      |
    
10.  The volume of orders for each day of the week is as follows:
    | day_of_week | volume |
    |-------------|--------|
    | 4           | 5      |
    | 5           | 3      |
    | 6           | 1      |
    | 7           | 5      |
    
## B. Runner and Customer Experience

1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
    | week_num | num_runners |
    |----------|-------------|
    | 0        | 1           |
    | 1        | 2           |
    | 2        | 1           |
    
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
    | runner_id | avg_time_minutes |
    |-----------|------------------|
    | 1         | 15               |
    | 2         | 24               |
    | 3         | 10               |
    
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
    | order_id | num_orders | prep_time_minute |
    |----------|------------|------------------|
    | 4        | 3          | 30               |
    | 3        | 2          | 21               |
    | 10       | 2          | 16               |
    | 1        | 1          | 10               |
    | 2        | 1          | 10               |
    | 5        | 1          | 10               |
    | 7        | 1          | 10               |
    | 8        | 1          | 21               |
    

4. What was the average distance travelled for each customer?
    | customer_id | avg_dist_km |
    |-------------|-------------|
    | 101         | 20          |
    | 102         | 16          |
    | 103         | 23          |
    | 104         | 10          |
    | 105         | 25          |
    
5. What was the difference between the longest and shortest delivery times for all orders?
    | order_id | delivery_time |
    |----------|---------------|
    | 1        | 42            |
    | 2        | 37            |
    | 3        | 41            |
    | 3        | 41            |
    | 4        | 70            |
    | 4        | 70            |
    | 4        | 70            |
    | 5        | 25            |
    | 7        | 35            |
    | 8        | 36            |
    | 10       | 26            |
    | 10       | 26            |
    
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
    | runner_id | order_id | avg_speed |
    |-----------|----------|-----------|
    | 1         | 1        | 37.5      |
    | 1         | 2        | 44.444444 |
    | 1         | 3        | 39        |
    | 2         | 4        | 34.5      |
    | 3         | 5        | 40        |
    | 2         | 7        | 60        |
    | 2         | 8        | 92        |
    | 1         | 10       | 60        |
    
7. What is the successful delivery percentage for each runner?
    | runner_id | success_percent |
    |-----------|-----------------|    
    | 1         | 100             |
    | 2         | 75              |
    | 3         | 50              |

## C. Ingredient Optimization

1. What are the standard ingredients for each pizza?

    | Ingredients |
    | --- |
    | Cheese |
    | Mushrooms |

2. What was the most commonly added extra?

    | Topping Name | Topping Count |
    | --- | --- |
    | Bacon | 4 |
    | Cheese | 1 |
    | Chicken | 1 |

3. What was the most common exclusion?

    | Topping Name  | Times Excluded |
    | ---           | ---:           |
    | Cheese        | 3              |
    | Mushrooms     | 1              |
    | BBQ Sauce     | 1              |

4. Generate an order item for each record in the customers_orders table in the format of one of the following:

    ### Meat Lovers
    ### Meat Lovers - Exclude Beef
    ### Meat Lovers - Extra Bacon
    ### Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers


    | Order ID | Customer ID | Pizza ID | Exclusions | Extras | Order Time | Readable Pizza Order |
    | --- | --- | --- | --- | --- | --- | --- |
    | 1 | 101 | 1 | 0 | 0 | 2020-01-01 18:05:02.000 | Meatlovers |
    | 2 | 101 | 1 | 0 | 0 | 2020-01-01 19:00:52.000 | Meatlovers |
    | 3 | 102 | 1 | 0 | 0 | 2020-01-02 23:51:23.000 | Meatlovers |
    | 3 | 102 | 2 | 0 | 0 | 2020-01-02 23:51:23.000 | Vegetarian |
    | 4 | 103 | 1 | 4 | 0 | 2020-01-04 13:23:46.000 | Meatlovers - Exclude Cheese |
    | 4 | 103 | 2 | 4 | 0 | 2020-01-04 13:23:46.000 | Vegetarian - Exclude Cheese |
    | 5 | 104 | 1 | 0 | 1 | 2020-01-08 21:00:29.000 | Meatlovers - Extra Bacon |
    | 6 | 101 | 2 | 0 | 0 | 2020-01-08 21:03:13.000 | Vegetarian |
    | 7 | 105 | 2 | 0 | 1 | 2020-01-08 21:20:29.000 | Vegetarian - Extra Bacon |
    | 8 | 102 | 1 | 0 | 0 | 2020-01-09 23:54:33.000 | Meatlovers |
    | 9 | 103 | 1 | 4 | 1, 5 | 2020-01-10 11:22:59.000 | Meatlovers - Exclude Cheese - Extra Bacon, Chicken |
    | 10 | 104 | 1 | 0 | 0 | 2020-01-11 18:34:49.000 | Meatlovers |
    | 10 | 104 | 1 | 2, 6 | 1, 4 | 2020-01-11 18:34:49.000 | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |

5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the 
   customer_orders table and add a 2x in front of any relevant ingredients
   ### For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

    | numbered_ingredients                                    |
    |---------------------------------------------------------|
    | Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami |
    | Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami |
    | Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami |
    | Cheese,Mushrooms,Onions,Peppers,Tomato Sauce,Tomatoes     |
    | Bacon,BBQ Sauce,Beef,Chicken,Mushrooms,Pepperoni,Salami   |
    | Mushrooms,Onions,Peppers,Tomato Sauce,Tomatoes            |
    | **2xBacon**,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami |
    | Cheese,Mushrooms,Onions,Peppers,Tomato Sauce,Tomatoes     |
    | Bacon,Cheese,Mushrooms,Onions,Peppers,Tomato Sauce,Tomatoes |
    | Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami |
    | **2xBacon**,BBQ Sauce,Beef,**2xChicken**,Mushrooms,Pepperoni,Salami |
    | Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami |
    | **2xBacon**,Beef,**2xCheese**,Chicken,Pepperoni,Salami            |
