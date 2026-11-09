ansible-playbook site.yml --tags verify -l 'all:!lab' -k -K | tee log-collaudo-$(date +%F_%H%M).log
