#!/usr/bin/env bash
set -euo pipefail

# Commits backup logs to Git daily.
# Commit message format: "Backup logs - YYYY-MM-DD"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load config (for LOG_DIR)
CONF_FILE="${CONF_FILE:-$PROJECT_DIR/backup.conf}"
if [[ -f "$CONF_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONF_FILE"
fi

LOG_DIR="${LOG_DIR:-$PROJECT_DIR/logs}"

cd "$PROJECT_DIR"

# Ensure we are inside a git repo (Task requires Git integration)
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: Not inside a git repository. Run this from within your repo."
  exit 1
fi

# We commit yesterday's backup log because the cron runs at midnight (00:05).
LOG_DATE="$(date -d 'yesterday' +%F 2>/dev/null || true)"
if [[ -z "${LOG_DATE}" ]]; then
  # fallback for systems without GNU date -d (rare on Ubuntu)
  LOG_DATE="$(date +%F)"
fi

LOG_FILE="$LOG_DIR/backup-$LOG_DATE.log"

if [[ ! -f "$LOG_FILE" ]]; then
  echo "INFO: No backup log file found for $LOG_DATE ($LOG_FILE). Nothing to commit."
  exit 0
fi

git add "$LOG_FILE"

# If nothing staged, skip commit
if git diff --cached --quiet; then
  echo "INFO: No changes to commit."
  exit 0
fi

git commit -m "Backup logs - $LOG_DATE"
echo "OK: Committed backup log for $LOG_DATE"
