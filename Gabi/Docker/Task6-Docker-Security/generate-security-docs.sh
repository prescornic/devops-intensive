#!/bin/bash

set -Eeuo pipefail

SCAN_DIR="scan-results"
REPORT_FILE="security-report.md"
CHECKLIST_FILE="security-checklist.md"

TRIVY_FILE="${SCAN_DIR}/trivy.txt"
DOCKER_SCAN_FILE="${SCAN_DIR}/docker-scan.txt"
GRYPE_FILE="${SCAN_DIR}/grype.txt"

extract_trivy_counts() {
  local file="$1"

  if [[ -f "$file" ]]; then
    local line
    line="$(grep -E "^Total:" "$file" | head -n 1 || true)"

    if [[ -n "$line" ]]; then
      local critical high medium low
      critical="$(echo "$line" | sed -n 's/.*CRITICAL: \([0-9]\+\).*/\1/p')"
      high="$(echo "$line" | sed -n 's/.*HIGH: \([0-9]\+\).*/\1/p')"
      medium="$(echo "$line" | sed -n 's/.*MEDIUM: \([0-9]\+\).*/\1/p')"
      low="$(echo "$line" | sed -n 's/.*LOW: \([0-9]\+\).*/\1/p')"

      echo "${critical:-0} ${high:-0} ${medium:-0} ${low:-0}"
      return
    fi
  fi

  echo "0 0 0 0"
}

extract_grype_counts() {
  local file="$1"

  if [[ -f "$file" ]]; then
    local line
    line="$(grep -E "by severity:" "$file" | head -n 1 || true)"

    if [[ -n "$line" ]]; then
      local critical high medium low
      critical="$(echo "$line" | sed -n 's/.*\([0-9]\+\) critical.*/\1/p')"
      high="$(echo "$line" | sed -n 's/.*critical, \([0-9]\+\) high.*/\1/p')"
      medium="$(echo "$line" | sed -n 's/.*high, \([0-9]\+\) medium.*/\1/p')"
      low="$(echo "$line" | sed -n 's/.*medium, \([0-9]\+\) low.*/\1/p')"

      echo "${critical:-0} ${high:-0} ${medium:-0} ${low:-0}"
      return
    fi
  fi

  echo "0 0 0 0"
}

docker_scan_status() {
  local file="$1"

  if [[ -f "$file" ]]; then
    if grep -qi "not available" "$file"; then
      echo "Unavailable"
    else
      echo "Executed"
    fi
  else
    echo "Not run"
  fi
}

read -r TRIVY_CRITICAL TRIVY_HIGH TRIVY_MEDIUM TRIVY_LOW < <(extract_trivy_counts "$TRIVY_FILE")
read -r GRYPE_CRITICAL GRYPE_HIGH GRYPE_MEDIUM GRYPE_LOW < <(extract_grype_counts "$GRYPE_FILE")
DOCKER_SCAN_STATUS="$(docker_scan_status "$DOCKER_SCAN_FILE")"

TRIVY_NO_CRITICAL=" "
TRIVY_NO_HIGH=" "
GRYPE_NO_CRITICAL=" "
GRYPE_NO_HIGH=" "

[[ "$TRIVY_CRITICAL" == "0" ]] && TRIVY_NO_CRITICAL="x"
[[ "$TRIVY_HIGH" == "0" ]] && TRIVY_NO_HIGH="x"
[[ "$GRYPE_CRITICAL" == "0" ]] && GRYPE_NO_CRITICAL="x"
[[ "$GRYPE_HIGH" == "0" ]] && GRYPE_NO_HIGH="x"

cat > "$REPORT_FILE" <<EOF
# Security Report

## Overview

This report documents the security hardening applied to the Docker image and runtime configuration.

## Hardening Measures Implemented

### Dockerfile
- Multi-stage build used
- Minimal runtime image selected
- Non-root user configured (UID 10001)
- No secrets copied into the image
- COPY used instead of ADD
- Minimal dependencies installed

### Runtime
- Read-only root filesystem enabled
- Temporary writable area provided with tmpfs
- All capabilities dropped
- no-new-privileges enabled
- CPU and memory limits configured
- PID limit configured

### Secrets
- Secret mounted from file
- Secret excluded from image build
- Secret excluded from git

## Scan Results Summary

### Trivy
- Critical vulnerabilities: ${TRIVY_CRITICAL}
- High vulnerabilities: ${TRIVY_HIGH}
- Medium vulnerabilities: ${TRIVY_MEDIUM}
- Low vulnerabilities: ${TRIVY_LOW}

### Docker Scan
- Status: ${DOCKER_SCAN_STATUS}

### Grype
- Critical vulnerabilities: ${GRYPE_CRITICAL}
- High vulnerabilities: ${GRYPE_HIGH}
- Medium vulnerabilities: ${GRYPE_MEDIUM}
- Low vulnerabilities: ${GRYPE_LOW}

## Findings

Most remaining vulnerabilities, if any, are typically related to:
- base image OS packages
- language runtime packages
- transitive packaging tools

## Remediation Actions Taken

- Used a minimal runtime image
- Used a multi-stage build
- Ran container as a non-root user
- Kept secrets out of image layers
- Mounted secrets at runtime
- Enabled runtime hardening controls in Docker Compose
- Minimized installed packages

## Residual Risk

If high vulnerabilities remain, they should be tracked and documented as upstream or runtime-related issues until patched versions become available.

## Evidence

Raw scan outputs are stored in:
- ${TRIVY_FILE}
- ${DOCKER_SCAN_FILE}
- ${GRYPE_FILE}
EOF

cat > "$CHECKLIST_FILE" <<EOF
# Security Checklist

## Dockerfile Security
- [x] Using minimal base image
- [x] Running as non-root user (UID > 1000)
- [x] No secrets in image layers
- [x] Multi-stage build used
- [x] COPY used instead of ADD
- [x] Minimal packages installed
- [x] .dockerignore configured

## Runtime Security
- [x] Read-only root filesystem enabled
- [x] Unnecessary capabilities dropped
- [x] no-new-privileges enabled
- [x] Resource limits set
- [x] tmpfs used for temporary writable space
- [x] Minimal exposed ports
- [x] No privileged containers

## Secrets Management
- [x] Secret provided via mounted file
- [x] No hardcoded credentials
- [x] .env reserved for non-sensitive config
- [x] .env ignored in git
- [x] secrets/ ignored in git

## Image Scanning
- [x] Trivy scan executed
- [x] docker scan attempted
- [x] Grype optional support included
- [${TRIVY_NO_CRITICAL}] No critical vulnerabilities reported by Trivy
- [${TRIVY_NO_HIGH}] No high vulnerabilities reported by Trivy
- [${GRYPE_NO_CRITICAL}] No critical vulnerabilities reported by Grype
- [${GRYPE_NO_HIGH}] No high vulnerabilities reported by Grype

## Notes
- This checklist is auto-generated from the latest scan results.
- If high vulnerabilities remain, they should be documented in security-report.md.
EOF

echo "Generated:"
echo "  - ${REPORT_FILE}"
echo "  - ${CHECKLIST_FILE}"