#!/bin/bash
LOG_DIR="var/logs/health-monitor"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/health-monitor.log"

METRIC_CPU=$(top -b -n1 | grep "Cpu(s)" | awk '{printf "%.0f", $2 + $4}')
METRIC_MEM=$(free -m | awk '/^Mem:/ { printf "%.0f", $3/$2 * 100 }')
METRIC_DISK=$(df -h | awk '$NF=="/"{gsub(/%/,"",$5); print $5}')

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "RAM Usage: $METRIC_MEM%"
echo "CPU usage: $METRIC_CPU%"
echo "Disk Usage: $METRIC_DISK%"

if [ "$METRIC_CPU" -gt 80 ]; then
    echo "ALERT: High CPU usage: $METRIC_CPU%"
fi

if [ "$METRIC_MEM" -gt 85 ]; then
    echo "ALERT: High Memory usage: $METRIC_MEM%"
fi

if [ "$METRIC_DISK" -gt 90 ]; then
    echo "ALERT: High Disk usage: $METRIC_DISK%"
fi

echo "[$TIMESTAMP] CPU: $METRIC_CPU% RAM: $METRIC_MEM% DISK: $METRIC_DISK%" >> "$LOG_FILE"

NGINX_STATUS=$(service nginx status)
if ! echo "$NGINX_STATUS" | grep -q "is running"; then
    echo "[$TIMESTAMP] Nginx is DOWN. Starting nginx..." >> "$LOG_FILE"
    service nginx start > /dev/null 2>&1
else
    echo "[$TIMESTAMP] Nginx: running" >> "$LOG_FILE"
fi

SSHD_STATUS=$(service ssh status)
if ! echo "$SSHD_STATUS" | grep -q "is running"; then
    echo "[$TIMESTAMP] SSH is DOWN. Starting ssh..." >> "$LOG_FILE"
    service ssh start > /dev/null 2>&1
else
    echo "[$TIMESTAMP] SSH: running" >> "$LOG_FILE"
fi

SQL_STATUS=$(service mysql status)
if ! echo "$SQL_STATUS" | grep -qE "is running|Uptime"; then
    echo "[$TIMESTAMP] MySQL is DOWN. Starting mysql..." >> "$LOG_FILE"
    service mysql start > /dev/null 2>&1
else
    echo "[$TIMESTAMP] MySQL: running" >> "$LOG_FILE"
fi
