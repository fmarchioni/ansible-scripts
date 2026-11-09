#!/bin/bash
# =============================================================================
# TASK 6 - Rimozione /data: verifica dopo la rimozione in vCD (SOLA LETTURA)
# PREREQUISITO: Gianluca ha rimosso i dischi /data delle 4 VM.
# Linux: lsblk, vgs vg_data, grep /data /etc/fstab, systemctl --failed
# Da lanciare da /root/fews-ansible (ansible.cfg, inventory.yml, disks.yml, site.yml)
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")" || exit 2
[[ -f ansible.cfg && -f inventory.yml && -f disks.yml ]] || { echo "Mancano ansible.cfg/inventory.yml/disks.yml nella cartella: copiare qui disks.yml"; exit 2; }
LOG="log-$(basename "$0" .sh)-$(date +%F_%H%M).log"
ansible-playbook disks.yml --tags data-verify -e "data_hosts='*adminint*:*dbproxy*'" 2>&1 | tee "$LOG"
echo; echo "Atteso: vg_data: assente, fstab /data: 0, unita systemd in errore: 0. Prossimo: task7.sh"
