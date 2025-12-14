#!/usr/bin/env bash
set -euo pipefail

# backup.sh <source_dir> <destination>
# destination can be:
#   - local path: /backup/local
#   - remote ssh path: user@host:/remote/path

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_FILE="${CONF_FILE:-$SCRIPT_DIR/backup.conf}"

# Load config (if present)
if [[ -f "$CONF_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONF_FILE"
fi

LOG_DIR="${LOG_DIR:-$SCRIPT_DIR/logs}"
RETENTION_COUNT="${RETENTION_COUNT:-7}"
MIN_FREE_MB="${MIN_FREE_MB:-500}"
PROGRESS_THRESHOLD_MB="${PROGRESS_THRESHOLD_MB:-200}"
SSH_CONNECT_TIMEOUT="${SSH_CONNECT_TIMEOUT:-5}"
SSH_PORT="${SSH_PORT:-22}"

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/backup-$(date +%F).log"

log() {
  local level="$1"; shift
  local msg="$*"
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "$ts [$level] $msg" | tee -a "$LOG_FILE"
}

die() {
  log "ERROR" "$*"
  log "INFO" "NOTIFY: Backup FAILED."
  exit 1
}

usage() {
  cat <<EOF
Usage:
  ./backup.sh <source_dir> <destination>

Examples:
  ./backup.sh /home/user/documents /backup/local
  ./backup.sh /var/www/html user@backup-server:/backups/web
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

is_remote_dest() {
  [[ "$1" =~ .+@.+:.+ ]]
}

parse_remote() {
  local dest="$1"   # user@host:/path
  REMOTE_USERHOST="${dest%%:*}"
  REMOTE_PATH="${dest#*:}"
}

check_source() {
  local src="$1"
  [[ -d "$src" ]] || die "Source directory does not exist: $src"
  [[ -r "$src" ]] || die "Source directory not readable: $src"
}

source_size_bytes() {
  local src="$1"
  du -sb "$src" 2>/dev/null | awk '{print $1}'
}

archive_size_bytes() {
  local f="$1"
  stat -c%s "$f"
}

bytes_to_human() {
  local b="$1"
  awk -v b="$b" 'BEGIN{
    split("B KB MB GB TB",u," ");
    i=1;
    while(b>=1024 && i<5){b/=1024;i++}
    printf "%.2f %s", b, u[i]
  }'
}

check_local_dest_space() {
  local dest="$1"
  mkdir -p "$dest" || die "Cannot create destination directory: $dest"
  [[ -w "$dest" ]] || die "Destination not writable: $dest"

  local avail_kb
  avail_kb=$(df -Pk "$dest" | awk 'NR==2 {print $4}')
  local avail_mb=$((avail_kb / 1024))

  if (( avail_mb < MIN_FREE_MB )); then
    die "Insufficient disk space on destination. Available ${avail_mb}MB < required ${MIN_FREE_MB}MB"
  fi
}

check_remote_connectivity() {
  local userhost="$1"
  log "INFO" "Checking SSH connectivity to $userhost ..."
  if ! timeout "$SSH_CONNECT_TIMEOUT" ssh -p "$SSH_PORT" -o BatchMode=yes -o ConnectTimeout="$SSH_CONNECT_TIMEOUT" "$userhost" "echo ok" >/dev/null 2>&1; then
    die "Cannot reach remote destination via SSH (check network/keys): $userhost"
  fi
}

ensure_remote_path() {
  local userhost="$1"
  local path="$2"
  ssh -p "$SSH_PORT" "$userhost" "mkdir -p '$path'" || die "Failed to create remote path: $path"
}

make_archive_name() {
  echo "backup-$(date +%F-%H%M%S).tar.gz"
}

create_archive() {
  local src="$1"
  local out_file="$2"
  local src_parent src_base
  src_parent="$(dirname "$src")"
  src_base="$(basename "$src")"

  local src_bytes src_mb
  src_bytes="$(source_size_bytes "$src")"
  src_mb=$((src_bytes / 1024 / 1024))

  log "INFO" "Creating archive: $out_file"
  log "INFO" "Source size: $(bytes_to_human "$src_bytes")"

  # If pv exists and size large enough, show progress
  if command -v pv >/dev/null 2>&1 && (( src_mb >= PROGRESS_THRESHOLD_MB )); then
    (cd "$src_parent" && tar -cf - "$src_base") \
      | pv -s "$src_bytes" \
      | gzip -c > "$out_file"
  else
    (cd "$src_parent" && tar -czf "$out_file" "$src_base")
  fi
}

verify_archive() {
  local archive="$1"
  log "INFO" "Verifying archive integrity..."
  gzip -t "$archive" || die "Archive integrity check failed (gzip -t)"
  tar -tzf "$archive" >/dev/null || die "Archive listing failed (tar -tzf)"
  log "INFO" "Archive integrity OK"
}

compare_sizes() {
  local src_bytes="$1"
  local arc_bytes="$2"

  log "INFO" "Archive size: $(bytes_to_human "$arc_bytes")"

  awk -v s="$src_bytes" -v a="$arc_bytes" 'BEGIN{
    if (s > 0) {
      ratio = (a/s)*100;
      printf "Compression ratio: %.2f%% (archive/source)\n", ratio
    } else {
      print "Compression ratio: N/A"
    }
  }' | while read -r line; do log "INFO" "$line"; done
}

retention_local() {
  local dest="$1"
  log "INFO" "Retention: keeping last $RETENTION_COUNT backups in $dest"

  mapfile -t files < <(ls -1t "$dest"/backup-*.tar.gz 2>/dev/null || true)
  local count="${#files[@]}"

  if (( count <= RETENTION_COUNT )); then
    log "INFO" "No old backups to delete (found $count)"
    return
  fi

  for ((i=RETENTION_COUNT; i<count; i++)); do
    log "INFO" "Deleting old backup: ${files[$i]}"
    rm -f "${files[$i]}" || log "WARN" "Failed to delete: ${files[$i]}"
  done
}

retention_remote() {
  local userhost="$1"
  local path="$2"
  log "INFO" "Remote retention: keeping last $RETENTION_COUNT backups in $userhost:$path"

  ssh -p "$SSH_PORT" "$userhost" bash -lc "set -e;
    cd '$path' 2>/dev/null || exit 0;
    ls -1t backup-*.tar.gz 2>/dev/null | tail -n +$((RETENTION_COUNT+1)) | xargs -r rm -f
  " || log "WARN" "Remote retention failed (non-fatal)."
}

main() {
  if (( $# != 2 )); then
    usage
    exit 1
  fi

  require_cmd tar
  require_cmd gzip
  require_cmd du
  require_cmd df
  require_cmd stat

  local SRC="$1"
  local DEST="$2"

  check_source "$SRC"

  local archive_name tmp_archive
  archive_name="$(make_archive_name)"
  tmp_archive="$SCRIPT_DIR/$archive_name"

  local src_bytes
  src_bytes="$(source_size_bytes "$SRC")"
  [[ -n "$src_bytes" ]] || die "Could not calculate source size (du -sb failed)."

  if is_remote_dest "$DEST"; then
    # Remote backup
    require_cmd ssh
    require_cmd scp
    require_cmd timeout

    parse_remote "$DEST"
    check_remote_connectivity "$REMOTE_USERHOST"
    ensure_remote_path "$REMOTE_USERHOST" "$REMOTE_PATH"

    create_archive "$SRC" "$tmp_archive"
    verify_archive "$tmp_archive"

    local arc_bytes
    arc_bytes="$(archive_size_bytes "$tmp_archive")"
    compare_sizes "$src_bytes" "$arc_bytes"

    log "INFO" "Transferring archive via scp to: $REMOTE_USERHOST:$REMOTE_PATH/$archive_name"
    scp -P "$SSH_PORT" "$tmp_archive" "$REMOTE_USERHOST:$REMOTE_PATH/$archive_name" || die "Remote transfer failed (scp)."

    rm -f "$tmp_archive"
    retention_remote "$REMOTE_USERHOST" "$REMOTE_PATH"

    log "INFO" "Backup SUCCESS (remote): $REMOTE_USERHOST:$REMOTE_PATH/$archive_name"
    log "INFO" "NOTIFY: Backup completed successfully."
  else
    # Local backup
    check_local_dest_space "$DEST"

    create_archive "$SRC" "$tmp_archive"
    verify_archive "$tmp_archive"

    local arc_bytes
    arc_bytes="$(archive_size_bytes "$tmp_archive")"
    compare_sizes "$src_bytes" "$arc_bytes"

    log "INFO" "Moving archive to destination: $DEST/$archive_name"
    mv "$tmp_archive" "$DEST/$archive_name" || die "Failed to move archive to destination."

    retention_local "$DEST"

    log "INFO" "Backup SUCCESS (local): $DEST/$archive_name"
    log "INFO" "NOTIFY: Backup completed successfully."
  fi
}

main "$@"
