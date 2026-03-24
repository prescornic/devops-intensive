# Dockerized Flask Application

## 📌 Overview

This project demonstrates how to containerize a simple Python Flask application using Docker, following best practices.

The application exposes the following endpoints:

* `/` → returns `Hello from Docker!`
* `/health` → returns application health status and timestamp
* `/info` → returns container runtime information (hostname, platform, Python version, environment)

---

## 🧱 Architecture

```
Client (curl / browser)
        ↓
Docker Container (Flask App)
        ↓
Python Runtime (python:3.11-slim)
```

---

## ⚙️ Application Structure

```
docker-flask-app/
├── app/
│   ├── __init__.py
│   └── routes.py
├── app.py
├── requirements.txt
├── Dockerfile
├── .dockerignore
├── README.md
└── test-commands.sh
```

---

## ⚙️ Build Instructions

Build the Docker image:

```bash
docker build -t myapp:1.0.0 .
```

---

## 🚀 Run the Container

```bash
docker run -d \
  --name myapp-container \
  -p 8080:5000 \
  -e APP_ENV=production \
  -e APP_DEBUG=false \
  myapp:1.0.0
```

---

## 🧪 Test Endpoints

```bash
curl http://localhost:8080/
curl http://localhost:8080/health
curl http://localhost:8080/info
```

Or use the test script:

```bash
./test-commands.sh
```

---

## 📜 Test Script

```bash
#!/bin/bash

echo "Testing /"
curl -s http://localhost:8080/

echo -e "\nTesting /health"
curl -s http://localhost:8080/health

echo -e "\nTesting /info"
curl -s http://localhost:8080/info
```

---

## 📊 Container Management

### View running containers

```bash
docker ps
```

### View logs

```bash
docker logs myapp-container
```

### Inspect container

```bash
docker inspect myapp-container
```

---

## 🔁 Restart Behavior Test

```bash
docker restart myapp-container
curl http://localhost:8080/health
```

This confirms the application remains functional after restart.

---

## 🐳 Dockerfile Explanation

The Dockerfile follows best practices:

### Base Image

```dockerfile
FROM python:3.11-slim
```

* lightweight official image
* reduces final image size

---

### Working Directory

```dockerfile
WORKDIR /app
```

* ensures consistent execution path inside container

---

### Dependency Installation (Layer Optimization)

```dockerfile
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
```

* dependencies installed in a separate layer
* improves Docker build caching

---

### Copy Application Code

```dockerfile
COPY app ./app
COPY app.py .
```

* only necessary files are included

---

### Non-Root User (Security Best Practice)

```dockerfile
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
USER appuser
```

* prevents privilege escalation
* improves container security

---

### Environment Variables

```dockerfile
ENV APP_HOST=0.0.0.0 APP_PORT=5000 APP_ENV=production
```

* enables runtime configuration
* makes container portable across environments

---

### Exposed Port

```dockerfile
EXPOSE 5000
```

* documents the application port

---

### Application Start Command

```dockerfile
CMD ["python", "app.py"]
```

* defines container entry point

---

## 🚫 .dockerignore Usage

The `.dockerignore` file excludes unnecessary files:

```
venv/
__pycache__/
*.pyc
.git
.gitignore
```

### Benefits

* smaller image size
* faster builds
* cleaner runtime environment

---

## 🔐 Security Considerations

* container runs as non-root user
* minimal base image reduces attack surface
* no unnecessary files included
* environment variables used instead of hardcoding

---

## 🎯 Best Practices Applied

* official base image (`python:3.11-slim`)
* non-root user
* minimal image size
* layer caching optimization
* environment-based configuration
* clear separation of concerns

---

## 📦 Deliverables

* Flask application source code
* `Dockerfile`
* `.dockerignore`
* `requirements.txt`
* `README.md`
* `test-commands.sh`

---

## 🏁 Conclusion

This project demonstrates how to:

* containerize a Python application using Docker
* follow best practices for building images
* ensure security using non-root users
* validate application behavior through testing

T
