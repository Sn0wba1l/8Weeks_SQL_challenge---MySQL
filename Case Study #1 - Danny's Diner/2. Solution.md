# Case Study #1: Danny's Diner

## Case Study Questions

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
10. What is the total items and amount spent for each member before they became a member?
11. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
12. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
***

### 1. What is the total amount each customer spent at the restaurant?
```SQl
SELECT Customer_ID, SUM(Price) AS Total_amount_spent
FROM Sales S
JOIN Menu M ON S.Product_ID=M.Product_ID
GROUP BY Customer_ID
ORDER BY Customer_ID ASC;
```

#### Result set:
| customer_id | Total_amount_spent |
| ----------- | ----------         |
| A           | 76                 |
| B           | 74                 |
| C           | 36                 |


***

###  2. How many days has each customer visited the restaurant?
```SQL
SELECT Customer_ID, COUNT(DISTINCT order_date) AS Number_of_days_visited
FROM Sales 
GROUP BY Customer_ID
ORDER BY Customer_ID;
```


#### Result set:
| customer_id | Number_of_days_visited |
| ----------- | ----------- |
| A           | 4           |
| B           | 6           |
| C           | 2           |


***

###  3. What was the first item from the menu purchased by each customer?
```SQL
WITH ordered_sales AS (
  SELECT 
  sales.customer_id, 
    sales.order_date, 
    menu.product_name,
    DENSE_RANK() OVER(
      PARTITION BY sales.customer_id ORDER BY sales.order_date) AS rnk
  FROM giraffe.sales
  INNER JOIN giraffe.menu
    ON sales.product_id = menu.product_id
)

SELECT 
  customer_id, 
  product_name
FROM ordered_sales
WHERE rnk = 1
GROUP BY customer_id, product_name;
```
	
#### Result set:
| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

***

###  4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql
SELECT product_name AS most_purchased_item,
       count(sales.product_id) AS order_count
FROM dannys_diner.menu
INNER JOIN dannys_diner.sales ON menu.product_id = sales.product_id
GROUP BY product_name
ORDER BY order_count DESC
LIMIT 1;
```

#### Result set:
| most_purchased_item | most_purchased_item |
| ------------------- | -----------         |
| ramen               | 8                   |

***

###  5. Which item was the most popular for each customer?
```SQL
WITH most_popular AS ( 
    SELECT S.Customer_ID, COUNT(S.Product_ID) AS order_count , M.Product_name,
    DENSE_RANK () OVER(PARTITION BY S.Customer_ID ORDER BY COUNT(S.Product_ID) DESC) AS rnk
    FROM Sales S
    JOIN Menu M
        ON S.Product_ID=M.Product_ID
    GROUP BY S.Customer_ID, M.Product_name
)

SELECT Customer_ID,Product_name, order_count
FROM most_popular
WHERE rnk=1;
```

#### Result set:
| customer_id | product_name | order_count |
| ----------- | ------------ | ----------- |
| A           | ramen        | 3           |
| B           | ramen        | 2           |
| B           | curry        | 2           |
| B           | sushi        | 2           |
| C           | ramen        | 3           |

***

###  6. Which item was purchased first by the customer after they became a member?
```SQL
WITH joined_as_member AS (
    SELECT 
        members.customer_id, sales.order_date, sales.product_id,
        dense_rank()OVER ( PARTITION BY members.customer_id ORDER BY sales.order_date ASC) AS rnk
        FROM members
        JOIN sales
        ON members.customer_id=sales.customer_id
            AND sales.order_date>members.join_date
)

SELECT customer_id, order_date, product_name
FROM joined_as_member
JOIN menu
ON joined_as_member.product_id=menu.product_id
where rnk=1
ORDER BY Customer_id ASC;
```

#### Result set:
| customer_id | order_date               | product_name  |  
| ----------- | ------------------------ | ------------  | 
| A           | 2021-01-07               |  ramen        |
| B           | 2021-01-11               |  sushi        |

***

###  7. Which item was purchased just before the customer became a member?

```sql
WITH joined_as_member AS (
    SELECT 
        members.customer_id, sales.order_date, sales.product_id,
        dense_rank()OVER ( PARTITION BY members.customer_id ORDER BY sales.order_date desc) AS rnk
        FROM members
        JOIN sales
        ON members.customer_id=sales.customer_id
            AND sales.order_date<members.join_date
)

