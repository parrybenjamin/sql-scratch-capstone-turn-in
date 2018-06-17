WITH months AS (
SELECT 
  '2017-01-01' AS first_day,
  '2017-01-31' AS last_day
UNION
SELECT 
  '2017-02-01' AS first_day,
  '2017-02-28' AS last_day
UNION
SELECT 
  '2017-03-01' AS first_day,
  '2017-03-31' AS last_day
), 

cross_join AS (
SELECT *
FROM subscriptions
CROSS JOIN months
), 

status AS (
SELECT id, 
	first_day AS month, 
	CASE
		WHEN subscription_start < first_day AND (subscription_end > first_day OR subscription_end IS NULL) THEN 1
		ELSE 0
	END AS is_active,		
    CASE
		WHEN subscription_end BETWEEN first_day AND last_day THEN 1
		ELSE 0
	END AS is_cancelled
FROM cross_join
),

status_aggregate AS (
SELECT month, 
	SUM(is_active) AS sum_active, 
	SUM(is_cancelled) AS sum_cancelled
FROM status
GROUP BY month
)

SELECT month, 
	ROUND(1.0 * sum_cancelled / sum_active,2) AS churn_rate 
FROM status_aggregate;