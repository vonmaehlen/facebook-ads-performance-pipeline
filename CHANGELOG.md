# Changelog

## 1.0.1 (2019-08-22)

* Fix dependency name change
* Use default DB connection for pipeline instead of hardcoded one. Use `patch(data_integration.config.default_db_alias)(lambda: '<YOUR ETL alias here>')` in your local_setup.py to configure if not done so already.




## 1.0.0 (2018-28-09)

Initial version
