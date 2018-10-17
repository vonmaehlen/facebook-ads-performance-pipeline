SELECT
  date,
  ad_id,
  device,

  json_extract(performance, '$.impressions') AS impressions,

  (SELECT json_extract(action.value, '$.value')
   FROM ad_performance t2, json_each(performance, '$.actions') AS action
   WHERE json_extract(action.value, '$.action_type') == 'link_click'
         AND t2.ad_id = t1.ad_id AND t2.device = t1.device)
                                             AS inline_link_clicks,

  json_extract(performance, '$.spend')       AS spend,

  (SELECT sum(json_extract(action.value, '$.value'))
   FROM ad_performance t2, json_each(performance, '$.actions') AS action
   WHERE json_extract(action.value, '$.action_type') IN
         ('offsite_conversion.fb_pixel_purchase', 'offsite_conversion.fb_pixel_lead')
         AND t2.ad_id = t1.ad_id AND t2.device = t1.device)
                                             AS conversions,

  (SELECT sum(json_extract(action_value.value, '$.value'))
   FROM ad_performance t2, json_each(performance, '$.action_values') AS action_value
   WHERE json_extract(action_value.value, '$.action_type') IN
         ('offsite_conversion.fb_pixel_purchase', 'offsite_conversion.fb_pixel_lead')
         AND t2.ad_id = t1.ad_id AND t2.device = t1.device)
                                             AS conversion_value
FROM ad_performance t1;
