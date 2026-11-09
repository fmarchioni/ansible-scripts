ansible-playbook ~/ansible-scripts/disks.yml --tags check | tee dischi-prima-$(date +%F).log

# il volume di sistema deve stare sull'ultima partizione del disco (requisito per allargarlo)
ansible 'fews_rhel:!*postgres*' -m shell -a "lsblk -nlo NAME,TYPE,SIZE /dev/sda; pvs --noheadings -o pv_name,vg_name"

# /data vuoto e non in uso su adminint e dbproxy
ansible '*adminint*:*dbproxy*' -m shell -a "find /data -mindepth 1 | wc -l; fuser -vm /data 2>&1 | tail -n +2"
