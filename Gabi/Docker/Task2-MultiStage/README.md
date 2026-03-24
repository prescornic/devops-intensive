# Multi-Stage Docker Build – Go Application

## 📌 Overview

This project demonstrates how to use **multi-stage Docker builds** to optimize container images by separating the **build stage** from the **runtime stage**.

The application is a simple Go web server exposing the following endpoints:

* `/` → returns `Hello from Multi-Stage Docker!`
* `/health` → returns application health status and timestamp
* `/info` → returns runtime information (hostname, platform, Go version, environment)

---

## 🧱 Architecture

```
Builder Stage (golang:1.21)
    ↓
- Download dependencies
- Compile Go binary
- Includes full toolchain

    ↓ (copy binary only)

Runtime Stage (alpine)
    ↓
- Only compiled binary
- Minimal OS
- No build tools
```

---

## ⚙️ Build Instructions

### Build Single-Stage Image

```bash
docker build -f Dockerfile.single -t myapp-single:1.0.0 .
```

### Build Multi-Stage Image

```bash
docker build -f Dockerfile -t myapp-multi:1.0.0 .
```

---

## 📊 Image Size Comparison

Run the comparison script:

```bash
./build-compare.sh
```

### Example Output

```
REPOSITORY       TAG     SIZE
myapp-single     1.0.0   1.2GB
myapp-multi      1.0.0   15MB
```

### 📉 Size Reduction

```
((Single - Multi) / Single) * 100 = ~98%
```

### 🔍 Explanation

The size reduction is achieved because:

* The **single-stage image** contains:

  * Go compiler
  * build tools
  * full dependency chain

* The **multi-stage image** contains only:

  * compiled Go binary
  * minimal runtime environment (Alpine Linux)

This results in a **significant reduction (>50%)**, improving performance and efficiency.

---

## 🚀 Run the Application

```bash
docker run -d \
  --name myapp-multi-container \
  -p 8081:8080 \
  -e APP_ENV=production \
  myapp-multi:1.0.0
```

---

## 🧪 Test Endpoints

```bash
curl http://localhost:8081/
curl http://localhost:8081/health
curl http://localhost:8081/info
```

---

## ❤️ Health Check

The container includes a Docker health check:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget --spider --quiet http://127.0.0.1:8080/health || exit 1
```

This enables:

* automatic health monitoring
* compatibility with container orchestration systems (Kubernetes, ECS)

---

## ⚡ Build Optimization (Layer Caching)

The Dockerfile is optimized for caching:

```dockerfile
COPY go.mod ./
RUN go mod download
```

Benefits:

* dependencies are cached
* faster rebuilds when only source code changes

---

## 🔐 Security Analysis

Security scans were performed using **Trivy**:

```bash
./security-scan.sh
```

### Findings

**Single-stage image:**

* larger attack surface
* includes build tools and compilers
* more vulnerabilities

**Multi-stage image:**

* reduced attack surface
* minimal runtime dependencies
* fewer vulnerabilities

---

## 🔒 Security Benefits of Multi-Stage Builds

* no build tools in production image
* smaller dependency footprint
* reduced vulnerability exposure
* improved maintainability

---

## 👤 Non-Root User

The container runs as a non-root user:

```dockerfile
USER appuser
```

Benefits:

* prevents privilege escalation
* aligns with container security best practices

---

## 📦 Deliverables

* Go application source code
* `Dockerfile` (multi-stage)
* `Dockerfile.single` (single-stage)
* `.dockerignore`
* `build-compare.sh`
* `security-scan.sh`
* `README.md`

---

## 🎯 Key Takeaways

* Multi-stage builds significantly reduce image size (**>50% reduction achieved**)
* runtime images should contain only required components
* separation of build and runtime improves:

  * security
  * performance
  * maintainability
* Docker layer caching improves build efficiency

---

## 🏁 Conclusion

The multi-stage Docker build approach provides:

* smaller images → faster deployment and startup
* improved security → reduced vulnerabilities and attack surface
* cleaner architecture → separation of concerns

This approach follows modern DevOps best practices for building production-ready container images.
