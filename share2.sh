ansible fews_fss -m shell -a "findmnt -t nfs,nfs4; grep -i nfs /etc/fstab; rpm -q nfs-utils; ls -ld /shared; last reboot | head -2"
