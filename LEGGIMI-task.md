# Dischi FEWS: /opt +10 GB e rimozione /data - sequenza script

Copiare in /root/fews-ansible: task1.sh ... task9.sh, disks.yml e site.yml (versione aggiornata).
Lanciare da lì, uno alla volta, nell'ordine. Ogni script salva l'output in log-taskN-<data>.log.
Gli script che MODIFICANO le VM chiedono conferma [s/N].

| Ordine | Chi | Cosa | Modifica? |
|---|---|---|---|
| task1.sh | Francesco | fotografia iniziale dei dischi | no |
| task2.sh | Francesco | installa growpart/gdisk sulle 12 VM | solo pacchetti |
| vCD | Gianluca | disco di sistema 50 -> 60 GB su adminint-prod-01 | |
| task3.sh | Francesco | /opt +10 GB su adminint-prod-01 (prova) | si', a caldo |
| vCD | Gianluca | disco di sistema 50 -> 60 GB sulle altre 11 VM | |
| task4.sh | Francesco | /opt +10 GB sulle 12 VM | si', a caldo |
| task5.sh | Francesco | prepara rimozione /data su adminint-prod-01 (prova) | si' |
| task6.sh | Francesco | prepara rimozione /data su adminint-02, dbproxy-01/02 | si' |
| vCD | Gianluca | rimuove i dischi /data indicati (60 GB) | |
| task7.sh | Francesco | verifica dopo la rimozione | no |
| task8.sh | Francesco | aggiorna inventory.yml (4 VM senza /data) | solo file locale |
| task9.sh | Francesco | collaudo finale | no |
