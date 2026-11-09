#!/bin/bash
# =============================================================================
# TASK 13 - Aggiorna l'inventario: dischi dati di fss (2) e openarchive (1)
# Modifica solo il file locale inventory.yml (copia di sicurezza prima). Nessun intervento sulle VM.
# Poi rilanciare task8.sh (collaudo finale).
# Da lanciare da /root/fews-ansible (ansible.cfg, inventory.yml, disks.yml, site.yml)
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")" || exit 2
[[ -f ansible.cfg && -f inventory.yml && -f disks.yml ]] || { echo "Mancano ansible.cfg/inventory.yml/disks.yml nella cartella: copiare qui disks.yml"; exit 2; }
LOG="log-$(basename "$0" .sh)-$(date +%F_%H%M).log"
cp inventory.yml "inventory.yml.bak-$(date +%F_%H%M)"
awk '
  /^        [^ ]*-fss-prod-0[123]:/        { h="fss"; print; next }
  /^        [^ ]*-openarchive-prod-01:/    { h="oa";  print; next }
  /^        [^ ]/                          { h="" }
  h=="fss" && /^ +fews_data_disks:/ { sub(/fews_data_disks:.*/, "fews_data_disks: [sdb, sdc]") }
  h=="oa"  && /^ +fews_data_disks:/ { sub(/fews_data_disks:.*/, "fews_data_disks: [sdb]") }
  { print }
' inventory.yml > inventory.yml.new && mv inventory.yml.new inventory.yml
echo "--- Modifiche:"; diff "$(ls -t inventory.yml.bak-* | head -1)" inventory.yml
ansible 'fews_fss:*openarchive*' -m debug -a 'msg="dischi={{ fews_data_disks }}"' | grep msg
echo; echo "Atteso: fss dischi=[sdb, sdc], openarchive dischi=[sdb]. Prossimo: task8.sh (collaudo finale)"
