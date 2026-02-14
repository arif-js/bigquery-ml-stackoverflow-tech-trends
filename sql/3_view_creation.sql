-- Step 3: Create a unified view for the Looker Studio dashboard.
-- This view merges history (ACTUAL) and predictions (FORECAST) with 90% confidence intervals.
CREATE OR REPLACE VIEW `my_datasets.v_stackoverflow_trends_forecast` AS
WITH historical_data AS (
  SELECT 
    tag,
    DATE(creation_date) as record_date,
    SUM(post_count) as post_count,
    CAST(NULL AS FLOAT64) as lower_bound,
    CAST(NULL AS FLOAT64) as upper_bound,
    'ACTUAL' as data_type
  FROM `bigquery-pipeline-analytics.my_datasets.daily_tech_stats`
  GROUP BY tag, record_date
),
forecast_data AS (
  SELECT
    tag,
    DATE(forecast_timestamp) as record_date,
    forecast_value as post_count,
    prediction_interval_lower_bound as lower_bound,
    prediction_interval_upper_bound as upper_bound,
    'FORECAST' as data_type
  FROM
    ML.FORECAST(MODEL `my_datasets.multi_tag_forecast`,
                STRUCT(30 AS horizon, 0.9 AS confidence_level))
)
SELECT * FROM historical_data
UNION ALL
SELECT * FROM forecast_data;