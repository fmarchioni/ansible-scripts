# il volume di sistema deve stare sull'ultima partizione del disco (requisito per allargarlo)
ansible 'fews_rhel:!*postgres*' -m shell -a "lsblk -nlo NAME,TYPE,SIZE /dev/sda; pvs --noheadings -o pv_name,vg_name"


