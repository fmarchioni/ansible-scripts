read -rs -p 'Password dba_admin: ' PGPASSWORD; echo; export PGPASSWORD
ansible '*postgres-prod-01' -m shell -a "PGPASSWORD='{{ lookup('env','PGPASSWORD') }}' psql -h 10.65.47.15 -U dba_admin -d postgres -XAtc 'select current_user, inet_server_addr(), version()'"
ansible '*postgres-prod-02' -m shell -a "PGPASSWORD='{{ lookup('env','PGPASSWORD') }}' psql -h 10.65.47.14 -U dba_admin -d postgres -XAtc 'select current_user, inet_server_addr(), version()'"
unset PGPASSWORD
