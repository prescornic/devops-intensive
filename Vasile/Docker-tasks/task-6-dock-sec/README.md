# Docker Security Hardening Project

This project demonstrates Docker container security best practices using a secure Flask application.

## Security Features

- Minimal Alpine-based image
- Multi-stage Docker build
- Non-root container user
- Read-only root filesystem
- Dropped Linux capabilities
- `no-new-privileges` enabled
- Resource limits configured
- Docker secrets support
- Vulnerability scanning with Trivy and Docker Scout

---

# Secrets setup

Run:

```bash
./secrets-setup.sh
```

Expected response: 
- Directory created
- In terminal you should see:
```bash
Secrets initialized.
```

# Run Application

```bash
docker compose -f docker-compose.secure.yaml up -d --build
```

Open application:

```txt
http://localhost:5000
```

---

# Health Check

```bash
http://localhost:5000/health
```

Expected response:

```json
{"status":"healthy"}
```

---

# Security Scanning

Run scans:

```bash
./scan-images.sh
```

Tools used:
- Trivy
- Docker Scout

---

# Evidence

## Application Running

![Application](<../task-6-dock-sec/evidence/1.png>)

---

## Health Check

![Health Check](<../task-6-dock-sec/evidence/2.png>)

---

## Docker Containers

![Docker Compose PS](<../task-6-dock-sec/evidence/3.png>)

---

## Non-Root User Verification

![Non Root User](<../task-6-dock-sec/evidence/4.png>)

---

## Read-Only Filesystem Verification

![Read Only Filesystem](<../task-6-dock-sec/evidence/5.png>)

---

## Trivy Security Scan & Docker Scout Scan

![Scan](<../task-6-dock-sec/evidence/6.png>)

---

![Scan](<../task-6-dock-sec/evidence/7.png>)

---

![Scan](<../task-6-dock-sec/evidence/8.png>)

---

# Visual Diagram
```bash
┌─────────────────────────────────────────┐
│         HOST MACHINE                    │
│  ┌──────────────────────────────────┐   │
│  │  Container (Task6 Flask App)     │   │
│  │  • read-only filesystem          │   │
│  │  • no Linux capabilities         │   │
│  │  • cannot gain privileges        │   │
│  │  • 512MB RAM limit               │   │
│  │  • 0.5 CPU limit                 │   │
│  │  • secret mount from /run/secrets│   │
│  │                                  │   │
│  │    [internal-network] ──┐        │   │
│  └─────────────────────────┼────────┘   │
│                            │            │
│                [ISOLATED - No Internet] |
│                            │            │
│  ┌─────────────────────────┼─────────┐  │
│  │  Other containers on same network │  │
│  │  (database, cache, etc)           │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```