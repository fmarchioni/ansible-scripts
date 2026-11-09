#!/bin/bash
# =============================================================================
# TASK 3 - /opt +10 GB su UNA VM di prova (adminint-prod-01)
# PREREQUISITO: Gianluca ha ingrandito in vCD il disco di sistema di adminint-prod-01 a 60 GB.
# A caldo, non distruttivo. Linux: rescan disco, growpart /dev/sda 3, pvresize /dev/sda3,
# lvextend -r -l +100%FREE /dev/rhel/opt, df -h /opt
# Da lanciare da /root/fews-ansible (ansible.cfg, inventory.yml, disks.yml, site.yml)
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")" || exit 2
[[ -f ansible.cfg && -f inventory.yml && -f disks.yml ]] || { echo "Mancano ansible.cfg/inventory.yml/disks.yml nella cartella: copiare qui disks.yml"; exit 2; }
LOG="log-$(basename "$0" .sh)-$(date +%F_%H%M).log"
read -r -p "Questo passo MODIFICA le VM. Procedo? [s/N] " a; [[ "$a" =~ ^[sS]$ ]] || { echo "Annullato."; exit 0; }
ansible-playbook disks.yml --tags opt -e "opt_hosts='*adminint-prod-01'" 2>&1 | tee "$LOG"
echo; echo "Atteso: \"/opt ora: ... 21G\" e failed=0. Prossimo: Gianluca ingrandisce le altre 11 VM, poi task4.sh"
