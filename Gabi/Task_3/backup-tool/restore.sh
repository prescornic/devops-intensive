#!/usr/bin/env bash
set -euo pipefail

# restore.sh <backup.tar.gz> <restore_destination_dir>
# Example:
#   ./restore.sh /backup/local/backup-2025-12-10-143022.tar.gz /restore/location

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_FILE="${CONF_FILE:-$SCRIPT_DIR/backup.conf}"

# Load config for log dir (optional)
if [[ -f "$CONF_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONF_FILE"
fi

LOG_DIR="${LOG_DIR:-$SCRIPT_DIR/logs}"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/restore-$(date +%F).log"

log() {
  local level="$1"; shift
  local msg="$*"
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "$ts [$level] $msg" | tee -a "$LOG_FILE"
}

die() {
  log "ERROR" "$*"
  log "INFO" "NOTIFY: Restore FAILED."
  exit 1
}

usage() {
  cat <<EOF
Usage:
  ./restore.sh <backup-YYYY-MM-DD-HHMMSS.tar.gz> <restore_destination_dir>

Examples:
  ./restore.sh /backup/local/backup-2025-12-10-143022.tar.gz /tmp/restore
EOF
}

main() {
  if (( $# != 2 )); then
    usage
    exit 1
  fi

  local ARCHIVE="$1"
  local DEST="$2"

  [[ -f "$ARCHIVE" ]] || die "Archive not found: $ARCHIVE"
  mkdir -p "$DEST" || die "Cannot create restore destination: $DEST"
  [[ -w "$DEST" ]] || die "Destination not writable: $DEST"

  log "INFO" "Verifying archive integrity..."
  gzip -t "$ARCHIVE" || die "Archive gzip integrity failed (gzip -t)."
  tar -tzf "$ARCHIVE" >/dev/null || die "Archive tar listing failed (tar -tzf)."

  log "INFO" "Restoring archive into: $DEST"
  tar -xzf "$ARCHIVE" -C "$DEST" || die "Restore extraction failed."

  log "INFO" "Restore SUCCESS"
  log "INFO" "NOTIFY: Restore completed successfully."
}

main "$@"
