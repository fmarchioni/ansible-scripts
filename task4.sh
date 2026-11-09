#!/bin/bash
# =============================================================================
# TASK 4 - Rimozione /data: preparazione su UNA VM di prova (adminint-prod-01)
# Si ferma se /data contiene qualcosa o e' in uso. Smonta /data, toglie la riga da /etc/fstab
# (con backup), rimuove LVM (vg_data), stacca il disco da Linux e STAMPA IL DISCO da rimuovere in vCD.
# Linux: find /data, fuser -m /data, umount /data, (fstab), vgremove, pvremove, echo 1 > .../device/delete
# Da lanciare da /root/fews-ansible (ansible.cfg, inventory.yml, disks.yml, site.yml)
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")" || exit 2
[[ -f ansible.cfg && -f inventory.yml && -f disks.yml ]] || { echo "Mancano ansible.cfg/inventory.yml/disks.yml nella cartella: copiare qui disks.yml"; exit 2; }
LOG="log-$(basename "$0" .sh)-$(date +%F_%H%M).log"
read -r -p "Questo passo MODIFICA le VM. Procedo? [s/N] " a; [[ "$a" =~ ^[sS]$ ]] || { echo "Annullato."; exit 0; }
ansible-playbook disks.yml --tags data-prepare -e "data_hosts='*adminint-prod-01'" 2>&1 | tee "$LOG"
echo; echo "Annota il disco stampato (es. sdb 60G SCSI 0:0:1:0) e passalo a Gianluca. Prossimo: task5.sh"
