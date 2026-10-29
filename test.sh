ansible '*postgres*' -m shell -a "runuser -u postgres -- psql -XAtc \"select version(); show data_directory; show TimeZone; select pg_is_in_recovery();\""
