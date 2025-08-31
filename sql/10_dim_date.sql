-- dim_date for GA4 E-commerce Analytics
CREATE OR REPLACE TABLE `global-booster-451302-r3.analytics_ga4.dim_date` AS
WITH bounds AS (
  SELECT
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS min_date,
    MAX(PARSE_DATE('%Y%m%d', event_date)) AS max_date
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
),
calendar AS (
  SELECT d AS date_pk
  FROM bounds, UNNEST(GENERATE_DATE_ARRAY(min_date, max_date)) AS d
)
SELECT
  date_pk,
  EXTRACT(YEAR FROM date_pk)            AS year,
  EXTRACT(MONTH FROM date_pk)           AS month,
  FORMAT_DATE('%B', date_pk)            AS month_name,
  EXTRACT(ISOWEEK FROM date_pk)         AS week,
  FORMAT_DATE('%A', date_pk)            AS day_name
FROM calendar
ORDER BY date_pk;
