#!/bin/bash

TIMESTAMP=$(date "+%Y-%m-%d")

LOG_FILE="/home/var/logs/health-monitor/health-monitor.log"
echo "--- Health Summary for $TIMESTAMP ---" > daily-summary.txt

cat "$LOG_FILE" | grep $(date -d "-1 days" +"%Y-%m-%d") >> daily-summary.txt

git add daily-summary.txt
git commit -m "Health logs - $TIMESTAMP"