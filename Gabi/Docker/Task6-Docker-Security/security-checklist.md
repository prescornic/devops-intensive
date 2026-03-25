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
- [x] No critical vulnerabilities reported by Trivy
- [x] No high vulnerabilities reported by Trivy
- [x] No critical vulnerabilities reported by Grype
- [x] No high vulnerabilities reported by Grype

## Notes
- This checklist is auto-generated from the latest scan results.
- If high vulnerabilities remain, they should be documented in security-report.md.
