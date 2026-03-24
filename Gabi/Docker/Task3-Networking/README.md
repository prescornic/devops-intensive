# Docker Networking Deep Dive

## 📌 Overview

This project demonstrates Docker networking concepts and inter-container communication using multiple network types.

The following were implemented and tested:

* custom bridge networks
* host network
* none network
* multi-network containers
* network isolation
* a practical multi-tier architecture (frontend → backend → database)

---

## 🧱 Architecture

### Practical Example (3-Tier Design)

```
frontend (frontend-net)
    |
    v
backend (frontend-net, backend-net)
    |
    v
database (backend-net)
```

### Communication Rules

* frontend → backend ✅
* backend → database ✅
* frontend → database ❌ (blocked)

This mimics real-world application architecture and security segmentation.

---

## 🌐 Network Types Demonstrated

### 1. Custom Bridge Network

A custom bridge network enables containers to:

* communicate using container names
* resolve DNS automatically via Docker

Example:

* `bridge-a`
* `bridge-b`

---

### 2. Host Network

A container using host networking shares the host’s network stack.

**Use cases:**

* performance-sensitive applications
* direct host port access
* low-latency networking

**Note (macOS):**
On Docker Desktop for macOS, host networking is limited because Docker runs inside a VM. Full behavior is observable on native Linux systems.

---

### 3. None Network

A container started with `--network none` has no external network access.

**Use cases:**

* secure batch jobs
* isolated workloads
* high-security environments

---

### 4. Multi-Network Container

A container can be attached to multiple networks.

Example:

* `backend` connects to:

  * `frontend-net`
  * `backend-net`

This allows controlled communication between otherwise isolated networks.

---

## 🔒 Network Isolation

Two separate networks were created:

* `isolated-net-a`
* `isolated-net-b`

Containers in these networks:

* cannot resolve each other
* cannot communicate

A third container connected to both networks can act as a bridge.

---

## ⚙️ Automation Script

This project includes a unified automation script:

```bash
./run-all.sh
```

### Supported Commands

```bash
./run-all.sh setup
./run-all.sh deploy
./run-all.sh test
./run-all.sh cleanup
./run-all.sh all
```

### Purpose

The script provides:

* reproducible environment setup
* automated deployment
* automated testing
* simplified cleanup

This reflects real-world DevOps practices.

---

## 📝 Execution Logs

All script output is automatically saved to:

```
run.log
```

### Benefits

* full execution trace
* easy debugging
* proof of successful execution
* reusable logs for documentation

### Usage

```bash
./run-all.sh all
cat run.log
```

---

## 🚀 How to Run

### Run full workflow

```bash
./run-all.sh all
```

### Or step-by-step

```bash
./run-all.sh setup
./run-all.sh deploy
./run-all.sh test
./run-all.sh cleanup
```

---

## 🧪 Connectivity Tests (Verified)

### Custom Bridge Network

* `bridge-a` successfully pinged `bridge-b`
* DNS resolution via container name works

---

### Network Isolation

* `isolated-a` cannot resolve or reach `isolated-b`

---

### Multi-Network Container

* `network-bridge` can access containers on both networks

---

### Frontend / Backend / Database

* frontend can reach backend ✅
* backend can reach database ✅
* frontend cannot resolve database ❌

---

### None Network

* container has no network access
* cannot reach external IPs

---

## 🔍 Example Outputs

### DNS Resolution

```
nslookup bridge-b
Name: bridge-b
Address: 172.x.x.x
```

### Isolation Proof

```
ping: bad address 'isolated-b'
Expected failure
```

### None Network

```
ping: sendto: Network unreachable
```

---

## 🔐 Security Implications

Docker networking enables:

* strong service isolation
* controlled communication paths
* reduced attack surface
* enforcement of least-privilege networking

---

## 📦 Project Files

* `setup-networks.sh` – create networks
* `deploy-containers.sh` – deploy containers
* `test-connectivity.sh` – run connectivity tests
* `cleanup.sh` – remove all resources
* `run-all.sh` – full automation script
* `run.log` – execution logs
* `backend/` – simple backend API

---

## 🎯 Key Takeaways

* containers communicate via Docker DNS on shared networks
* separate networks provide strong isolation
* multi-network containers act as controlled bridges
* frontend/backend/database segmentation improves security
* automation scripts improve reproducibility and efficiency

---