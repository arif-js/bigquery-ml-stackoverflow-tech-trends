-- Step 2: Train a multi-series ARIMA+ forecasting model.
-- We limit this to the top 50 tags to ensure the model has dense, high-quality data.
CREATE OR REPLACE MODEL `my_datasets.multi_tag_forecast`
OPTIONS(
  model_type='ARIMA_PLUS',
  time_series_timestamp_col='date_only',
  time_series_data_col='total_posts',
  TIME_SERIES_ID_COL='tag'
) AS
SELECT 
    tag,
    DATE(creation_date) as date_only, 
    SUM(post_count) as total_posts
FROM `bigquery-pipeline-analytics.my_datasets.daily_tech_stats`
WHERE tag IN (
    SELECT tag FROM `bigquery-pipeline-analytics.my_datasets.daily_tech_stats`
    GROUP BY tag ORDER BY SUM(post_count) DESC LIMIT 50
)
GROUP BY tag, date_only;