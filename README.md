# Scripts

## Bash

### backups
The `backups.sh` script is for make and compress files or folders and copy them to other folder (preferably a folder mount in external drive/usb).

For use it properly, follow the next steps:
1. Set `TMPDIR` variable to a directory with enough space for temporal compress files.
2. If you use the `-f` parameter for read paths to backup, leave a blank line at the end. If not, the last specified path won't be backup. (TO FIX)
3. If your destination folder for backups isn't a mount external drive/usb, you must comment the function `__check_mount` in main flow. (TO FIX)

Examples of use in crontab:
```
# Daily backups (everyday at 00:05, copy backup files to /some/directory/daily-backups, delete older files than 5 days and redirect output to specific log file)
05 00 * * * bash /opt/scripts/bash/backups.sh -f /some/directory/daily-backups -r 5 -t /mnt/external/daily-backups >> /var/log/daily-backups.log 2>&1

# Weekly backups (every sunday at 00:10, copy backup files to /some/directory/weekly-backups, delete older files than 20 days and redirect output to specific log file)
10 00 * * 7 bash /opt/scripts/bash/backups.sh -f /some/directory/weekly-backups -r 20 -t /mnt/external/weekly-backups >> /var/log/weekly-backups.log 2>&1

# Monthly backups (every 3th at 00:15, copy backup files to /some/directory/monthly-backups, delete older files than 90 days and redirect output to specific log file)
15 00 * 3 * bash /opt/scripts/bash/backups.sh -f /some/directory/monthly-backups -r 90 -t /mnt/external/monthly-backups >> /var/log/monthly-backups.log 2>&1
```

>**IMPORTANT**
>Each destination folder must have only backups files to prevent unexpected file deletion

Suggestions are always welcome :)