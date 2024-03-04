---------------------------------------QA1
SELECT COUNT(DISTINCT node_id) AS unique_node
FROM customer_nodes;

---------------------------------------QA2
SELECT region_name,region_id,COUNT(node_id) AS unique_node
FROM regions
JOIN customer_nodes USING (region_id)
GROUP BY region_id,region_name
ORDER BY region_id;

---------------------------------------QA3
SELECT region_name,region_id,COUNT(DISTINCT customer_id) AS customer_count
FROM regions
JOIN customer_nodes USING (region_id)
GROUP BY region_id,region_name
ORDER BY region_id;

---------------------------------------QA4
SELECT round(avg(datediff(end_date, start_date)), 2) AS avg_days
FROM customer_nodes
WHERE end_date!='9999-12-31';

---------------------------------------QA5

--95th Percentile:
WITH reallocation_days_cte AS(
  SELECT *, (datediff(end_date,start_date)) AS reallocation_days
  FROM customer_nodes 
  INNER JOIN regions USING (region_id)
  WHERE end_date!='9999-12-31'),

percentile_cte AS (
  SELECT *, percent_rank() over(PARTITION BY region_id ORDER BY reallocation_days) * 100 AS percent
  FROM reallocation_days_cte
),

dense_percentile_cte AS (
    SELECT *, DENSE_RANK() over(PARTITION BY region_id ORDER BY reallocation_days ASC ) AS r
    FROM percentile_cte
    WHERE percent>95
)

SELECT region_id, region_name, reallocation_days
FROM dense_percentile_cte
WHERE r=1
GROUP BY region_id,region_name,reallocation_days;

--80th Percentile:

WITH reallocation_days_cte AS(
  SELECT *, (datediff(end_date,start_date)) AS reallocation_days
  FROM customer_nodes 
  INNER JOIN regions USING (region_id)
  WHERE end_date!='9999-12-31'),

percentile_cte AS (
  SELECT *, percent_rank() over(PARTITION BY region_id ORDER BY reallocation_days) * 100 AS percent
  FROM reallocation_days_cte
),

dense_percentile_cte AS (
    SELECT *, DENSE_RANK() over(PARTITION BY region_id ORDER BY reallocation_days ASC ) AS r
    FROM percentile_cte
    WHERE percent>80
)

SELECT region_id, region_name, reallocation_days
FROM dense_percentile_cte
WHERE r=1
GROUP BY region_id,region_name,reallocation_days;


--median percentile:
WITH reallocation_days_cte AS(
  SELECT *, (datediff(end_date,start_date)) AS reallocation_days
  FROM customer_nodes 
  INNER JOIN regions USING (region_id)
  WHERE end_date!='9999-12-31'),

percentile_cte AS (
  SELECT *, percent_rank() over(PARTITION BY region_id ORDER BY reallocation_days) * 100 AS percent
  FROM reallocation_days_cte
),

dense_percentile_cte AS (
    SELECT *, DENSE_RANK() over(PARTITION BY region_id ORDER BY reallocation_days ASC ) AS r
    FROM percentile_cte
    WHERE percent>50
)

SELECT region_id, region_name, reallocation_days
FROM dense_percentile_cte
WHERE r=1
GROUP BY region_id,region_name,reallocation_days;

---------------------------------------QB1
SELECT * FROM customer_nodes;
SELECT * FROM regions;
SELECT * FROM customer_transactions;

