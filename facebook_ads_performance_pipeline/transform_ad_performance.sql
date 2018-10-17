CREATE TABLE fb_dim_next.device (
  device_id   SMALLSERIAL PRIMARY KEY,
  device_name TEXT NOT NULL
);

INSERT INTO fb_dim_next.device (device_name)
  SELECT DISTINCT device
  FROM fb_data.ad_performance
  ORDER BY device;

CREATE TABLE fb_dim_next.ad_performance (
  day_fk             BIGINT   NOT NULL,
  ad_fk              BIGINT   NOT NULL,
  device_fk          SMALLINT NOT NULL,

  impressions        INTEGER,
  inline_link_clicks INTEGER,
  spend              DOUBLE PRECISION,
  conversions        INTEGER,
  conversion_value   DOUBLE PRECISION
);


INSERT INTO fb_dim_next.ad_performance
  SELECT
    to_char(date, 'YYYYMMDD') :: BIGINT AS day_fk,
    perf.ad_id                          AS ad_fk,

    device_id                           AS device_fk,

    NULLIF(impressions, 0),
    NULLIF(inline_link_clicks, 0),
    NULLIF(spend, 0),
    NULLIF(conversions, 0),
    NULLIF(conversion_value, 0)

  FROM fb_data.ad_performance perf
    LEFT JOIN fb_dim_next.device ON perf.device = device_name;


CREATE FUNCTION fb_tmp.constrain_ad_performance()
  RETURNS VOID AS $$

SELECT util.add_fk('fb_dim_next', 'ad_performance', 'time', 'day');
SELECT util.add_fk('fb_dim_next', 'ad_performance', 'fb_dim_next', 'ad');
SELECT util.add_fk('fb_dim_next', 'ad_performance', 'fb_dim_next', 'device');

$$ LANGUAGE SQL;
