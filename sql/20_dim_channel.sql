-- dim_channel: derive simple channel groups from GA4 traffic_source
CREATE OR REPLACE TABLE `global-booster-451302-r3.analytics_ga4.dim_channel` AS
WITH src AS (
  SELECT
    COALESCE(traffic_source.source, '(unknown)') AS source,
    COALESCE(traffic_source.medium, '(unknown)') AS medium
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name IS NOT NULL
  GROUP BY 1,2
),
labeled AS (
  SELECT
    source,
    medium,
    CASE
      WHEN LOWER(medium) LIKE '%organic%'              THEN 'Organic Search'
      WHEN LOWER(source) IN ('google','bing','yahoo') 
           AND LOWER(medium) IN ('cpc','ppc','paid','paid-search') THEN 'Paid Search'
      WHEN LOWER(medium) IN ('email')                  THEN 'Email'
      WHEN LOWER(medium) IN ('social','social-network','social-media')
           OR LOWER(source) IN ('facebook','twitter','instagram','linkedin') THEN 'Social'
      WHEN LOWER(medium) IN ('affiliate')              THEN 'Affiliate'
      WHEN LOWER(medium) IN ('referral')               THEN 'Referral'
      WHEN LOWER(medium) IN ('display','cpm','banner') THEN 'Display'
      WHEN LOWER(medium) IN ('(none)','none','direct') OR source = '(direct)' THEN 'Direct'
      ELSE 'Other'
    END AS channel_group
  FROM src
)
SELECT
  ROW_NUMBER() OVER (ORDER BY channel_group, source, medium) AS channel_key,
  channel_group,
  source,
  medium
FROM labeled
ORDER BY channel_key;
