#!/bin/bash
# =============================================================================
# TASK 8 - Aggiorna l'inventario: adminint e dbproxy senza disco dati
# Per le 4 VM imposta fews_data_disks: [] e fews_mount: "" (cosi' site.yml non ricrea ne' verifica /data).
# Modifica solo il file locale inventory.yml (copia di sicurezza prima). Nessun intervento sulle VM.
# Da lanciare da /root/fews-ansible (ansible.cfg, inventory.yml, disks.yml, site.yml)
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")" || exit 2
[[ -f ansible.cfg && -f inventory.yml && -f disks.yml ]] || { echo "Mancano ansible.cfg/inventory.yml/disks.yml nella cartella: copiare qui disks.yml"; exit 2; }
LOG="log-$(basename "$0" .sh)-$(date +%F_%H%M).log"
cp inventory.yml "inventory.yml.bak-$(date +%F_%H%M)"
awk '
  /^        [^ ]*-(adminint|dbproxy)-prod-0[12]:/ { inhost=1; print; next }
  /^        [^ ]/ { inhost=0 }
  inhost && /^ +fews_data_disks:/ { sub(/fews_data_disks:.*/, "fews_data_disks: []") }
  inhost && /^ +fews_mount:/      { sub(/fews_mount:.*/, "fews_mount: \"\"") }
  { print }
' inventory.yml > inventory.yml.new && mv inventory.yml.new inventory.yml
echo "--- Modifiche:"; diff "$(ls -t inventory.yml.bak-* | head -1)" inventory.yml
ansible '*adminint*:*dbproxy*' -m debug -a 'msg="dischi={{ fews_data_disks }} mount={{ fews_mount }}"' | grep msg
echo; echo "Atteso: 8 righe cambiate (2 per VM). Prossimo: task9.sh"
