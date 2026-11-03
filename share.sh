ansible fews_fss -m shell -a "findmnt /shared; df -h /shared | tail -1; sudo -u fews-user touch /shared/.test-fews && echo SCRITTURA_OK && rm -f /shared/.test-fews"
