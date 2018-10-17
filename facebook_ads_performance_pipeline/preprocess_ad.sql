CREATE TABLE fb_tmp.ad (
  ad_id         BIGINT NOT NULL,
  ad_name       TEXT   NOT NULL,
  ad_set_id     BIGINT NOT NULL,
  ad_set_name   TEXT   NOT NULL,
  campaign_id   BIGINT NOT NULL,
  campaign_name TEXT   NOT NULL,
  account_id    BIGINT NOT NULL,
  account_name  TEXT   NOT NULL,
  attributes    JSONB  NOT NULL
);

INSERT INTO fb_tmp.ad
  SELECT
    ad_id,
    ad_name,
    ad_set_id,
    ad_set_name,
    campaign_id,
    campaign_name,
    account_id,
    account_name,
    attributes
  FROM fb_data.campaign_structure
  WHERE ad_id IN (SELECT DISTINCT ad_id
                  FROM fb_data.ad_performance);

-- create entries for ad sets that don't appear in the facebook campaign structure
INSERT INTO fb_tmp.ad
  SELECT
    DISTINCT
    ad_id,
    'deleted facebook ad ' AS ad_name,
    -1                     AS ad_set_id,
    'deleted facebook ad'  AS ad_set_name,
    -1                     AS campaign_id,
    'deleted facebook ad'  AS campaign_name,
    -1                     AS account_id,
    'deleted facebook ad'  AS account_name,
    '{}' :: JSONB          AS attributes

  FROM fb_data.ad_performance
  WHERE ad_id NOT IN (SELECT ad_id
                      FROM fb_tmp.ad)
        AND ad_id IS NOT NULL;
