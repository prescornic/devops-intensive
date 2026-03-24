#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-./backups}"
mkdir -p "$BACKUP_DIR"

usage() {
  cat <<EOF
Usage:
  sudo ./backup-restore.sh --backup
  sudo ./backup-restore.sh --restore <backup_file.rules>

Examples:
  sudo ./backup-restore.sh --backup
  sudo ./backup-restore.sh --restore ./backups/firewall-20251217-120000.rules
EOF
}

if [[ "${1:-}" == "--backup" ]]; then
  ts="$(date -u +%Y%m%d-%H%M%S)"
  out="$BACKUP_DIR/firewall-$ts.rules"
  iptables-save > "$out"
  echo "Backup saved: $out"
  exit 0
fi

if [[ "${1:-}" == "--restore" && -n "${2:-}" ]]; then
  f="$2"
  [[ -f "$f" ]] || { echo "Backup file not found: $f"; exit 1; }
  iptables-restore < "$f"
  echo "Restored firewall rules from: $f"
  exit 0
fi

usage
exit 1
