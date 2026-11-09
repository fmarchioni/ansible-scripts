#!/bin/bash
# =============================================================================
# TASK 9 - Collaudo finale (SOLA LETTURA)
# Fotografia dei dischi 'dopo' e collaudo completo delle VM.
# Da lanciare da /root/fews-ansible (ansible.cfg, inventory.yml, disks.yml, site.yml)
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")" || exit 2
[[ -f ansible.cfg && -f inventory.yml && -f disks.yml ]] || { echo "Mancano ansible.cfg/inventory.yml/disks.yml nella cartella: copiare qui disks.yml"; exit 2; }
LOG="log-$(basename "$0" .sh)-$(date +%F_%H%M).log"
ansible-playbook disks.yml --tags check 2>&1 | tee "$LOG"
ansible-playbook site.yml --tags verify 2>&1 | tee -a "$LOG"
echo; echo "Atteso: /opt ~21G sulle 12 VM, nessun /data su adminint/dbproxy, verify senza failed. Esito in $LOG"
