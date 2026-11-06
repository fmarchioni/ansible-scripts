ansible fews_nfs -k -K -b -m shell -a "id fews-user; echo '--- uid/gid 1001:'; getent passwd 1001; getent group 1001; echo '--- gruppo sudo:'; getent group sudo"
