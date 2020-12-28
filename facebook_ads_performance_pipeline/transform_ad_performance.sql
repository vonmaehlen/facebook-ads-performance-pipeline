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
  conversion_value   DOUBLE PRECISION,

  add_to_carts       INTEGER,
  add_to_cart_value  DOUBLE PRECISION,

  initiate_checkouts INTEGER,
  initiate_checkout_value DOUBLE PRECISION,

  purchases          INTEGER,
  purchase_value     DOUBLE PRECISION,

  leads              INTEGER,
  lead_value         DOUBLE PRECISION,

  registrations      INTEGER,
  registration_value DOUBLE PRECISION

);


INSERT INTO fb_dim_next.ad_performance
  SELECT
    to_char(date, 'YYYYMMDD') :: BIGINT AS day_fk,
    perf.ad_id                          AS ad_fk,

    device_id                           AS device_fk,

    NULLIF(impressions, 0) AS impressions,
    NULLIF(inline_link_clicks, 0) AS inline_link_clicks,
    NULLIF(spend, 0) AS spend,

    NULLIF(conversions, 0) AS conversions,
    NULLIF(conversion_value, 0) AS conversion_value,

    NULLIF(add_to_carts, 0) AS add_to_carts,
    NULLIF(add_to_cart_value, 0) AS add_to_cart_value,

    NULLIF(initiate_checkouts, 0) AS initiate_checkouts,
    NULLIF(initiate_checkout_value, 0) AS initiate_checkout_value,

    NULLIF(purchases, 0) AS purchases,
    NULLIF(purchase_value, 0) AS purchase_value,

    NULLIF(leads, 0) AS leads,
    NULLIF(lead_value, 0) AS lead_value,

    NULLIF(registrations, 0) AS registrations,
    NULLIF(registration_value, 0) AS registration_value

  FROM fb_data.ad_performance perf
    LEFT JOIN fb_dim_next.device ON perf.device = device_name;


CREATE FUNCTION fb_tmp.constrain_ad_performance()
  RETURNS VOID AS $$

SELECT util.add_fk('fb_dim_next', 'ad_performance', 'time', 'day');
SELECT util.add_fk('fb_dim_next', 'ad_performance', 'fb_dim_next', 'ad');
SELECT util.add_fk('fb_dim_next', 'ad_performance', 'fb_dim_next', 'device');

$$ LANGUAGE SQL;
