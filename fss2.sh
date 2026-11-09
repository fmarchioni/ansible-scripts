ansible fews_nfs -k -K -m shell -a "apt-get update -qq && apt-get install -y open-vm-tools && systemctl is-active open-vm-tools"
