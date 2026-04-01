#!/bin/bash

TIMESTAMP=$(date "+%Y-%m-%d")

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOG_FILE="$PROJECT_ROOT/logs/backup.log"

echo "--- Backup Summary for $TIMESTAMP ---" > daily-backup-summary.txt

grep $(date -d "-1 days" +"%Y-%m-%d") "$LOG_FILE" >> daily-backup-summary.txt

git add daily-backup-summary.txt
git commit -m "Backup logs - $TIMESTAMP"