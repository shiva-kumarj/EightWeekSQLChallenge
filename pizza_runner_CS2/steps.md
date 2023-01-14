# Data Cleaning and Manipulation

I wrote a SQL script that performs data cleaning and manipulation on various columns in multiple tables such as `customer_orders`, `runner_orders`, `pizza_names`, and `pizza_toppings`. I first selected specific columns and then performed various operations such as:
- Setting null values to certain columns 
- Replacing null values with a default of '0' 
- Cleaning and formatting columns by calling custom functions, and 
- Inserting a new row and altering the data type of certain columns.

I also utilized various SQL functions such as `round`, `coalesce`, and `lower` to format and standardize the data in the columns.

## A. Pizza Analytics
1. The total number of pizzas ordered is: `14`
2. The total number of unique customer orders made is: `10`
3. The number of successful orders delivered by each runner is as follows:
| runner_id | orders_delivered |
|:----------|:------------------|
| 1         | 4                 |
| 2         | 3                 |
| 3         | 1                 |


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

10. The volume of orders for each day of the week is as follows:
| day_of_week | volume |
|-------------|--------|
| 4           | 5      |
| 5           | 3      |
| 6           | 1      |
| 7           | 5      |
