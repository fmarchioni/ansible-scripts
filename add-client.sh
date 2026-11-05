#!/bin/bash
# =============================================================================
# Aggiunge una VM client alla share NFS esistente (export /data -> mount /shared)
#
# Da lanciare sul nodo Ansible, dalla cartella del kit (inventario + vault):
#   cd ~/fews-ansible
#   bash ~/ansible-scripts/nfs-add-client.sh check <pattern-client> <ip-client> <ip-server-nfs>
#   bash ~/ansible-scripts/nfs-add-client.sh apply <pattern-client> <ip-client> <ip-server-nfs>
#
# Esempio:
#   bash ~/ansible-scripts/nfs-add-client.sh check '*openarchive*' <ip-client> <ip-server>
#
# check = solo verifiche, nessuna modifica (default consigliato prima di apply)
# apply = verifiche + modifiche + verifica finale
#
# Il server NFS e' il gruppo inventario "fews_nfs" (Ubuntu, utente non root: sudo).
# Se le sue password non sono nel vault, impostare NFS_AUTH="-k -K" (default).
# =============================================================================
set -uo pipefail

MODE="${1:-}"; CLIENT="${2:-}"; CLIENT_IP="${3:-}"; SERVER_IP="${4:-}"
EXPORT_DIR="/data"; MOUNTPOINT="/shared"
EXPORT_OPTS="rw,sync,no_subtree_check,root_squash"     # uguali ai client esistenti
MOUNT_OPTS="defaults,_netdev"
TEST_USER="${TEST_USER:-fews-user}"
NFS_AUTH="${NFS_AUTH:--k -K}"

if [[ ! "$MODE" =~ ^(check|apply)$ || -z "$CLIENT" || -z "$CLIENT_IP" || -z "$SERVER_IP" ]]; then
  sed -n '2,19p' "$0"; exit 2
fi
[[ -f ansible.cfg && -f inventory.yml ]] || { echo "Lanciare dalla cartella del kit (cd ~/fews-ansible)"; exit 2; }

step() { echo; echo "=================================================================="; echo " $*"; echo "=================================================================="; }
SRV() { ansible fews_nfs $NFS_AUTH -b -m shell -a "$1"; }
CLI() { ansible "$CLIENT" -m shell -a "$1"; }

# -----------------------------------------------------------------------------
# CHECK (sola lettura)
# -----------------------------------------------------------------------------
step "CHECK 1 - VM client selezionata dal pattern '$CLIENT'"
ansible "$CLIENT" --list-hosts || exit 2

step "CHECK 2 - client: nfs-utils, $MOUNTPOINT, mount attuale"
CLI "rpm -q nfs-utils; ls -ld $MOUNTPOINT 2>&1; findmnt $MOUNTPOINT || echo 'NON MONTATO'; grep -E '\s$MOUNTPOINT\s' /etc/fstab || echo 'NESSUNA RIGA FSTAB'"

step "CHECK 3 - client: raggiungibilita' del server NFS ($SERVER_IP:2049)"
CLI "timeout 3 bash -c '</dev/tcp/$SERVER_IP/2049' && echo NFS_RAGGIUNGIBILE || echo NFS_NON_RAGGIUNGIBILE"

step "CHECK 4 - server NFS: export attuale"
SRV "cat /etc/exports; echo '--- exportfs -v'; exportfs -v"

[[ "$MODE" == "check" ]] && { echo; echo "Solo verifica completata. Per applicare: stesso comando con 'apply'."; exit 0; }

# -----------------------------------------------------------------------------
# APPLY (modifiche)
# -----------------------------------------------------------------------------
read -r -p $'\nProcedo con le modifiche (server NFS + client)? [s/N] ' ans
[[ "$ans" =~ ^[sS]$ ]] || { echo "Annullato: nessuna modifica."; exit 0; }

step "FIX 1 - server NFS: aggiunge $CLIENT_IP all'export $EXPORT_DIR (backup di /etc/exports)"
SRV "cp -n /etc/exports /etc/exports.bak-\$(date +%F); \
grep -q '${CLIENT_IP}(' /etc/exports && echo 'CLIENT GIA PRESENTE NELL EXPORT' || \
sed -i '\\#^${EXPORT_DIR}[[:space:]]# s/\$/ ${CLIENT_IP}(${EXPORT_OPTS})/' /etc/exports; \
exportfs -ra && exportfs -v | grep -A1 '^${EXPORT_DIR}'" || { echo "Errore sul server NFS: interrotto"; exit 1; }

step "FIX 2 - client: installa nfs-utils"
ansible "$CLIENT" -m dnf -a "name=nfs-utils state=present" || { echo "Errore installazione nfs-utils: interrotto"; exit 1; }

step "FIX 3 - client: crea $MOUNTPOINT, riga fstab, mount"
CLI "mkdir -p $MOUNTPOINT; \
grep -qE '\s$MOUNTPOINT\s' /etc/fstab || echo '$SERVER_IP:$EXPORT_DIR $MOUNTPOINT nfs $MOUNT_OPTS 0 0' >> /etc/fstab; \
systemctl daemon-reload; findmnt $MOUNTPOINT >/dev/null || mount $MOUNTPOINT; findmnt $MOUNTPOINT" || { echo "Errore nel mount: interrotto"; exit 1; }

# -----------------------------------------------------------------------------
# VERIFICA FINALE
# -----------------------------------------------------------------------------
step "VERIFICA - mount, spazio, scrittura come $TEST_USER"
CLI "findmnt $MOUNTPOINT; df -h $MOUNTPOINT | tail -1; \
sudo -u $TEST_USER touch $MOUNTPOINT/.test-nfs && echo SCRITTURA_OK && rm -f $MOUNTPOINT/.test-nfs"

echo; echo "Fatto. Atteso: $SERVER_IP:$EXPORT_DIR su $MOUNTPOINT e SCRITTURA_OK."