SELECT txn_type,COUNT(txn_amount) AS no_transaction, SUM(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type;

---------------------------------------QB2
SELECT round(count(customer_id)/
               (SELECT count(DISTINCT customer_id)
                FROM customer_transactions)) AS average_deposit_count,
       concat('$', round(avg(txn_amount), 2)) AS average_deposit_amount
FROM customer_transactions
WHERE txn_type = "deposit";

---------------------------------------QB3
WITH monthly_transaction_cte AS(
  SELECT customer_id,
  MONTH(txn_date) AS mth,
  SUM(CASE WHEN txn_type='deposit' THEN 1 ELSE 0 END) AS deposit_count,
  SUM(CASE WHEN txn_type='purchase' THEN 1 ELSE  0 END) AS purchase_count,
  SUM(CASE WHEN  txn_type='withdrawal' THEN 1 ELSE 0 END ) as withdrawal_count
  FROM customer_transactions
  GROUP BY customer_id,mth
)

SELECT mth, COUNT(DISTINCT customer_id) AS customer_count 
FROM monthly_transaction_cte
WHERE deposit_count > 1
AND (purchase_count = 1 OR withdrawal_count = 1 )
GROUP BY mth
ORDER BY mth;

---------------------------------------QB4

WITH cte AS (
  SELECT customer_id,
        MONTH(txn_date) AS mth,
        SUM(CASE 
                  WHEN txn_type = "deposit" THEN txn_amount ELSE -txn_amount END) AS net_transaction_amount
FROM customer_transactions
GROUP BY customer_id, MONTH(txn_date)
ORDER BY customer_id
)

SELECT customer_id,
        mth,
        net_transaction_amount,
        SUM(net_transaction_amount) over(PARTITION BY customer_id ORDER BY mth ROWS BETWEEN UNBOUNDED preceding AND CURRENT ROW) AS closing_balance
FROM cte;

---------------------------------------QB5
WITH cte AS (
  SELECT customer_id,
        MONTH(txn_date) AS mth,
        SUM(CASE 
                  WHEN txn_type = "deposit" THEN txn_amount ELSE -txn_amount END) AS net_transaction_amount
FROM customer_transactions
GROUP BY customer_id, mth
),
cte1 AS(
SELECT customer_id,
        mth,
        net_transaction_amount,
        SUM(net_transaction_amount) over(PARTITION BY customer_id ORDER BY mth ROWS BETWEEN UNBOUNDED preceding AND CURRENT ROW) AS closing_balance
FROM cte
),
cte2 AS (
  SELECT customer_id,
          mth,
          closing_balance,
          LAG(closing_balance) OVER (PARTITION BY customer_id ORDER BY mth) AS previous_mth_closing_balance,
          100 * (closing_balance - LAG (closing_balance)OVER (PARTITION BY customer_id ORDER BY mth))/NULLIF(LAG(closing_balance)OVER(PARTITION BY customer_id ORDER BY mth),0) AS pct_increase
  FROM cte1
)

SELECT CAST(100.0*COUNT(DISTINCT customer_id)/(SELECT COUNT(DISTINCT customer_id)FROM customer_transactions) AS FLOAT) as pct_customer 
FROM cte2
where pct_increase > 5;

---------------------------------------QC1

SELECT * FROM customer_nodes;
SELECT * FROM regions;
SELECT * FROM customer_transactions;

SELECT customer_id,
        txn_date,
        txn_type,
        txn_amount,
        SUM(CASE WHEN txn_type='deposit' THEN txn_amount 
                WHEN txn_type = 'withdrawal' THEN -txn_amount
                WHEN txn_type = 'purchase' THEN -txn_amount
            ELSE 0 
            END ) OVER(PARTITION BY customer_id ORDER BY txn_date) AS running_balance
FROM customer_transactions;

---------------------------------------QC2
SELECT customer_id,
        MONTH(txn_date) AS month,
        MONTHNAME(txn_date) AS month_name,
        SUM (CASE WHEN txn_type ='deposit' THEN txn_amount 
                WHEN txn_type = 'withdrawal' THEN -txn_amount
                WHEN txn_type = 'purchase' THEN -txn_amount
            ELSE 0 
            END ) AS closing_balance
FROM customer_transactions
GROUP BY customer_id, month,month_name
ORDER BY  customer_id;

---------------------------------------QC3
WITH cte AS(
    SELECT customer_id,
            txn_date,
            txn_type,
            txn_amount,
            SUM(CASE WHEN txn_type='deposit' THEN txn_amount 
                    WHEN txn_type = 'withdrawal' THEN -txn_amount
                    WHEN txn_type = 'purchase' THEN -txn_amount
                ELSE 0 
                END ) OVER(PARTITION BY customer_id ORDER BY txn_date) AS running_balance
    FROM customer_transactions
)

SELECT customer_id,
        ROUND(AVG(running_balance),2) AS average_running_balance,
        ROUND(MIN(running_balance),2) AS minimum_running_balance,
        ROUND(MAX(running_balance),2) AS maximum_running_balance
FROM cte
GROUP BY customer_id
ORDER BY customer_id;

---------------------------------------QC4
WITH transaction_amt_cte AS
(
	SELECT customer_id,
	       txn_date,
	       MONTH(txn_date) AS txn_month,
	       txn_type,
	       CASE WHEN txn_type = 'deposit' THEN txn_amount 
		    ELSE -txn_amount 
	       END AS net_transaction_amt
	FROM customer_transactions
),

running_customer_balance_cte AS
(
	SELECT customer_id,
	       txn_date,
	       txn_month,
	       net_transaction_amt,
	       SUM(net_transaction_amt) OVER(PARTITION BY customer_id, txn_month ORDER BY txn_date
	       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_customer_balance
	FROM transaction_amt_cte
),

customer_end_month_balance_cte AS
(
	SELECT customer_id,
	       txn_month,
	       MAX(running_customer_balance) AS month_end_balance
	FROM running_customer_balance_cte
	GROUP BY customer_id, txn_month
)

SELECT txn_month,
       SUM(month_end_balance) AS data_required_per_month
FROM customer_end_month_balance_cte
GROUP BY txn_month
ORDER BY data_required_per_month DESC;

---------------------------------------QC5

WITH transaction_amt_cte AS
(
	SELECT customer_id,
               MONTH(txn_date) AS txn_month,
	       SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
		        ELSE -txn_amount
		    END) AS net_transaction_amt
	FROM customer_transactions
	GROUP BY customer_id, MONTH(txn_date)
),

running_customer_balance_cte AS
(
	SELECT customer_id,
	       txn_month,
	       net_transaction_amt,
	       SUM(net_transaction_amt) OVER(PARTITION BY customer_id ORDER BY txn_month) AS running_customer_balance
	FROM transaction_amt_cte
), 

avg_running_customer_balance AS
(
	SELECT customer_id,
	       AVG(running_customer_balance) AS avg_running_customer_balance
	FROM running_customer_balance_cte
	GROUP BY customer_id
)

SELECT txn_month,
       ROUND(SUM(avg_running_customer_balance), 0) AS data_required_per_month
FROM running_customer_balance_cte r
JOIN avg_running_customer_balance a
ON r.customer_id = a.customer_id
GROUP BY txn_month
ORDER BY data_required_per_month;

---------------------------------------QC6

WITH transaction_amt_cte AS
(
	SELECT customer_id,
	       txn_date,
	       MONTH(txn_date) AS txn_month,
	       txn_type,
	       txn_amount,
	       (CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE -txn_amount END) AS net_transaction_amt
	FROM customer_transactions
),

running_customer_balance_cte AS
(
	SELECT customer_id,
	       txn_month,
	       SUM(net_transaction_amt) OVER (PARTITION BY customer_id ORDER BY txn_month) AS running_customer_balance
	FROM transaction_amt_cte
)

SELECT txn_month,
       SUM(running_customer_balance) AS data_required_per_month
FROM running_customer_balance_cte
GROUP BY txn_month
ORDER BY data_required_per_month;

---------------------------------------QD
SELECT * FROM customer_nodes;
SELECT * FROM regions;
SELECT * FROM customer_transactions;


WITH cte AS (
	SELECT customer_id,
	       txn_date,
	       SUM(txn_amount) AS total_data,
         DATE(CONCAT_WS('-', YEAR(txn_date),  MONTH(txn_date), 1))AS month_start_date,
	       DATEDIFF(txn_date, DATE(CONCAT_WS('-', YEAR(txn_date),  MONTH(txn_date), 1))) AS days_in_month,
	       CAST(SUM(txn_amount) AS DECIMAL(18, 2)) * POWER((1 + 0.06/365), DATEDIFF(txn_date,'1900-01-01')) AS daily_interest_data
	FROM customer_transactions
	GROUP BY customer_id, txn_date
)

SELECT customer_id,
      DATE(CONCAT_WS('-', YEAR(month_start_date),  MONTH(month_start_date), 1)) AS txn_month, 
       ROUND(SUM(daily_interest_data * days_in_month), 2) AS data_required
FROM cte
GROUP BY customer_id, DATE(CONCAT_WS('-', YEAR(month_start_date),  MONTH(month_start_date), 1))
ORDER BY data_required DESC;

--REFER to https://github.com/Chisomnwa/SQL-Challenge-Case-Study-4---Data-Bank/blob/main/D.%20Extra%20Challenge.md 
