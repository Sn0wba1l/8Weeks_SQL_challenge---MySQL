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

