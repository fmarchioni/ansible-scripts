ansible fews_rhel -m shell -a "echo 1 > /sys/class/block/sda/device/rescan; lsblk -dno NAME,SIZE -e 11 | xargs" | sed 's/mase-prod-vm-vml-fd-//'
