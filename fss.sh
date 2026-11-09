ansible fews_nfs -k -K -m shell -a "dpkg -l open-vm-tools | tail -1; systemctl is-active open-vm-tools"
