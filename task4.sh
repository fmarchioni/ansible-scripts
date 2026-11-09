#!/bin/bash
# =============================================================================
# TASK 4 - /opt +10 GB sulle 12 VM (una alla volta; adminint-prod-01 gia' fatta viene saltata)
# PREREQUISITO: Gianluca ha ingrandito in vCD il disco di sistema delle altre 11 VM a 60 GB.
# VM: adminint-01/02, dbproxy-01/02, mc-01/02, fss-01/02/03, openarchive-01, websrv-01/02
# Da lanciare da /root/fews-ansible (ansible.cfg, inventory.yml, disks.yml, site.yml)
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")" || exit 2
[[ -f ansible.cfg && -f inventory.yml && -f disks.yml ]] || { echo "Mancano ansible.cfg/inventory.yml/disks.yml nella cartella: copiare qui disks.yml"; exit 2; }
LOG="log-$(basename "$0" .sh)-$(date +%F_%H%M).log"
read -r -p "Questo passo MODIFICA le VM. Procedo? [s/N] " a; [[ "$a" =~ ^[sS]$ ]] || { echo "Annullato."; exit 0; }
ansible-playbook disks.yml --tags opt -e "opt_hosts='fews_rhel:!*postgres*'" 2>&1 | tee "$LOG"
echo; echo "Atteso: /opt a ~21G su tutte e failed=0. Punto 1 completato. Prossimo: task5.sh"
