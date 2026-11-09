#!/bin/bash
# =============================================================================
# TASK 12 - Verifica della share dai client (SOLA LETTURA, salvo un file di prova creato e cancellato)
# fss-prod-01/02/03 e openarchive-prod-01: spazio di /shared e scrittura come fews-user.
# Linux: df -h /shared, sudo -u fews-user touch /shared/.test-share
# Da lanciare da /root/fews-ansible (ansible.cfg, inventory.yml, disks.yml, site.yml)
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")" || exit 2
[[ -f ansible.cfg && -f inventory.yml && -f disks.yml ]] || { echo "Mancano ansible.cfg/inventory.yml/disks.yml nella cartella: copiare qui disks.yml"; exit 2; }
LOG="log-$(basename "$0" .sh)-$(date +%F_%H%M).log"
ansible-playbook disks.yml --tags share-verify -e "share_clients='fews_fss:*openarchive*'" 2>&1 | tee "$LOG"
echo; echo "Atteso: /shared ~800G e SCRITTURA_OK su tutte e 4. Prossimo: task13.sh"
