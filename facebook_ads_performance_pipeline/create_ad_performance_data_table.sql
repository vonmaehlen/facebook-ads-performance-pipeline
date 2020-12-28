DROP TABLE IF EXISTS fb_data.ad_performance CASCADE;

CREATE TABLE fb_data.ad_performance (
  date               DATE             NOT NULL,
  ad_id              BIGINT           NOT NULL,
  device             TEXT             NOT NULL,

  impressions        DOUBLE PRECISION NOT NULL,
  inline_link_clicks DOUBLE PRECISION,
  spend              DOUBLE PRECISION,

  conversions        DOUBLE PRECISION,
  conversion_value   DOUBLE PRECISION,

  add_to_carts       DOUBLE PRECISION,
  add_to_cart_value  DOUBLE PRECISION,

  initiate_checkouts DOUBLE PRECISION,
  initiate_checkout_value DOUBLE PRECISION,

  purchases          DOUBLE PRECISION,
  purchase_value     DOUBLE PRECISION,

  leads              DOUBLE PRECISION,
  lead_value         DOUBLE PRECISION,

  registrations      DOUBLE PRECISION,
  registration_value DOUBLE PRECISION
);

-- needed for upserting
SELECT util.add_index('fb_data', 'ad_performance', column_names := ARRAY ['date']);

-- create an exact copy of the data table. New data will be copied here
DROP TABLE IF EXISTS fb_data.ad_performance_upsert;

CREATE TABLE fb_data.ad_performance_upsert AS
  SELECT *
  FROM fb_data.ad_performance
  LIMIT 0;


CREATE OR REPLACE FUNCTION fb_data.upsert_ad_performance()
  RETURNS VOID AS '

-- rather than doing a proper upsert, first data for the dates and ad_ids in the upsert table
DELETE FROM fb_data.ad_performance
USING fb_data.ad_performance_upsert
WHERE ad_performance_upsert.date = ad_performance.date
      AND ad_performance_upsert.ad_id = ad_performance.ad_id
      AND ad_performance_upsert.device = ad_performance.device;

-- copy new data in
INSERT INTO fb_data.ad_performance
  SELECT *
  FROM fb_data.ad_performance_upsert;

-- remove tmp data
TRUNCATE fb_data.ad_performance_upsert;

'
LANGUAGE SQL;
