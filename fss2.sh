ansible '*fss-prod-02' -m shell -a "sed -i 's|^[[:space:]]*/dev/mapper/vg_data|/dev/mapper/vg_data|' /etc/fstab; grep -c '^/dev/mapper/vg_data' /etc/fstab; findmnt --verify | tail -2"
