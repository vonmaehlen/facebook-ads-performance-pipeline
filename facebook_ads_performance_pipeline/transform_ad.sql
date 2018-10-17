CREATE TABLE fb_dim_next.ad (
  ad_id         BIGINT NOT NULL,
  ad_name       TEXT   NOT NULL,
  ad_set_name   TEXT   NOT NULL,
  campaign_name TEXT   NOT NULL,
  account_name  TEXT   NOT NULL,

  _attributes   JSONB  NOT NULL
);

INSERT INTO fb_dim_next.ad
  SELECT
    ad_id,
    ad_name,
    ad_set_name,
    campaign_name,
    account_name,
    attributes
  FROM fb_tmp.ad;

SELECT util.add_pk('fb_dim_next', 'ad');
