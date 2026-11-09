#!/bin/bash
# =============================================================================
# TASK 11 - Estensione della share NFS da 200 a 800 GB (server nfs-prod-01, a caldo, non distruttivo)
# PRIMA DI LANCIARE: Gianluca ha AGGIUNTO 4 dischi da 150 GB alla VM nfs-prod-01.
# Rileva i dischi nuovi (si ferma se non sono esattamente 4), li aggiunge al volume della share
# e allarga il filesystem senza smontare: i client continuano a lavorare.
# Linux: scansione SCSI, pvcreate, vgextend vg_data, lvextend -r -l +100%FREE /dev/vg_data/lv_data
# VM Ubuntu con utente ldo: chiede le password SSH e sudo (NFS_AUTH='' se sono nel vault).
# Da lanciare da /root/fews-ansible (ansible.cfg, inventory.yml, disks.yml, site.yml)
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")" || exit 2
[[ -f ansible.cfg && -f inventory.yml && -f disks.yml ]] || { echo "Mancano ansible.cfg/inventory.yml/disks.yml nella cartella: copiare qui disks.yml"; exit 2; }
LOG="log-$(basename "$0" .sh)-$(date +%F_%H%M).log"
read -r -p "Questo passo MODIFICA le VM. Procedo? [s/N] " a; [[ "$a" =~ ^[sS]$ ]] || { echo "Annullato."; exit 0; }
NFS_AUTH="${NFS_AUTH:--k -K}"
ansible-playbook disks.yml --tags share-extend $NFS_AUTH 2>&1 | tee "$LOG"
echo; echo "Atteso: Dopo: ... 800G /data, client nell export invariati. Prossimo: task12.sh"
