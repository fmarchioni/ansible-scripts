#!/bin/bash
# =============================================================================
# Ricrea /data VUOTO su una VM a cui e' stato tolto in vCD un disco del volume
# vg_data PRIMA che /data fosse ricreato (es. fss: da 3 a 2 dischi).
# Da lanciare dal nodo Ansible, solo DOPO che la VM e' tornata raggiungibile:
#   ansible fews_fss -m script -a fss-recover.sh
#
# Cosa fa (DISTRUTTIVO su /data, gia' concordato):
#   - toglie dal volume group il disco mancante e il vecchio volume rotto
#   - ricrea /data (XFS) sui dischi rimasti
#   - riattiva /data in /etc/fstab (aggiornando l'UUID se usato), monta
#   - lascia il marcatore /etc/fews-data-shrunk (cosi' task9 salta la VM)
# Se /data e' gia' montato e sano, non fa nulla.
# =============================================================================
set -euo pipefail
MNT=/data; VG=vg_data; LV=lv_data; MARK=/etc/fews-data-shrunk

if findmnt -n "$MNT" >/dev/null 2>&1 && [ -f "$MARK" ]; then
  echo "SKIP: $MNT gia' montato e ricreato in precedenza"; df -h "$MNT" | tail -1; exit 0
fi
if findmnt -n "$MNT" >/dev/null 2>&1 && ! pvs 2>&1 | grep -qi missing; then
  echo "STOP: $MNT e' montato e nessun disco risulta mancante: questa VM non ha bisogno del recupero"; exit 1
fi

cp -a /etc/fstab "/etc/fstab.bak-recover-$(date +%F_%H%M)"
umount "$MNT" 2>/dev/null || true

echo ">> rimuovo dal volume group il disco mancante e il volume rotto"
vgreduce --removemissing --force "$VG"
lvremove -y "$VG/$LV" 2>/dev/null || true

echo ">> ricreo $MNT sui dischi rimasti: $(pvs --noheadings -o pv_name -S vg_name=$VG | xargs)"
lvcreate -y -l 100%FREE -n "$LV" "$VG"
mkfs.xfs -f -K "/dev/$VG/$LV" >/dev/null

echo ">> fstab"
sed -i "s|^#\(.*[[:space:]]$MNT[[:space:]]\)|\1|" /etc/fstab        # riattiva la riga commentata
dev=$(awk -v m="$MNT" '$1 !~ /^#/ && $2 == m {print $1}' /etc/fstab)
[ -n "$dev" ] || { echo "STOP: nessuna riga $MNT in /etc/fstab"; exit 1; }
case "$dev" in
  UUID=*) new=$(blkid -s UUID -o value "/dev/$VG/$LV")
          sed -i "s|^$dev\([[:space:]]\+$MNT[[:space:]]\)|UUID=$new\1|" /etc/fstab ;;
esac
grep -E "[[:space:]]$MNT[[:space:]]" /etc/fstab

systemctl daemon-reload
mount "$MNT"
restorecon -R "$MNT" 2>/dev/null || true
echo "$(date '+%F %T') /data ricreato dopo rimozione disco (recupero)" > "$MARK"

echo ">> risultato"
df -h "$MNT" | tail -1
pvs --noheadings -o pv_name,vg_name,pv_size -S vg_name="$VG"
findmnt -n /shared >/dev/null && echo "/shared montato" || echo "ATTENZIONE: /shared non montato (mount /shared)"
