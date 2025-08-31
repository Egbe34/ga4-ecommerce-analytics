-- FACT: sessions, add_to_cart, purchases, revenue by date & channel
CREATE OR REPLACE TABLE `global-booster-451302-r3.analytics_ga4.fact_funnel_by_date_channel` AS

WITH base AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS date_pk,
    COALESCE(traffic_source.source, '(unknown)') AS source,
    COALESCE(traffic_source.medium, '(unknown)') AS medium,
    event_name,
    ecommerce.purchase_revenue AS purchase_revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
),
joined AS (
  SELECT
    b.date_pk,
    dc.channel_key,
    dc.channel_group,
    b.event_name,
    b.purchase_revenue
  FROM base b
  LEFT JOIN `global-booster-451302-r3.analytics_ga4.dim_channel` dc
    ON dc.source = b.source
   AND dc.medium = b.medium
)
SELECT
  j.date_pk,
  j.channel_key,
  j.channel_group,
  COUNTIF(j.event_name = 'session_start') AS sessions,
  COUNTIF(j.event_name = 'add_to_cart')   AS add_to_cart,
  COUNTIF(j.event_name = 'purchase')      AS purchases,
  SUM(IF(j.event_name = 'purchase', IFNULL(j.purchase_revenue, 0), 0)) AS revenue,
  SAFE_DIVIDE(COUNTIF(j.event_name = 'purchase'),
              NULLIF(COUNTIF(j.event_name = 'session_start'), 0)) AS conversion_rate,
  SAFE_DIVIDE(SUM(IF(j.event_name = 'purchase', IFNULL(j.purchase_revenue, 0), 0)),
              NULLIF(COUNTIF(j.event_name = 'purchase'), 0)) AS aov
FROM joined j
JOIN `global-booster-451302-r3.analytics_ga4.dim_date` d
  ON d.date_pk = j.date_pk
GROUP BY 1,2,3
ORDER BY 1,3;
