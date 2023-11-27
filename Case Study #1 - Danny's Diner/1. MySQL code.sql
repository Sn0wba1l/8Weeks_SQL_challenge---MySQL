----------------------------------------------Q1
SELECT Customer_ID, SUM(Price) AS Total_amount_spent
FROM Sales S
JOIN Menu M ON S.Product_ID=M.Product_ID
GROUP BY Customer_ID
ORDER BY Customer_ID ASC;

----------------------------------------------Q2
SELECT Customer_ID, COUNT(DISTINCT order_date) AS Number_of_days_visited
FROM Sales 
GROUP BY Customer_ID
ORDER BY Customer_ID;

----------------------------------------------Q3
----------------------------------------------SOL 1:
WITH ordered_sales AS (
SELECT s.customer_ID,s.order_date,m.product_name,
    DENSE_RANK() OVER( PARTITION BY s.customer_id ORDER BY s.order_date) AS dense_rnk
  FROM giraffe.sales AS s
  INNER JOIN giraffe.menu AS m
    ON s.product_id = m.product_id
)

SELECT Customer_ID,  product_name
FROM ordered_sales
where dense_rnk=1
GROUP BY customer_id, product_name;

----------------------------------------------SOL 2:
WITH ordered_sales AS (
  SELECT 
  sales.customer_id, 
    sales.order_date, 
    menu.product_name,
    DENSE_RANK() OVER(
      PARTITION BY sales.customer_id 
      ORDER BY sales.order_date) AS rnk
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

----------------------------------------------Q4:
SELECT m.Product_name, COUNT(s.product_id) AS most_purchased_item
FROM sales s
JOIN menu m
    ON s.product_id=m.product_id
GROUP BY product_name
ORDER BY most_purchased_item DESC
LIMIT 1;

----------------------------------------------Q5:
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

----------------------------------------------Q6: 
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

----------------------------------------------Q7:
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

-----------------------------------------------Q8:
SELECT sales.customer_id, COUNT(sales.product_id) AS number_of_items_purchased, SUM(menu.price) AS total_amount_spent 
FROM sales
JOIN menu
    ON sales.product_id=menu.product_id
JOIN members
    ON sales.customer_id=members.customer_id
    AND sales.order_date<members.join_date
GROUP BY customer_id
ORDER BY customer_id;

------------------------------------------------Q9:
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

----------------------------------------------Q10:
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

----------------------------------------------BONUS QUESTION 1:
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

----------------------------------------------BONUS QUESTION 2:
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
