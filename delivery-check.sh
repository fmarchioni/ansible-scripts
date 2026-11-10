#!/bin/bash
# =============================================================================
# Controlli di consegna eseguiti SU OGNI VM (lanciato da delivery.yml, sola lettura).
# Stampa solo righe "KO ..." (bloccanti), "WARN ..." (da segnalare) e "ID ..." (per i
# controlli incrociati). Esce sempre con 0: l'esito lo decide delivery.yml.
# Parametri chiave=valore: host= ip= dns= opt_min= data= shared= pg= nfssrv=
# =============================================================================
HOST=""; IP=""; DNS=""; OPT_MIN=0; DATA=none; SHARED=no; PG=no; NFSSRV=no
for a in "$@"; do
  case "$a" in
    host=*) HOST=${a#*=} ;; ip=*) IP=${a#*=} ;; dns=*) DNS=${a#*=} ;; opt_min=*) OPT_MIN=${a#*=} ;;
    data=*) DATA=${a#*=} ;; shared=*) SHARED=${a#*=} ;; pg=*) PG=${a#*=} ;; nfssrv=*) NFSSRV=${a#*=} ;;
  esac
done
ko()   { echo "KO   $*"; }
warn() { echo "WARN $*"; }
gb()   { df -BG --output=size "$1" 2>/dev/null | tail -1 | tr -dc '0-9'; }
pct()  { df --output=pcent "$1" 2>/dev/null | tail -1 | tr -dc '0-9'; }

# --- identita' e rete --------------------------------------------------------
[ -z "$HOST" ] || [ "$(hostname -s)" = "$HOST" ] || ko "hostname $(hostname -s) (atteso $HOST)"
[ -z "$IP" ] || ip -4 -o addr show | grep -q " $IP/" || ko "IP $IP non configurato"
[ -z "$DNS" ] || timeout 3 bash -c "</dev/tcp/$DNS/53" 2>/dev/null || ko "DNS $DNS non raggiungibile"

# --- sistema -----------------------------------------------------------------
f=$(systemctl list-units --state=failed --plain --no-legend 2>/dev/null | awk '{print $1}' | xargs)
[ -z "$f" ] || ko "servizi in errore: $f"
findmnt --verify >/dev/null 2>&1 || ko "/etc/fstab con errori (findmnt --verify)"
[ "$(timedatectl show -p Timezone --value 2>/dev/null)" = "Europe/Rome" ] || ko "fuso orario $(timedatectl show -p Timezone --value)"
[ "$(timedatectl show -p NTPSynchronized --value 2>/dev/null)" = "yes" ] || ko "ora non sincronizzata (NTP)"
systemctl is-active -q vmtoolsd 2>/dev/null || systemctl is-active -q open-vm-tools 2>/dev/null || ko "open-vm-tools non attivo"

# --- spazio ------------------------------------------------------------------
for m in / /var /opt /home; do
  u=$(pct "$m"); [ "${u:-0}" -lt 85 ] || warn "$m occupato al ${u}%"
done
if [ "$OPT_MIN" -gt 0 ]; then
  s=$(gb /opt); [ "${s:-0}" -ge "$OPT_MIN" ] || ko "/opt ${s}G (atteso almeno ${OPT_MIN}G)"
fi
if [ "$DATA" != "none" ]; then
  findmnt -n "$DATA" >/dev/null 2>&1 || ko "$DATA non montato"
else
  findmnt -n /data >/dev/null 2>&1 && ko "/data montato ma non previsto su questa VM"
fi

# --- utenza ------------------------------------------------------------------
if id fews-user >/dev/null 2>&1; then
  [ "$(id -u fews-user)" = "1001" ] || ko "fews-user con UID $(id -u fews-user) (atteso 1001)"
  id -nG fews-user | grep -qwE 'wheel|sudo' || warn "fews-user senza sudo"
else
  ko "utente fews-user assente"
fi

# --- specifici RHEL / Ubuntu -------------------------------------------------
if [ -f /etc/redhat-release ]; then
  rpm -q perl-Nagios-Plugin >/dev/null 2>&1 || ko "perl-Nagios-Plugin non installato"
  [ -f /etc/pki/consumer/cert.pem ] || ko "non registrata a Red Hat"
  if command -v needs-restarting >/dev/null 2>&1; then
    needs-restarting -r >/dev/null 2>&1 || warn "riavvio consigliato (aggiornamenti installati)"
  fi
fi
[ -f /var/run/reboot-required ] && warn "riavvio richiesto (kernel aggiornato)"

# --- disco condiviso (client) ------------------------------------------------
if [ "$SHARED" = "yes" ]; then
  if findmnt -n /shared >/dev/null 2>&1; then
    s=$(gb /shared); [ "${s:-0}" -ge 780 ] || ko "/shared ${s}G (attesi ~800G)"
    t="/shared/.consegna-$$"
    if sudo -u fews-user touch "$t" 2>/dev/null; then rm -f "$t"; else ko "/shared non scrivibile da fews-user"; fi
  else
    ko "/shared non montato"
  fi
fi

# --- server NFS --------------------------------------------------------------
if [ "$NFSSRV" = "yes" ]; then
  systemctl is-active -q nfs-server || ko "servizio nfs-server non attivo"
  s=$(gb /data); [ "${s:-0}" -ge 780 ] || ko "share /data ${s}G (attesi ~800G)"
  c=$(exportfs -v 2>/dev/null | grep -c '^/data'); [ "$c" -ge 4 ] || ko "export /data verso $c client (attesi 4)"
fi

# --- PostgreSQL --------------------------------------------------------------
if [ "$PG" = "yes" ]; then
  systemctl is-active -q postgresql || ko "postgresql non attivo"
  v=$(runuser -u postgres -- psql -XAtc 'show server_version' 2>/dev/null)
  case "$v" in 15.*) ;; *) ko "PostgreSQL versione '${v:-?}' (attesa 15.x)" ;; esac
  [ "$(runuser -u postgres -- psql -XAtc "select count(*) from pg_roles where rolname='dba_admin'" 2>/dev/null)" = "1" ] || ko "ruolo dba_admin assente"
fi

# --- dati per i controlli incrociati -----------------------------------------
echo "ID   $(cat /etc/machine-id 2>/dev/null) $(ssh-keygen -lf /etc/ssh/ssh_host_ecdsa_key.pub 2>/dev/null | awk '{print $2}')"
exit 0
