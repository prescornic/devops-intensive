#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
./fetch-and-process.py --config config.yaml --report-only
