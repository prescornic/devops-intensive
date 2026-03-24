#!/usr/bin/env bash
#
# git-commit-logs.sh - Create daily summary and commit to Git

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

LOG_DIR="${LOG_DIR:-$PROJECT_DIR/logs}"
MAIN_LOG="$LOG_DIR/health-monitor.log"
SUMMARY_DIR="$LOG_DIR/summaries"

mkdir -p "$SUMMARY_DIR"

YESTERDAY="$(date -d 'yesterday' +%F || date +%F)"
SUMMARY_FILE="$SUMMARY_DIR/summary-$YESTERDAY.txt"

if [[ ! -f "$MAIN_LOG" ]]; then
  echo "No main log file at $MAIN_LOG, nothing to summarize."
  exit 0
fi

# Filter only yesterday's lines (logs start with YYYY-MM-DD)
grep "^$YESTERDAY" "$MAIN_LOG" > "$SUMMARY_FILE" || true

if [[ ! -s "$SUMMARY_FILE" ]]; then
  echo "No log entries for $YESTERDAY, not committing."
  rm -f "$SUMMARY_FILE"
  exit 0
fi

# Make sure we are in a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not inside a Git repository. Run 'git init' first."
  exit 1
fi

git add "$SUMMARY_FILE"

if git diff --cached --quiet; then
  echo "No changes to commit for $YESTERDAY"
  exit 0
fi

COMMIT_MSG="Health logs - $YESTERDAY"
git commit -m "$COMMIT_MSG"

echo "Committed summary for $YESTERDAY with message: $COMMIT_MSG"
