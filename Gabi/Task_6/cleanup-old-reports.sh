#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

DAYS="${1:-30}"

python3 - <<'PY'
import datetime as dt
import shutil
from pathlib import Path
import sys

days = int(sys.argv[1])
reports_dir = Path("./reports")
cutoff = dt.datetime.now(dt.timezone.utc) - dt.timedelta(days=days)

removed = 0
if reports_dir.exists():
    for child in reports_dir.iterdir():
        if not child.is_dir():
            continue
        try:
            d = dt.datetime.strptime(child.name, "%Y-%m-%d").replace(tzinfo=dt.timezone.utc)
        except ValueError:
            continue
        if d < cutoff:
            shutil.rmtree(child)
            removed += 1
            print(f"Removed: {child}")
print(f"Removed directories: {removed}")
PY "$DAYS"
