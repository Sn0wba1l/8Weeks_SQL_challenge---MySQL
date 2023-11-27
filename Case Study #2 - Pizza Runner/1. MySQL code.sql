--MySQL version solution URL: 
--https://github.com/manaswikamila05/8-Week-SQL-Challenge/tree/main/Case%20Study%20%23%202%20-%20Pizza%20Runner

--katie huang solution URL:
--https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/B.%20Runner%20and%20Customer%20Experience.md 

DROP TABLE if EXISTS Runner;
CREATE TABLE Runner (
    runner_id INT,
    registration_date DATE,
    PRIMARY KEY (runner_id)
);

INSERT INTO runner VALUES (1, '2021-01-01');
INSERT INTO runner VALUES (2, '2021-01-03');
INSERT INTO runner VALUES (3, '2021-01-08');
INSERT INTO runner VALUES (4, '2021-01-15');



DROP TABLE IF EXISTS Customer_orders;
CREATE TABLE Customer_orders(
    order_id INT,
    customer_id INT,
    pizza_id INT,
    exclusions VARCHAR(4),
    extras VARCHAR(4),
    order_time TIMESTAMP
);
INSERT INTO Customer_orders VALUES 
('1', '101', '1', '', '', '2020-01-01 18:05:02'),
('2', '101', '1', '', '', '2020-01-01 19:00:52'),
('3', '102', '1', '', '', '2020-01-02 23:51:23'),
('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

DROP TABLE IF EXISTS customer_orders_temp;
CREATE TABLE customer_orders_temp AS
SELECT  order_id,
        customer_id,
        pizza_id,
        CASE 
            WHEN exclusions = '' then NULL
            WHEN exclusions = 'null' then NULL
            ELSE exclusions
        END AS exclusions,
        CASE 
            WHEN extras = '' then NULL
            WHEN extras = 'null' then NULL
            ELSE extras
        END AS extras,
        order_time
    FROM customer_orders;

SELECT t.order_id,
       t.customer_id,
       t.pizza_id,
       trim(j1.exclusions) AS exclusions,
       trim(j2.extras) AS extras,
       t.order_time
FROM customer_orders_temp t
INNER JOIN json_table(trim(replace(json_array(t.exclusions), ',', '","')), '$[*]' columns (exclusions varchar(50) PATH '$')) j1
INNER JOIN json_table(trim(replace(json_array(t.extras), ',', '","')), '$[*]' columns (extras varchar(50) PATH '$')) j2 ;

SELECT * FROM customer_orders_temp;



DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders(
    order_id INT,
    runner_id INT,
    pickup_time VARCHAR(19),
    distance VARCHAR(7),
    duration VARCHAR(10),
    cancellation VARCHAR(23)
);
INSERT INTO runner_orders VALUES 
('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS runner_orders_temp;
CREATE TABLE runner_orders_temp AS
SELECT 
    order_id,
    runner_id,
    CASE 
        WHEN pickup_time LIKE 'null' THEN NULL
        ELSE pickup_time
    END AS pickup_time,
    CASE
        WHEN runner_orders.distance LIKE 'null' THEN NULL
        ELSE CAST(regexp_replace(distance,'[a-z]+','')AS FLOAT)
    END AS distance,
    CASE 
        WHEN duration LIKE 'null' THEN NULL
        ELSE CAST (regexp_replace(duration, '[a-z]+','')AS FLOAT)
    END AS duration,
    CASE
        WHEN cancellation LIKE '' THEN NULL
        WHEN cancellation LIKE 'null' THEN NULL
        ELSE cancellation
    END AS cancellation
FROM runner_orders;
SELECT * FROM runner_orders_temp;



CREATE TABLE pizza_name(
    pizza_id INT,
    pizza_name VARCHAR(20),
    PRIMARY KEY (pizza_id)
);
INSERT INTO pizza_name VALUES
(1, 'Meatlovers'),
(2, 'Vegetarian');




DROP TABLE IF EXISTS pizza_recipe;
CREATE TABLE pizza_recipe(
    pizza_id INT, 
    toppings TEXT
);
INSERT INTO pizza_recipe VALUES
(1, '1, 2, 3, 4, 5, 6, 8, 10'),
(2, '4, 6, 7, 9, 11, 12');

SELECT *,
       json_array(toppings),
       replace(json_array(toppings), ',', '","'),
       trim(replace(json_array(toppings), ',', '","'))
FROM pizza_recipe;

DROP TABLE IF EXISTS pizza_recipe_vertical;
CREATE TABLE pizza_recipe_vertical(    
SELECT pizza_id, (j.topping) AS topping_id
FROM pizza_recipe t
JOIN json_table(trim(replace(json_array(t.toppings), ',', '","')), '$[*]' columns (topping varchar(50) PATH '$')) j 
);

SELECT * FROM pizza_recipe_vertical;




CREATE TABLE pizza_toppings(
    topping_id INT,
    topping_name VARCHAR(20),
    PRIMARY KEY (topping_id)
);
INSERT INTO pizza_toppings VALUES
(1, 'Bacon'),
(2, 'BBQ Sauce'),
(3, 'Beef'),
(4, 'Cheese'),
(5, 'Chicken'),
(6, 'Mushrooms'),
(7, 'Onions'),
(8, 'Pepperoni'),
(9, 'Peppers'),
(10, 'Salami'),
(11, 'Tomatoes'),
(12, 'Tomato Sauce');




SELECT * FROM customer_orders_temp;
SELECT * FROM runner_orders_temp;
SELECT * FROM pizza_recipe;
SELECT * FROM pizza_name;
SELECT * FROM pizza_toppings;
SELECT * FROM runner;



---------------------------------------QA1
SELECT COUNT (*) AS number_pizza_ordered
FROM customer_orders;

---------------------------------------QA2
SELECT COUNT(DISTINCT order_id) AS distinct_order_made
FROM customer_orders;

---------------------------------------QA3
SELECT runner_id, COUNT(order_id) AS number_order_made
FROM runner_orders
WHERE distance!=0
GROUP BY runner_id;

---------------------------------------QA4
SELECT p.pizza_name, COUNT(c.pizza_id) AS number_of_succesful_delivery
FROM customer_orders c
    JOIN pizza_name p
    ON c.pizza_id=p.pizza_id
    JOIN runner_orders r
    ON c.order_id=r.order_id
    AND r.distance!=0
GROUP BY pizza_name;

---------------------------------------QA5
SELECT c.customer_id, p.pizza_name, COUNT(p.pizza_id) AS number_of_pizzas
FROM customer_orders c
JOIN pizza_name p
ON c.pizza_id=p.pizza_id
GROUP BY c.customer_id,pizza_name
ORDER BY c.customer_id;

---------------------------------------QA6
SELECT customer_id, order_id, count(order_id) AS pizza_count
FROM customer_orders_temp
GROUP BY customer_id, order_id
ORDER BY pizza_count DESC
limit 1;

---------------------------------------QA7

SELECT c.customer_id, 
SUM(
    CASE WHEN c.exclusions IS NOT NULL 
    OR 
    c.extras IS NOT NULL 
    THEN 1
    ELSE 0
    END 
) AS at_least_one_change,
SUM(
    CASE WHEN c.exclusions IS NULL 
    AND 
    c.extras IS NULL 
    THEN 1
    ELSE 0
    END
) AS no_change
FROM customer_orders_temp c
JOIN runner_orders_temp r 
ON c.order_id=r.order_id
WHERE distance != 0
GROUP BY customer_id
ORDER BY customer_id;


---------------------------------------QA8
SELECT customer_id,  
  SUM(
    CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1
    ELSE 0
    END) AS pizza_count_w_exclusions_extras
FROM customer_orders_temp AS c
JOIN runner_orders_temp AS r
  ON c.order_id = r.order_id
WHERE r.distance >= 1 
  GROUP BY customer_id;


---------------------------------------QA9
SELECT 
HOUR(c.order_time) AS hour_of_the_day,
COUNT(order_id) AS pizza_count
FROM customer_orders c
GROUP BY HOUR(c.order_time)
ORDER BY HOUR(c.order_time); 

---------------------------------------QA10*********

SELECT 
  dayname (order_time) AS day_of_week, -- add 2 to adjust 1st day of the week as Monday
  COUNT(order_id) AS total_pizzas_ordered
FROM customer_orders
GROUP BY dayname (order_time)
ORDER BY 2 DESC;

---------------------------------------QA10 (SOLUTION) ********
SELECT 
  FORMAT(DATEADD(DAY, 2, order_time),'dddd') AS day_of_week, -- add 2 to adjust 1st day of the week as Monday
  COUNT(order_id) AS total_pizzas_ordered
FROM customer_orders
GROUP BY FORMAT(DATEADD(DAY, 2, order_time),'dddd');

SELECT dayname(order_time) AS 'Day Of Week',
       count(order_id) AS 'Number of pizzas ordered',
       round(100*count(order_id) /sum(count(order_id)) over(), 2) AS 'Volume of pizzas ordered'
FROM pizza_runner.customer_orders_temp
GROUP BY 1
ORDER BY 2 DESC;

########################################################################################################
########################################################################################################

SELECT * FROM customer_orders_temp;
SELECT * FROM runner_orders_temp;
SELECT * FROM pizza_recipe;
SELECT * FROM pizza_name;
SELECT * FROM pizza_toppings;
SELECT * FROM runner;

---------------------------------------QB1
SELECT week(registration_date) AS 'Week of registration', count(runner_id) AS 'Number of runners'
FROM runner
GROUP BY 1;

---------------------------------------QB2
SELECT runner_id, SUM(TIMESTAMPDIFF(MINUTE, order_time, pickup_time)) AS runner_pickup_time, round(avg(TIMESTAMPDIFF(MINUTE, order_time, pickup_time)),2) AS avg_runner_pickup_time
FROM runner_orders_temp r 
JOIN customer_orders_temp c 
ON r.order_id=c.order_id
WHERE cancellation IS NULL
GROUP BY runner_id;

---------------------------------------QB3

WITH prep_time_cte AS
(
  SELECT 
    c.order_id, 
    COUNT(c.order_id) AS pizza_order, 
    c.order_time, 
    r.pickup_time, 
    TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) AS prep_time_minutes
  FROM customer_orders_temp AS c 
    JOIN runner_orders_temp AS r
    ON c.order_id = r.order_id
  WHERE cancellation IS NULL
  GROUP BY c.order_id, c.order_time, r.pickup_time
)

SELECT 
  pizza_order, 
  AVG(prep_time_minutes) AS avg_prep_time_minutes
FROM prep_time_cte
GROUP BY pizza_order;

---------------------------------------QB4
SELECT c.customer_id, round(avg(r.distance),2) AS average_distance_travelled
FROM runner_orders_temp r 
JOIN customer_orders_temp c USING (order_id)
WHERE cancellation IS NULL
GROUP BY customer_id;

---------------------------------------QB5
SELECT MIN(duration) AS shortest_delivery_time,
        MAX(duration) AS longest_delivery_time,
        MAX(duration)-MIN(duration) AS maximum_difference
FROM runner_orders_temp;

---------------------------------------QB6
SELECT r.runner_id,COUNT(c.order_id) AS pizza_count,r.duration, distance, round(r.duration/60,2) AS duration_hour, round(r.distance*60/r.duration,2) AS average_speed
FROM runner_orders_temp r
JOIN customer_orders_temp c USING(order_id)
WHERE cancellation IS NULL
GROUP BY r.runner_id,  r.distance, r.duration
ORDER BY r.runner_id;

---------------------------------------QB7
SELECT runner_id, COUNT(pickup_time) AS delivered_orders, COUNT(*) AS total_number_orders, ROUND(100*COUNT(pickup_time)/COUNT(runner_id),0) AS successful_delivery_orders
FROM runner_orders_temp
GROUP BY runner_id
ORDER BY runner_id;

---------------------------------------QB7 (Katie's sol)
SELECT 
  runner_id, 
  ROUND(100 * SUM(
    CASE WHEN distance = 0 THEN 0
    ELSE 1 END) / COUNT(*), 0) AS success_perc
FROM runner_orders_temp
GROUP BY runner_id;

########################################################################################################
########################################################################################################

CREATE TABLE customer_orders_temp_vertical AS
SELECT t.row_num,
       t.order_id,
       t.customer_id,
       t.pizza_id,
       t.exclusions,
       trim(j2.extras) AS extras,
       t.order_time
FROM
  (SELECT *,
          row_number() over() AS row_num
   FROM customer_orders_temp) t
INNER JOIN json_table(trim(replace(json_array(t.extras), ',', '","')),
                      '$[*]' columns (extras varchar(50) PATH '$')) j2 ;

DROP TABLE customer_orders_temp_vertical;


CREATE TABLE customer_orders_temp_vertical_2 AS
SELECT t.row_num,
       t.order_id,
       t.customer_id,
       t.pizza_id,
       trim(j1.exclusions) AS exclusions,
       trim(j2.extras) AS extras,
       t.order_time
FROM
  (SELECT *,
          row_number() over() AS row_num
   FROM customer_orders_temp) t
INNER JOIN json_table(trim(replace(json_array(t.exclusions), ',', '","')),
                      '$[*]' columns (exclusions varchar(50) PATH '$')) j1
INNER JOIN json_table(trim(replace(json_array(t.extras), ',', '","')),
                      '$[*]' columns (extras varchar(50) PATH '$')) j2 ;


SELECT *
FROM row_split_customer_orders_temp;

SELECT * FROM customer_orders_temp;
SELECT * FROM runner_orders_temp;
SELECT * FROM runner;
SELECT * FROM pizza_recipe_vertical;
SELECT * FROM pizza_name;
SELECT * FROM pizza_toppings;
SELECT * FROM customer_orders_temp_vertical;
SELECT * FROM customer_orders_temp_vertical_2;


---------------------------------------QC1
SELECT pizza_name,
       group_concat(DISTINCT topping_name) AS standard_ingredients
FROM pizza_recipe_vertical
INNER JOIN pizza_name USING (pizza_id)
INNER JOIN pizza_toppings USING (topping_id)
GROUP BY pizza_name, pizza_id
ORDER BY pizza_id;

---------------------------------------QC2

SELECT topping_name, count(*) AS purchase_counts
   FROM customer_orders_temp_vertical
   JOIN pizza_toppings ON customer_orders_temp_vertical.extras=pizza_toppings.topping_id 
   WHERE extras IS NOT NULL
   GROUP BY extras;

---------------------------------------QC3
SELECT topping_name, count(*) AS purchase_counts
    FROM customer_orders_temp_vertical_2
    JOIN pizza_toppings ON customer_orders_temp_vertical_2.exclusions=pizza_toppings.topping_id 
    WHERE exclusions IS NOT NULL
    GROUP BY exclusions;

---------------------------------------QC4
--check solution

--########################################################################################################
--########################################################################################################

SELECT * FROM customer_orders_temp;
SELECT * FROM runner_orders_temp;
SELECT * FROM runner;
SELECT * FROM pizza_recipe_vertical;
SELECT * FROM pizza_name;
SELECT * FROM pizza_toppings;
SELECT * FROM customer_orders_temp_vertical;
SELECT * FROM customer_orders_temp_vertical_2;

---------------------------------------QD1
SELECT CONCAT(SUM(CASE
                WHEN pizza_id=1 THEN 12
                ELSE 10
            END),' $') AS total_revenue
FROM customer_orders_temp
JOIN pizza_name USING (pizza_id)
JOIN runner_orders_temp USING (order_id)
WHERE cancellation IS NULL;

---------------------------------------QD2

SELECT CONCAT(topping_revenue+pizza_revenue,' $') AS total_revenue
FROM(
    SELECT SUM (CASE 
                    WHEN pizza_id = 1 THEN 12
                    ELSE 10
                END) AS pizza_revenue,
            SUM (topping_count) AS topping_revenue
    FROM 
    (
        SELECT *, length(extras) - length(replace(extras, ",", ""))+1 AS topping_count
            FROM customer_orders_temp
            INNER JOIN pizza_name USING (pizza_id)
            INNER JOIN runner_orders_temp USING (order_id)
            WHERE cancellation IS NULL
            ORDER BY order_id
    )t1
)t2;

---------------------------------------QD3
DROP TABLE IF EXISTS runner_rating;

CREATE TABLE runner_rating (order_id INTEGER, rating INTEGER, review VARCHAR(100)) ;

-- Order 6 and 9 were cancelled
INSERT INTO runner_rating
VALUES ('1', '1', 'Really bad service'),
       ('2', '1', NULL),
       ('3', '4', 'Took too long...'),
       ('4', '1','Runner was lost, delivered it AFTER an hour. Pizza arrived cold' ),
       ('5', '2', 'Good service'),
       ('7', '5', 'It was great, good service and fast'),
       ('8', '2', 'He tossed it on the doorstep, poor service'),
       ('10', '5', 'Delicious!, he delivered it sooner than expected too!');

SELECT * FROM runner_rating;

---------------------------------------QD4
SELECT  customer_id,
        order_id,
        runner_id,
        rating,
        order_time,
        pickup_time,
        TIMESTAMPDIFF(MINUTE,order_time,pickup_time) AS time_between_order_pick_up,
        duration AS delivery_duration,
        Round(distance*60/duration,2) AS average_speed,
        count(pizza_id) AS total_pizza_count
FROM customer_orders_temp
JOIN runner_orders_temp USING (order_id)
JOIN runner_rating USING (order_id)
GROUP BY order_id,customer_id,runner_id,rating,order_time,pickup_time,time_between_order_pick_up,delivery_duration,average_speed;

---------------------------------------QD5

SELECT CONCAT( ROUND(SUM(pizza_cost-delivery_cost),2) , ' $') AS total_revenue
FROM(
    SELECT order_id,
            distance,
            sum(pizza_cost) AS pizza_cost,
            round(0.30*distance, 2) AS delivery_cost
    FROM
        (SELECT *,
                (CASE
                    WHEN pizza_id = 1 THEN 12
                    ELSE 10
                END) AS pizza_cost
        FROM customer_orders_temp
        INNER JOIN pizza_name USING (pizza_id)
        INNER JOIN runner_orders_temp USING (order_id)
        WHERE cancellation IS NULL) t1
    GROUP BY order_id,distance
)t2;

--########################################################################################################
--########################################################################################################

SELECT * FROM customer_orders_temp;
SELECT * FROM runner_orders_temp;
SELECT * FROM runner;
SELECT * FROM pizza_recipe_vertical;
SELECT * FROM pizza_name;
SELECT * FROM pizza_toppings;
SELECT * FROM customer_orders_temp_vertical;
SELECT * FROM customer_orders_temp_vertical_2;

-- BONUS QUESTION
INSERT INTO pizza_name VALUES (3,'Supreme');
SELECT * FROM pizza_name;


CREATE TABLE pizza_recipe_2 AS (
    SELECT * FROM pizza_recipe
);
INSERT INTO pizza_recipe_2 VALUES (3, (SELECT GROUP_CONCAT(topping_id SEPARATOR ', ')FROM pizza_toppings));
SELECT * FROM pizza_recipe_2;


SELECT * FROM pizza_name
JOIN pizza_recipe_2 USING (pizza_id);


