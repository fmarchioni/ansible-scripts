#!/bin/bash
# =============================================================================
# TASK 5 - Rimozione /data: preparazione sulle altre 3 VM (adminint-02, dbproxy-01/02)
# adminint-prod-01 (gia' fatta) viene riconosciuta e saltata.
# Da lanciare da /root/fews-ansible (ansible.cfg, inventory.yml, disks.yml, site.yml)
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")" || exit 2
[[ -f ansible.cfg && -f inventory.yml && -f disks.yml ]] || { echo "Mancano ansible.cfg/inventory.yml/disks.yml nella cartella: copiare qui disks.yml"; exit 2; }
LOG="log-$(basename "$0" .sh)-$(date +%F_%H%M).log"
read -r -p "Questo passo MODIFICA le VM. Procedo? [s/N] " a; [[ "$a" =~ ^[sS]$ ]] || { echo "Annullato."; exit 0; }
ansible-playbook disks.yml --tags data-prepare -e "data_hosts='*adminint*:*dbproxy*'" 2>&1 | tee "$LOG"
echo; echo '--- Dischi da comunicare a Gianluca:'; grep -E "sd[a-z]+ [0-9.]+G SCSI" "$LOG" | sed 's/^ *//'
echo; echo "Prossimo: Gianluca rimuove i dischi indicati in vCD (controllando che siano da 60 GB), poi task6.sh"
