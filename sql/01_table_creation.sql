-- Step 1: Create a partitioned and clustered table for daily tag statistics.
-- Partitioning by date reduces scan costs for time-series analysis.
-- Clustering by tag speeds up filtering for specific technologies.
CREATE OR REPLACE TABLE `bigquery-pipeline-analytics.my_datasets.daily_tech_stats`
PARTITION BY DATE(creation_date)
CLUSTER BY tag 
AS
SELECT 
    creation_date,
    tag,
    COUNT(*) as post_count
FROM `bigquery-public-data.stackoverflow.posts_questions`,
UNNEST(SPLIT(tags, '|')) as tag
WHERE creation_date >= '2020-01-01'
GROUP BY 1, 2;