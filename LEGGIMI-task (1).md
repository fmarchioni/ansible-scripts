# Dischi FEWS - sequenza script

Copiare in /root/fews-ansible: task1.sh ... task13.sh, disks.yml e site.yml (versione aggiornata).
Lanciare da li', uno alla volta, nell'ordine. Ogni script salva l'output in log-taskN-<data>.log.
Gli script che MODIFICANO le VM chiedono conferma [s/N] (task9: bisogna scrivere CANCELLA).
Prima di lanciare uno script: `cat taskN.sh` e controllare il comando.

## Punto 1 - /opt +10 GB (12 VM, a caldo)

| Script | Attendere prima di lanciarlo | Cosa fa | Modifica? |
|---|---|---|---|
| task1.sh | - | fotografia iniziale dei dischi | no |
| task2.sh | - | installa growpart/gdisk sulle 12 VM | solo pacchetti |
| **Gianluca** | task2 OK | disco di sistema 50 -> 60 GB sulle 12 VM | |
| task3.sh | "fatto" di Gianluca (dischi di sistema a 60 GB) | /opt +10 GB sulle 12 VM | si', a caldo |

## Punto 2 - rimozione /data su adminint e dbproxy (4 VM)

| Script | Attendere prima di lanciarlo | Cosa fa | Modifica? |
|---|---|---|---|
| task4.sh | - (si puo' lanciare anche mentre Gianluca lavora sul punto 1) | prepara rimozione /data su adminint-prod-01 | si' |
| task5.sh | task4 OK | prepara rimozione /data sulle altre 3 VM, elenca i dischi | si' |
| **Gianluca** | lista dischi da task4/task5 | rimuove i 4 dischi /data (60 GB) | |
| task6.sh | "fatto" di Gianluca (dischi /data rimossi) | verifica | no |
| task7.sh | task6 OK | inventory.yml: 4 VM senza /data | solo file locale |

## Punto 3 - disco condiviso 200 -> 800 GB (fss, openarchive, nfs)

| Script | Attendere prima di lanciarlo | Cosa fa | Modifica? |
|---|---|---|---|
| task9.sh | conferma DXC: servizi FEWS fermi e backup Open Archive fatto (ricevuta) | ricrea /data su fss (450->300) e openarchive (300->150), elenca i dischi da rimuovere | si', DISTRUTTIVO su /data |
| **Gianluca** | lista dischi da task9 | rimuove i 4 dischi da 150 GB da fss/openarchive e AGGIUNGE 4 dischi da 150 GB a nfs-prod-01 | |
| task10.sh | "fatto" di Gianluca (dischi rimossi) | verifica fss e openarchive | no |
| task11.sh | "fatto" di Gianluca (4 dischi aggiunti a nfs-prod-01) | estende la share a 800 GB, a caldo | si', non distruttivo |
| task12.sh | task11 OK | verifica /shared da fss e openarchive (800 GB + scrittura) | no |
| task13.sh | task12 OK | inventory.yml: fss 2 dischi, openarchive 1 | solo file locale |

## Fine

| Script | Attendere prima di lanciarlo | Cosa fa | Modifica? |
|---|---|---|---|
| task8.sh | tutti i punti completati | collaudo finale | no |

Per risparmiare tempo: le operazioni vCD di Gianluca dei punti 2 e 3 si possono fare nella stessa
sessione, appena task5 e task9 hanno stampato i dischi da rimuovere.

## Consegna

| Script | Attendere prima di lanciarlo | Cosa fa | Modifica? |
|---|---|---|---|
| task14.sh | tutto completato | controllo finale di consegna: stampa solo i problemi e "AMBIENTE PRONTO PER LA CONSEGNA" | no |

Servono in /root/fews-ansible anche delivery.yml e delivery-check.sh.
