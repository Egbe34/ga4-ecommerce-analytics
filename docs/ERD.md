# ERD – GA4 E-commerce Analytics

## Purpose
Business-ready semantic layer for funnel analytics and ML.

## Entities
- **dim_date**(date_pk, year, month, week, day_name)
- **dim_channel**(channel_key, channel_group, source, medium)
- **fact_funnel_by_date_channel**(date_pk, channel_key, sessions, add_to_cart, purchases, revenue, conversion_rate, aov)
- **ml_conversion_scores**(date_pk, channel_key, segment, score)

## Notes
- conversion_rate = purchases / sessions
- aov = revenue / purchases
- Keys: (date_pk, channel_key)
