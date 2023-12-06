 -----------------------------------------------------------------------------------------------
SELECT * FROM users;
SELECT * FROM events;
SELECT * FROM campaign_identifier;
SELECT * FROM event_identifier;
SELECT * FROM page_hierachy;

---------------------------------------------------------------Q1
SELECT COUNT(DISTINCT user_id) AS user_count FROM users;


---------------------------------------------------------------Q2
WITH cte AS (
SELECT user_id, COUNT(DISTINCT cookie_id) AS cookie_id_count
FROM users
GROUP BY user_id
)

SELECT ROUND(AVG(cookie_id_count),0) AS avg_cookie_count
FROM cte;

---------------------------------------------------------------Q3
SELECT EXTRACT(MONTH FROM event_time) AS month,
COUNT (DISTINCT visit_id) AS unique_visit_count
FROM events
GROUP BY month;

---------------------------------------------------------------Q4
SELECT event_type, COUNT(*) AS event_count
FROM events
GROUP BY event_type
ORDER BY event_type;

---------------------------------------------------------------Q5
SELECT CONCAT(100*COUNT(DISTINCT visit_id)/(SELECT COUNT(DISTINCT visit_id) FROM events), ' %') AS percentage_visit
FROM events
JOIN event_identifier
USING(event_type)
WHERE event_name = 'purchase';

---------------------------------------------------------------Q6
WITH cte1 AS(
SELECT visit_id,
SUM(CASE WHEN event_name!='Purchase' and page_id=12 then 1 else 0 END) AS checkout,
SUM(CASE WHEN event_name='Purchase' THEN 1 ELSE 0 END) AS purchases
FROM events 
JOIN event_identifier
ON events.event_type=event_identifier.event_type
GROUP BY visit_id
)

SELECT SUM(checkout) AS total_checkouts,
SUM(purchases) AS total_purchases,
ROUND(100*(1-(SUM(purchases))/SUM(checkout)),2) AS percentage
FROM cte1;

---------------------------------------------------------------Q7
SELECT page_name, page_id, COUNT(visit_id) AS number_of_visits
FROM events
JOIN page_hierachy USING (page_id)
GROUP BY page_name,page_id
ORDER BY number_of_visits DESC
LIMIT 3;

---------------------------------------------------------------Q8
SELECT product_category,
SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS page_views,
SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS cart_add
FROM events
JOIN page_hierachy USING(page_id)
WHERE product_category IS NOT NULL
GROUP BY product_category
ORDER BY page_views DESC;

---------------------------------------------------------------Q9
WITH cte1 AS (
SELECT 
    visit_id,
    product_id,
    page_name AS Product_name,
    product_category,
    SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS cart_add
FROM events 
JOIN page_hierachy USING (page_id)
WHERE product_id IS NOT NULL
GROUP BY visit_id, product_id, Product_name, product_category
),

cte2 AS (
SELECT DISTINCT visit_id
FROM events
WHERE event_type = 3
),

combined_cte AS (
SELECT 
visit_id,
product_id,
Product_name,
product_category,
cart_add,
CASE WHEN cte2.visit_id IS NOT NULL THEN 1 ELSE 0 END AS purchase
FROM cte1
LEFT JOIN cte2 USING (visit_id)
)

SELECT 
product_name,
product_category,
SUM(CASE WHEN cart_add = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
FROM combined_cte
GROUP BY product_id,product_name, product_category
ORDER BY purchases DESC
LIMIT 3;

---------------------------------------------------------------QB1
WITH cte1 AS (
SELECT 
    visit_id,
    product_id,
    page_name AS Product_name,
    product_category,
    SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS page_view,
    SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS cart_add
FROM events 
JOIN page_hierachy USING (page_id)
WHERE product_id IS NOT NULL
GROUP BY visit_id, product_id, Product_name, product_category
),

cte2 AS (
SELECT DISTINCT visit_id
FROM events
WHERE event_type = 3
),

combined_cte AS (
SELECT 
visit_id,
product_id,
Product_name,
product_category,
page_view,
cart_add,
CASE WHEN cte2.visit_id IS NOT NULL THEN 1 ELSE 0 END AS purchase
FROM cte1
LEFT JOIN cte2 USING (visit_id)
)

SELECT 
product_name,
product_category,
SUM(page_view) AS views,
SUM(cart_add) AS cart_adds,
SUM(CASE WHEN cart_add = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
SUM(CASE WHEN cart_add = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
FROM combined_cte
GROUP BY product_id,product_name, product_category
ORDER BY product_id;

---------------------------------------------------------------QB2
WITH cte1 AS (
SELECT 
    visit_id,
    product_id,
    page_name AS Product_name,
    product_category,
    SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS page_view,
    SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS cart_add
FROM events 
JOIN page_hierachy USING (page_id)
WHERE product_id IS NOT NULL
GROUP BY visit_id, product_id, Product_name, product_category
),

cte2 AS (
SELECT DISTINCT visit_id
FROM events
WHERE event_type = 3
),

combined_cte AS (
SELECT 
visit_id,
product_id,
Product_name,
product_category,
page_view,
cart_add,
CASE WHEN cte2.visit_id IS NOT NULL THEN 1 ELSE 0 END AS purchase
FROM cte1
LEFT JOIN cte2 USING (visit_id)
)

SELECT 
product_category,
SUM(page_view) AS views,
SUM(cart_add) AS cart_adds,
SUM(CASE WHEN cart_add = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
SUM(CASE WHEN cart_add = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
FROM combined_cte
GROUP BY product_category;

---------------------------------------------------------------QC1
SELECT 
user_id,visit_id,
MIN(event_time) AS visit_start_time, 
SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS page_views,
SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS cart_adds, 
SUM(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase,
campaign_name,
SUM(CASE WHEN event_type = 4 THEN 1 ELSE 0 END) AS impression,
SUM(CASE WHEN event_type = 5 THEN 1 ELSE 0 END) AS click,
GROUP_CONCAT(CASE WHEN product_id IS NOT NULL AND event_type = 2 THEN p.page_name ELSE NULL END,', ' ORDER BY sequence_number) AS cart_products
FROM users
JOIN events USING(cookie_id)
LEFT JOIN campaign_identifier AS c  
    ON event_time BETWEEN c.start_date AND c.end_date
LEFT JOIN page_hierachy AS p USING (page_id)
GROUP BY user_id, visit_id, campaign_name;
