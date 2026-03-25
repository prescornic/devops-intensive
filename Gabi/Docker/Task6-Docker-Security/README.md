# Task 6: Docker Security Hardening

## 📌 Overview

This project demonstrates **Docker security best practices** for building and running hardened containers in a production-like environment.

The implementation focuses on:

* Secure image building (multi-stage, minimal base)
* Secure runtime configuration (least privilege)
* Proper secrets management
* Automated vulnerability scanning
* Auto-generated security reports and checklists
* Fully automated testing and execution workflow

---

## Project Structure

```
Task6-Docker-Security/
├── app/
│   ├── app.py
│   └── requirements.txt
├── secrets/
│   └── app_secret.txt (generated, ignored by git)
├── scan-results/
│   ├── trivy.txt
│   ├── docker-scan.txt
│   └── grype.txt
├── Dockerfile.secure
├── docker-compose.secure.yaml
├── scan-images.sh
├── generate-security-docs.sh
├── secrets-setup.sh
├── run-all.sh
├── security-report.md
├── security-checklist.md
├── .dockerignore
├── .gitignore
├── .env.example
├── run.log
└── README.md
```

---

## Security Features Implemented

### 1. Dockerfile Security

* Multi-stage build (separates build and runtime)
* Minimal base image (`python:3.11-alpine`)
* Non-root user (`UID 10001`)
* No secrets stored in image layers
* `COPY` used instead of `ADD`
* Minimal installed dependencies
* `.dockerignore` excludes sensitive files

---

### 2. Runtime Security

Configured in `docker-compose.secure.yaml`:

* `read_only: true` → prevents filesystem modifications
* `tmpfs: /tmp` → controlled writable space
* `cap_drop: [ALL]` → removes Linux capabilities
* `no-new-privileges:true` → prevents privilege escalation
* CPU and memory limits enforced
* PID limits applied
* Health checks enabled

---

### 3. Secrets Management

* Secrets stored **outside the image**
* Injected at runtime via Docker secrets (file-based)
* `.env` used only for non-sensitive config
* `secrets/` excluded from Git

Example:

```
/run/secrets/app_secret
```

---

### 4. Image Scanning

Automated scanning using:

* **Trivy**
* **Docker Scan** (if available)
* **Grype**

All results are saved in:

```
scan-results/
```

---

### 5. Automated Security Documentation

Security documentation is **auto-generated**:

* `security-report.md`
* `security-checklist.md`

Generated from scan results using:

```bash
./generate-security-docs.sh
```

---

### 6. Full Automation Script

The entire workflow is automated with:

```bash
./run-all.sh
```

This script:

1. Creates secrets
2. Builds secure image
3. Starts container
4. Waits for health
5. Runs tests
6. Executes vulnerability scans
7. Generates security documentation
8. Logs everything to `run.log`
9. Optionally cleans up containers

---

## Usage

### Run full workflow

```bash
./run-all.sh all
```

---

### Run step-by-step

```bash
./run-all.sh setup
./run-all.sh test
./run-all.sh cleanup
```

---

## Manual Testing

### Start container

```bash
docker compose -f docker-compose.secure.yaml up -d --build
```

### Check status

```bash
docker compose -f docker-compose.secure.yaml ps
```

### Health check

```bash
curl http://localhost:8080/health
```

### Secret validation

```bash
curl http://localhost:8080/secret-check
```

---

## Run Security Scans

```bash
./scan-images.sh
```

---

## Generate Security Docs

```bash
./generate-security-docs.sh
```

---

## Cleanup

```bash
docker compose -f docker-compose.secure.yaml down
```

---

## Output Artifacts

After running the workflow, the following files are generated:

* `run.log` → full execution log
* `scan-results/` → raw scan outputs
* `security-report.md` → vulnerability summary
* `security-checklist.md` → security compliance checklist

These serve as **evidence of implementation**.

---

## Security Findings Summary

* No **critical vulnerabilities**
* Some **high vulnerabilities** remain:

  * From base image (Alpine)
  * From Python runtime / packaging tools

These are:

* Documented in `security-report.md`
* Common in real-world environments
* Mitigated through:

  * minimal image usage
  * reduced attack surface
  * non-root execution

---

## Key Security Principles Applied

* Least privilege (non-root, no capabilities)
* Immutable infrastructure (read-only FS)
* Separation of concerns (multi-stage builds)
* Secrets externalization
* Minimal attack surface
* Continuous vulnerability scanning
* Automated documentation

---

## Notes

This project is designed for **learning and demonstration purposes**, simulating production-grade container security practices.

While not all vulnerabilities can be eliminated (due to upstream dependencies), the system is:

* Hardened
* Auditable
* Reproducible
* Secure by design

---

## Conclusion

This task demonstrates how to:

* Build secure Docker images
* Run containers with strict security controls
* Manage secrets safely
* Scan for vulnerabilities
* Automate security reporting
* Create reproducible DevOps workflows

---