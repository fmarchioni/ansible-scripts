ansible '*postgres-prod-01' -m shell -a "dnf -q module info postgresql:15 | grep -oE 'postgresql-server-(0:)?15[^ ]*' | sort -uV"
