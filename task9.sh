#!/bin/bash
# =============================================================================
# TASK 9 - Riduzione DISTRUTTIVA di /data su fss-prod-01/02/03 e openarchive-prod-01
# PRIMA DI LANCIARE: DXC ha fermato i servizi FEWS e salvato i dati di Open Archive (confermato via mail).
# Per ogni VM (una alla volta, stop al primo errore): smonta /data, elimina il volume, toglie dal
# volume group l'ULTIMO disco (fss: 3->2 dischi = 300 GB; openarchive: 2->1 = 150 GB), ricrea /data
# VUOTO (XFS), aggiorna fstab se usa UUID (backup), rimonta, stacca il disco tolto da Linux.
# Stampa per ogni VM il disco da rimuovere in vCD.
# Linux: umount /data, lvremove, vgreduce, pvremove, lvcreate, mkfs.xfs -K, mount /data
# /shared (NFS) NON viene toccato.
# Da lanciare da /root/fews-ansible (ansible.cfg, inventory.yml, disks.yml, site.yml)
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")" || exit 2
[[ -f ansible.cfg && -f inventory.yml && -f disks.yml ]] || { echo "Mancano ansible.cfg/inventory.yml/disks.yml nella cartella: copiare qui disks.yml"; exit 2; }
LOG="log-$(basename "$0" .sh)-$(date +%F_%H%M).log"
read -r -p "Il contenuto di /data su fss e openarchive verra CANCELLATO. Scrivi CANCELLA per procedere: " a; [[ "$a" == "CANCELLA" ]] || { echo "Annullato."; exit 0; }
ansible-playbook disks.yml --tags data-shrink -e "shrink_hosts='fews_fss:*openarchive*'" 2>&1 | tee "$LOG"
echo; echo '--- Dischi da comunicare a Gianluca:'; grep -o 'DA RIMUOVERE IN vCD: [^|]*' "$LOG"
echo; echo "Prossimo: Gianluca rimuove i 4 dischi indicati (150 GB) e AGGIUNGE 4 dischi da 150 GB alla VM nfs-prod-01, poi task10.sh"
