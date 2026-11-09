#!/bin/bash
# =============================================================================
# TASK 1 - Fotografia iniziale dei dischi (SOLA LETTURA)
# Mostra per ogni VM RHEL: dischi, partizioni, volumi LVM, spazio di /opt e /data.
# Linux: lsblk, vgs, df -h /opt /data
#
# Da lanciare da /root/fews-ansible (ansible.cfg, inventory.yml, disks.yml, site.yml)
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")" || exit 2
[[ -f ansible.cfg && -f inventory.yml && -f disks.yml ]] || { echo "Mancano ansible.cfg/inventory.yml/disks.yml nella cartella: copiare qui disks.yml"; exit 2; }
LOG="log-$(basename "$0" .sh)-$(date +%F_%H%M).log"
ansible-playbook disks.yml --tags check 2>&1 | tee "$LOG"
echo; echo "Salvato in $LOG. Prossimo: task2.sh"
