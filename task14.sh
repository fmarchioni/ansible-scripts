#!/bin/bash
# =============================================================================
# TASK 14 - Controllo finale per la CONSEGNA (SOLA LETTURA, output minimo)
# Da lanciare da /root/fews-ansible (servono delivery.yml e delivery-check.sh nella cartella).
# Su tutte le VM (RHEL + NFS): rete, servizi, fstab, NTP, VMware Tools, spazio (/opt, /data,
# /shared), fews-user, Nagios, registrazione Red Hat, NFS server, PostgreSQL, identita' uniche.
# Chiede le password di ldo (VM NFS Ubuntu): SSH e sudo.
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")" || exit 2
[[ -f delivery.yml && -f delivery-check.sh && -f inventory.yml ]] || { echo "Mancano delivery.yml/delivery-check.sh: copiarli qui"; exit 2; }
rm -f esito-consegna.txt
ANSIBLE_DISPLAY_OK_HOSTS=false ANSIBLE_DISPLAY_SKIPPED_HOSTS=false \
  ansible-playbook delivery.yml -l 'all:!lab' -k -K | grep -E 'fatal|UNREACHABLE|ERROR' 
echo
echo "=================================================================="
cat esito-consegna.txt 2>/dev/null || echo "Esito non prodotto: controllare gli errori sopra"
echo "=================================================================="
cp esito-consegna.txt "esito-consegna-$(date +%F_%H%M).txt" 2>/dev/null
