DROP TABLE IF EXISTS fb_data.campaign_structure;

CREATE TABLE fb_data.campaign_structure (
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
