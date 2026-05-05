# Task 3: Docker Networking Deep Dive

## Network Architecture
This project demonstrates Docker's ability to isolate workloads and manage inter-container communication via various network drivers.

### 1. Bridge Network (Custom)
- **Concept:** Provides a private internal network for containers.
- **Key Feature:** Automatic DNS resolution. Unlike the default 'bridge', custom bridges allow containers to talk via `--name` instead of IP.

### 2. Host Network
- **Concept:** The container shares the host's networking namespace.
- **Use Case:** High-performance applications (removes NAT overhead) or apps needing to handle large port ranges.

### 3. None Network
- **Concept:** No external network interface is provided.
- **Use Case:** Highly secure processing tasks, secret generation, or batch jobs that don't require network access.

### 4. Practical Isolation Example
Implemented a scenario where:
- **Frontend** can only talk to **Backend**.
- **Backend** acts as a bridge, talking to both **Frontend** and **Database**.
- **Database** is isolated from the **Frontend**, significantly increasing security.

## Usage

1. **Setup:** `./setup-networks.sh`
![alt text](<../task-3-networking/evidence/1.png>)

2. **Deploy:** `./deploy-containers.sh`
![alt text](<../task-3-networking/evidence/2.png>)

3. **Test:** `./test-connectivity.sh`
![alt text](<../task-3-networking/evidence/3.png>)

4. **Clean:** `./cleanup.sh`
![alt text](<../task-3-networking/evidence/4.png>)