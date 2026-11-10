grep -E "Dopo:|dischi liberi|attesi" log-task11-*.log | tail -3
ansible fews_nfs -k -K -m shell -a "lsblk -dno NAME,SIZE -e 11 | xargs; pvs --noheadings -o pv_name,vg_name; df -h /data | tail -1"
