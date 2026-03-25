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
- Critical vulnerabilities: 0
- High vulnerabilities: 0
- Medium vulnerabilities: 0
- Low vulnerabilities: 0

### Docker Scan
- Status: Unavailable

### Grype
- Critical vulnerabilities: 0
- High vulnerabilities: 0
- Medium vulnerabilities: 0
- Low vulnerabilities: 0

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
- scan-results/trivy.txt
- scan-results/docker-scan.txt
- scan-results/grype.txt
