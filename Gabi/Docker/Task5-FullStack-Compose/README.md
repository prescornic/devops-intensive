# Full-Stack Application with Docker Compose

## 📌 Overview

This project demonstrates a complete multi-container application using Docker Compose.

It includes:

* **Frontend**: React (Vite)
* **Backend API**: Python Flask
* **Database**: PostgreSQL
* **Cache**: Redis
* **Reverse Proxy**: Nginx

The goal is to simulate a real-world full-stack architecture with proper networking, persistence, health checks, and automation.

---

## 🧱 Architecture

```text
Browser
   |
   v
Nginx (Reverse Proxy)
 |   \
 |    \
 v     v
Frontend  Backend API
             |
        -------------
        |           |
        v           v
    PostgreSQL    Redis
```

---

## 🌐 Networking

### frontend-network

Used by:

* nginx
* frontend
* backend

### backend-network

Used by:

* backend
* postgres
* redis

✔ Ensures proper service isolation
✔ Backend services are not exposed externally

---

## 💾 Volumes

| Volume        | Purpose              |
| ------------- | -------------------- |
| postgres_data | Database persistence |
| redis_data    | Redis persistence    |

✔ Data persists across container restarts

---

## ⚙️ Environment Configuration

Copy environment variables:

```bash
cp .env.example .env
```

Example variables:

```env
POSTGRES_DB=appdb
POSTGRES_USER=appuser
POSTGRES_PASSWORD=secretpass
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

REDIS_HOST=redis
REDIS_PORT=6379

BACKEND_PORT=5000
FRONTEND_PORT=3000
NGINX_PORT=80
```

---

## 🚀 Running the Application

### Start all services

```bash
./start.sh
```

### Stop all services

```bash
./stop.sh
```

### View logs

```bash
./logs.sh
```

Or for a specific service:

```bash
./logs.sh backend
```

---

## 🧪 Testing the Application

### Check services

```bash
docker compose ps
```

---

### Test frontend

```bash
curl http://localhost/
```

---

### Test backend health

```bash
curl http://localhost/api/health
```

Expected:

```json
{"status":"healthy","database":true,"redis":true}
```

---

### Test users endpoint

```bash
curl http://localhost/api/users
```

---

### Test Redis cache

```bash
curl http://localhost/api/cache
curl http://localhost/api/cache
```

✔ Counter should increase

---

## 📈 Scaling Backend

```bash
docker compose up -d --scale backend=3
```

```bash
docker compose ps
```

✔ Multiple backend containers will be created
✔ Nginx resolves backend dynamically via Docker DNS

---

## 🔄 Automation

### Run full workflow

```bash
./run-all.sh
```

This script:

* builds and starts all services
* waits for health checks
* runs all required test cases
* demonstrates backend scaling
* logs all output

---

## 📝 Logging

### Workflow logs

```text
run.log
```

Contains:

* service startup logs
* health check results
* API responses
* scaling output

---

## 🔧 Nginx Configuration

Nginx acts as a reverse proxy:

* `/` → frontend
* `/api/` → backend

Features:

* gzip compression enabled
* security headers configured
* Docker DNS resolver (`127.0.0.11`)
* dynamic backend resolution for scaling

---

## ❤️ Health Checks

Health checks are configured for:

* PostgreSQL (`pg_isready`)
* Redis (`redis-cli ping`)
* Backend (`/api/health`)
* Frontend (HTTP check)
* Nginx (`/health`)

✔ Ensures services start in correct order
✔ Improves reliability

---

## 📂 Project Structure

```text
Task5-FullStack-Compose/
├── frontend/
├── backend/
├── nginx/
├── scripts/
├── docker-compose.yaml
├── docker-compose.prod.yaml
├── docker-compose.override.yaml
├── .env.example
├── start.sh
├── stop.sh
├── logs.sh
├── run-all.sh
├── run.log
└── README.md
```

---

## ⚠️ Important Notes

* `container_name` is **not used** to allow backend scaling
* Docker Compose automatically manages container naming
* Nginx uses Docker internal DNS for service discovery
* This setup is optimized for **learning and demonstration purposes**
* The full workflow was validated successfully using `./run-all.sh`, and the results were saved in `run.log`.

---

## 🚀 Key Takeaways

* Multi-container applications require proper networking and isolation
* Docker Compose simplifies orchestration of complex systems
* Named volumes ensure persistent storage
* Reverse proxies enable clean routing between services
* Health checks improve service reliability
* Automation scripts improve reproducibility
* Logging provides visibility into system behavior

---

## 🏁 Conclusion

This project demonstrates a complete Docker Compose-based full-stack system with:

* multiple services
* inter-container communication
* persistent storage
* reverse proxy routing
* scaling capability
* automated testing workflow