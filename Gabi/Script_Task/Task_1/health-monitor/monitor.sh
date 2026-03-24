#!/usr/bin/env bash
#
# monitor.sh - System Health Monitor 
#
# - Logs CPU, memory, disk usage
# - Checks monitored services
# - Logs alerts when thresholds exceed limits

set -euo pipefail

############################
# Configuration
############################

LOG_DIR="${LOG_DIR:-$(pwd)/logs}"
LOG_FILE="$LOG_DIR/health-monitor.log"

ALERT_CPU="${ALERT_CPU:-80}"
ALERT_MEM="${ALERT_MEM:-85}"
ALERT_DISK="${ALERT_DISK:-90}"

SERVICES=("nginx" "docker" "sshd")

############################
# Logging helper
############################

log_msg() {
  local level="$1"
  shift
  local msg="$*"
  local ts
  ts=$(date "+%Y-%m-%d %H:%M:%S")
  mkdir -p "$LOG_DIR"
  echo "$ts [$level] $msg" | tee -a "$LOG_FILE"
}

############################
# Metric collection
############################

get_cpu_usage() {
  # Read first sample
  read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
  local prev_idle=$((idle + iowait))
  local prev_non_idle=$((user + nice + system + irq + softirq + steal))
  local prev_total=$((prev_idle + prev_non_idle))

  sleep 1

  # Read second sample
  read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
  local idle2=$((idle + iowait))
  local non_idle2=$((user + nice + system + irq + softirq + steal))
  local total2=$((idle2 + non_idle2))

  local totald=$((total2 - prev_total))
  local idled=$((idle2 - prev_idle))

  if [[ "$totald" -eq 0 ]]; then
    echo "0"
    return
  fi

  # CPU usage = (totald - idled) / totald * 100
  awk -v totald="$totald" -v idled="$idled" \
    'BEGIN { printf "%.2f", (totald - idled) / totald * 100 }'
}

get_mem_usage() {
  free | awk '/Mem:/ { printf "%.2f", $3/$2 * 100 }'
}

check_disk_usage() {
  # Exclude tmpfs/devtmpfs
  df -P -x tmpfs -x devtmpfs | awk 'NR>1 {gsub(/%/,"",$5); printf "%s %s %s\n", $5, $6, $1}'
}

check_service_running() {
  local svc="$1"
  if systemctl is-active --quiet "$svc"; then
    return 0
  else
    return 1
  fi
}

############################
# Main logic
############################

main() {
  local cpu mem
  cpu=$(get_cpu_usage)
  mem=$(get_mem_usage)

  log_msg INFO "CPU usage: ${cpu}%"
  log_msg INFO "Memory usage: ${mem}%"

  # CPU alert
  if awk -v v="$cpu" -v t="$ALERT_CPU" 'BEGIN { exit !(v > t) }'; then
    log_msg ALERT "High CPU! ${cpu}% > threshold ${ALERT_CPU}%"
  fi

  # Memory alert
  if awk -v v="$mem" -v t="$ALERT_MEM" 'BEGIN { exit !(v > t) }'; then
    log_msg ALERT "High Memory! ${mem}% > threshold ${ALERT_MEM}%"
  fi

  # Disk checks
  while read -r usage mount fs; do
    log_msg INFO "Disk: ${fs} mounted on ${mount} at ${usage}%"

    if (( usage > ALERT_DISK )); then
      log_msg ALERT "High Disk usage on $fs ($mount): ${usage}% > ${ALERT_DISK}%"
    fi
  done < <(check_disk_usage)

  # Service checks
  for svc in "${SERVICES[@]}"; do
    if check_service_running "$svc"; then
      log_msg INFO "Service '$svc' is running"
    else
      log_msg ALERT "Service '$svc' is DOWN"
    fi
  done
}

main