SELECT customer_id, order_date, product_name
FROM joined_as_member
JOIN menu
ON joined_as_member.product_id=menu.product_id
where rnk=1
ORDER BY Customer_id ASC;
```

#### Result set:
| customer_id | order_date               | product_name |
| ----------- | ------------------------ | ------------ |
| A           | 2021-01-01               | curry        |
| A           | 2021-01-01               | sushi        |
| B           | 2021-01-04               | sushi        |

***

###  8. What is the total items and amount spent for each member before they became a member?
```sql
SELECT sales.customer_id, COUNT(sales.product_id) AS number_of_items_purchased, SUM(menu.price) AS total_amount_spent 
FROM sales
JOIN menu
    ON sales.product_id=menu.product_id
JOIN members
    ON sales.customer_id=members.customer_id
    AND sales.order_date<members.join_date
GROUP BY customer_id
ORDER BY customer_id;
```
#### Result set:
| customer_id | number_of_items_purchased | total_amount_spent |
| ----------- | ------------------------- | ------------------ |
| A           | 2                         |  25                |
| B           | 3                         |  40                |

***

###  9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

#### Had the customer joined the loyalty program before making the purchases, total points that each customer would have accrued
```sql
WITH points_table AS (
    SELECT menu.product_id, 
    CASE
        WHEN menu.product_id=1 THEN menu.price*20
        ELSE menu.price*10
    end AS points
    FROM menu
)

SELECT sales.customer_id, SUM (points_table.points) AS total_points_obtained
FROM sales
JOIN points_table
ON sales.product_id=points_table.product_id
GROUP BY sales.customer_id;
```

#### Result set:
| customer_id | total_points_obtained |
| ----------- | ----------------------|
| A           | 860                   |
| B           | 940                   |
| C           | 360                   |

***

###  10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January
```sql
SELECT customer_id,
        SUM(IF (order_date BETWEEN join_date AND DATE_ADD(join_date,INTERVAL 6 DAY), price*10*2,
            IF (product_name='sushi', price*10*2,price*10))) AS customer_points
FROM menu
JOIN sales USING (product_id)
JOIN members USING (customer_id)
WHERE order_date <= '2021-01-31'
AND order_date >= join_date
GROUP BY customer_id
ORDER BY customer_id;
```
#### Result set:
| customer_id | customer_points |
| ----------- | ----------------------|
| A           | 1020                  |
| B           | 320                   |


***

#### Steps
1. Find the program_last_date which is 7 days after a customer joins the program (including their join date)
2. Determine the customer points for each transaction and for members with a membership
	- During the first week of the membership -> points = price*20 irrespective of the purchase item
 	- Product = Sushi -> and order_date is not within a week of membership -> points = price*20
	- Product = Not Sushi -> and order_date is not within a week of membership -> points = price*10
3. Conditions in WHERE clause
	- order_date <= '2021-01-31' -> Order must be placed before 31st January 2021
	- order_date >= join_date -> Points awarded to only customers with a membership



### Bonus Questions

#### Join All The Things
Create basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL. Fill Member column as 'N' if the purchase was made before becoming a member and 'Y' if the after is amde after joining the membership.

```sql
SELECT 
  sales.customer_id, 
  sales.order_date,  
  menu.product_name, 
  menu.price,
  CASE
    WHEN members.join_date > sales.order_date THEN 'N'
    WHEN members.join_date <= sales.order_date THEN 'Y'
    ELSE 'N' END AS member_status
FROM sales
LEFT JOIN members
  ON sales.customer_id = members.customer_id
JOIN menu
  ON sales.product_id = menu.product_id
ORDER BY customer_id ASC, sales.order_date ASC;
```

#### Result set:
![QB1 result](https://github.com/Sn0wba1l/8Weeks_SQL_challenge/assets/100756361/e746f251-3a8e-4bee-b46c-6234467c6bd5)



***

#### Rank All The Things
Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

```sql
WITH customers_data AS (
  SELECT 
    sales.customer_id, 
    sales.order_date,  
    menu.product_name, 
    menu.price,
    CASE
      WHEN members.join_date > sales.order_date THEN 'N'
      WHEN members.join_date <= sales.order_date THEN 'Y'
      ELSE 'N' END AS member_status
  FROM sales
  LEFT JOIN members
    ON sales.customer_id = members.customer_id
  JOIN menu
    ON sales.product_id = menu.product_id
  ORDER BY members.customer_id, sales.order_date
)

SELECT *,
CASE 
WHEN member_status='N' THEN NULL
ELSE Rank() OVER(
    Partition BY customer_id, member_status
    ORDER BY order_date) END AS ranking
FROM customers_data
ORDER BY customer_id;
```

#### Result set:
![QB2 result](https://github.com/Sn0wba1l/8Weeks_SQL_challenge/assets/100756361/957e87b3-064e-4b1b-afe1-3cca2b5810ba)

***



