#!/bin/bash
# =============================================================================
# TASK 2 - Installa gli strumenti per allargare la partizione (nessun impatto su dischi/servizi)
# Sulle 12 VM interessate (tutte le RHEL tranne postgres) installa cloud-utils-growpart e gdisk.
# Linux: dnf install -y cloud-utils-growpart gdisk
# Da lanciare da /root/fews-ansible (ansible.cfg, inventory.yml, disks.yml, site.yml)
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")" || exit 2
[[ -f ansible.cfg && -f inventory.yml && -f disks.yml ]] || { echo "Mancano ansible.cfg/inventory.yml/disks.yml nella cartella: copiare qui disks.yml"; exit 2; }
LOG="log-$(basename "$0" .sh)-$(date +%F_%H%M).log"
ansible 'fews_rhel:!*postgres*' -m dnf -a "name=cloud-utils-growpart,gdisk state=present" 2>&1 | tee "$LOG"
echo; echo "Atteso: nessun FAILED. Prossimo: Gianluca ingrandisce il disco di sistema delle 12 VM (50->60 GB), poi task3.sh"
