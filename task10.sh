#!/bin/bash
# =============================================================================
# TASK 10 - Verifica di fss e openarchive dopo la rimozione dei dischi in vCD (SOLA LETTURA)
# PRIMA DI LANCIARE: Gianluca ha rimosso in vCD i dischi indicati da task9.sh.
# Linux: lsblk, df -h /data, pvs, findmnt /shared, systemctl --failed
# Da lanciare da /root/fews-ansible (ansible.cfg, inventory.yml, disks.yml, site.yml)
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")" || exit 2
[[ -f ansible.cfg && -f inventory.yml && -f disks.yml ]] || { echo "Mancano ansible.cfg/inventory.yml/disks.yml nella cartella: copiare qui disks.yml"; exit 2; }
LOG="log-$(basename "$0" .sh)-$(date +%F_%H%M).log"
ansible-playbook disks.yml --tags data-shrink-verify -e "shrink_hosts='fews_fss:*openarchive*'" 2>&1 | tee "$LOG"
echo; echo "Atteso: fss /data ~300G con 2 dischi, openarchive /data ~150G con 1 disco, /shared ancora montato, 0 unita in errore. Prossimo: task11.sh"
