# Docker & Docker Compose - Practical Tasks

## General Requirements (apply to all tasks)

- Use Docker Engine version 20.10+ and Docker Compose v2+
- Follow Docker best practices (minimal layers, .dockerignore, non-root users)
- All Dockerfiles and compose files should be in Git
- Include meaningful `.dockerignore` files to exclude unnecessary files
- Tag images appropriately with semantic versioning
- Document all commands and configurations
- Test on your local machine before submission

---

## Task 1: Dockerize a Simple Application

### Objective
Create a Docker container for a basic web application using best practices.

### Requirements
1. **Application Setup**:
   - Create a simple Python Flask or Node.js Express application with:
     - Root endpoint `/` returning "Hello from Docker!"
     - `/health` endpoint returning JSON: `{"status": "healthy", "timestamp": "..."}`
     - `/info` endpoint returning container environment information (hostname, platform)

2. **Dockerfile Requirements**:
   - Use official base image (python:3.11-slim or node:18-alpine)
   - Set working directory to `/app`
   - Copy only necessary files (use .dockerignore)
   - Install dependencies in a separate layer
   - Run as non-root user
   - Expose appropriate port
   - Use ENTRYPOINT or CMD correctly
   - Add LABEL with metadata (author, version, description)

3. **Build and Run**:
   - Build image with proper tag: `myapp:1.0.0`
   - Run container in detached mode
   - Map container port to host port 8080
   - Set environment variables for app configuration
   - Name the container meaningfully

4. **Testing**:
   - Verify all endpoints work correctly
   - Check container logs
   - Inspect container details
   - Test container restart behavior

### Deliverables
- `app.py` or `app.js` - application code
- `Dockerfile` - container definition
- `.dockerignore` - exclude unnecessary files
- `requirements.txt` or `package.json` - dependencies
- `README.md` - build and run instructions
- `test-commands.sh` - script with curl commands to test all endpoints
- Git repository

### Evaluation Criteria
- Dockerfile follows best practices
- Image size is optimized
- Application works correctly in container
- Non-root user implementation
- Clear documentation
- Proper .dockerignore usage

---

## Task 2: Multi-Stage Docker Build

### Objective
Implement a multi-stage Dockerfile to separate build and runtime environments, reducing image size.

### Requirements
1. **Application**:
   - Create a Java Spring Boot application OR
   - Create a Go application OR
   - Create a React/Angular/Vue frontend application

2. **Multi-Stage Dockerfile**:
   - **Stage 1 (Builder)**:
     - Use appropriate build image (maven:3.9-jdk-17, golang:1.21, node:18)
     - Copy source code
     - Install dependencies
     - Build the application
     - Run tests (optional but recommended)
   
   - **Stage 2 (Runtime)**:
     - Use minimal runtime image (openjdk:17-jre-slim, alpine, nginx:alpine)
     - Copy only compiled artifacts from builder stage
     - Do NOT include build tools or source code
     - Run as non-root user
     - Configure appropriate health checks

3. **Optimization**:
   - Compare image sizes between single-stage and multi-stage builds
   - Document size reduction achieved
   - Use layer caching effectively (copy dependency files before source)

4. **Security**:
   - Scan image for vulnerabilities using `docker scan` or Trivy
   - Address critical vulnerabilities if found
   - Document security scan results

### Deliverables
- Source code for chosen application
- `Dockerfile` with multi-stage build
- `Dockerfile.single` - single-stage version for comparison
- `.dockerignore`
- `build-compare.sh` - script to build both versions and compare sizes
- `security-scan.sh` - script to scan images
- `README.md` with size comparison and security analysis
- Git repository

### Evaluation Criteria
- Significant size reduction achieved (>50%)
- Runtime image contains only necessary components
- Build cache optimization implemented
- Security scan performed
- Performance not degraded
- Documentation includes metrics

---

## Task 3: Docker Networking Deep Dive

### Objective
Understand and implement different Docker network types and inter-container communication.

### Requirements
1. **Network Setup**:
   Create and demonstrate the following network types:
   - **Bridge Network** (custom):
     - Create custom bridge network
     - Deploy 2 containers that can communicate by container name
     - Test DNS resolution between containers
   
   - **Host Network**:
     - Deploy a container using host network
     - Demonstrate performance difference vs bridge (optional)
     - Document use cases
   
   - **None Network**:
     - Deploy an isolated container
     - Document when this is useful

2. **Multi-Network Container**:
   - Create a container connected to multiple networks simultaneously
   - Demonstrate it can communicate with containers on different networks
   - Example: proxy container bridging frontend and backend networks

3. **Network Isolation**:
   - Create two separate custom networks
   - Deploy containers in each network
   - Prove they CANNOT communicate with each other
   - Connect a third container to both networks as a bridge

4. **Practical Example**:
   - Frontend container (network: frontend-net)
   - Backend API container (networks: frontend-net, backend-net)
   - Database container (network: backend-net)
   - Demonstrate: Frontend → Backend → Database (Frontend cannot reach Database directly)

### Deliverables
- `setup-networks.sh` - create all networks
- `deploy-containers.sh` - deploy containers to appropriate networks
- `test-connectivity.sh` - test all communication paths
- `cleanup.sh` - remove all containers and networks
- `README.md` with network diagrams and explanations
- Screenshot or command output proving network isolation
- Git repository

### Evaluation Criteria
- All network types demonstrated correctly
- Network isolation proven
- DNS resolution between containers works
- Clear documentation with diagrams
- Security implications understood

---

## Task 4: Docker Volumes and Data Persistence

### Objective
Implement different volume strategies for data persistence and sharing between containers.

### Requirements
1. **Volume Types Implementation**:
   - **Named Volume**:
     - Create PostgreSQL/MySQL container with named volume
     - Insert data into database
     - Destroy and recreate container
     - Prove data persisted
   
   - **Bind Mount**:
     - Mount local configuration directory into nginx container
     - Modify config file locally
     - Reload nginx and verify changes applied
   
   - **tmpfs Mount**:
     - Create container with tmpfs mount for temporary data
     - Demonstrate data does NOT persist after container restart

2. **Data Container Pattern**:
   - Create a data-only container (or named volume)
   - Share volume between multiple containers
   - One container writes, another reads
   - Demonstrate data consistency

3. **Backup and Restore**:
   - Create backup script for volume data
   - Backup a database volume to tar.gz file
   - Restore data to a new volume
   - Verify data integrity

4. **Volume Drivers** (optional):
   - Explore different volume drivers
   - Use local driver with options (size limits, etc.)
   - Document differences

### Deliverables
- `docker-compose-volumes.yaml` - compose file demonstrating all volume types
- `backup-volume.sh` - backup script
- `restore-volume.sh` - restore script
- `test-persistence.sh` - script to test data persistence
- `README.md` with volume strategies explanation
- Documentation of when to use each volume type
- Git repository

### Evaluation Criteria
- All volume types correctly implemented
- Data persistence verified
- Backup/restore works correctly
- Performance considerations documented
- Clear understanding of use cases

---

## Task 5: Full-Stack Application with Docker Compose

### Objective
Build a complete multi-container application using Docker Compose, similar to the example shown in class but with additional services.

### Requirements
1. **Application Architecture**:
   - **Frontend**: React/Angular/Vue single-page application
   - **Backend API**: REST API (Python/Node.js/Java)
   - **Database**: PostgreSQL or MongoDB
   - **Cache**: Redis
   - **Reverse Proxy**: Nginx
   - **Monitoring**: Simple health check dashboard (optional)

2. **Docker Compose Configuration**:
   - Define all services in `docker-compose.yaml`
   - Use custom Dockerfiles where needed
   - Implement service dependencies (`depends_on`)
   - Configure multiple networks:
     - `frontend-network`: Frontend <-> Nginx <-> Backend
     - `backend-network`: Backend <-> Database <-> Redis
   - Use named volumes for database and redis data
   - Use bind mounts for nginx config
   - Set environment variables appropriately
   - Configure restart policies

3. **Nginx Configuration**:
   - Reverse proxy to frontend (/)
   - Reverse proxy to backend API (/api)
   - Serve static files efficiently
   - Add gzip compression
   - Configure appropriate headers

4. **Health Checks**:
   - Implement health check endpoints in all services
   - Configure Docker health checks in Compose file
   - Ensure dependent services wait for healthy status

5. **Environment Management**:
   - Support multiple environments (dev, prod)
   - Use `.env` file for configuration
   - Override compose file: `docker-compose.override.yaml` for dev
   - Production compose file: `docker-compose.prod.yaml`

### Deliverables
- `docker-compose.yaml` - main compose configuration
- `docker-compose.prod.yaml` - production overrides
- `docker-compose.override.yaml` - development overrides (ignored in git)
- `.env.example` - example environment variables
- Individual service directories with Dockerfiles
- `nginx/nginx.conf` - Nginx configuration
- `scripts/init-db.sql` - database initialization
- `start.sh` - script to start entire stack
- `stop.sh` - script to stop and cleanup
- `logs.sh` - script to view logs from all services
- `README.md` with architecture diagram and setup instructions
- Git repository

### Testing Requirements
Provide the following test cases:
```bash
# Build and start
docker-compose up -d --build

# Check all services healthy
docker-compose ps

# Test frontend
curl http://localhost/

# Test backend API
curl http://localhost/api/health

# Check logs
docker-compose logs -f backend

# Scale backend
docker-compose up -d --scale backend=3

# Stop all
docker-compose down -v
```

### Evaluation Criteria
- All services start correctly and communicate
- Network isolation properly implemented
- Data persists across restarts
- Health checks work correctly
- Environment configuration flexible
- Zero-downtime restart possible
- Clear documentation
- Code quality and organization

---

## Task 6: Docker Security Hardening

### Objective
Implement Docker security best practices for production-ready containers.

### Requirements
1. **Dockerfile Security**:
   - Use minimal base images (alpine, distroless)
   - Run as non-root user (create custom user)
   - Use COPY instead of ADD
   - Don't store secrets in layers
   - Pin package versions
   - Minimize installed packages
   - Use multi-stage builds to exclude build tools

2. **Image Scanning**:
   - Scan images with multiple tools:
     - `docker scan` (Snyk)
     - Trivy
     - Grype (optional)
   - Fix all critical and high vulnerabilities
   - Document scan results before/after fixes

3. **Runtime Security**:
   - Implement read-only root filesystem where possible
   - Drop unnecessary capabilities
   - Set resource limits (CPU, memory)
   - Use security options (no-new-privileges)
   - Implement Docker secrets for sensitive data
   - Use user namespaces (optional)

4. **Docker Compose Security**:
   ```yaml
   services:
     app:
       security_opt:
         - no-new-privileges:true
       cap_drop:
         - ALL
       cap_add:
         - NET_BIND_SERVICE
       read_only: true
       tmpfs:
         - /tmp
       mem_limit: 512m
       cpus: 0.5
   ```

5. **Secrets Management**:
   - Use Docker secrets or external vault
   - Never hardcode credentials
   - Use .env file for non-sensitive config
   - Add .env to .gitignore

6. **Network Security**:
   - Limit exposed ports
   - Use internal networks where possible
   - No privileged containers
   - Document necessary privileged operations

### Deliverables
- `Dockerfile.secure` - hardened Dockerfile
- `docker-compose.secure.yaml` - hardened compose file
- `scan-images.sh` - security scanning script
- `security-report.md` - vulnerability report before/after
- `secrets-setup.sh` - script to initialize Docker secrets
- `security-checklist.md` - checklist of all security measures
- `README.md` with security best practices
- Git repository (no secrets!)

### Security Checklist Example
```markdown
## Dockerfile Security
- [ ] Using minimal base image
- [ ] Running as non-root user (UID > 1000)
- [ ] No secrets in image layers
- [ ] All packages pinned to versions
- [ ] Multi-stage build used
- [ ] .dockerignore configured
- [ ] No unnecessary packages installed

## Runtime Security
- [ ] Read-only root filesystem where possible
- [ ] Unnecessary capabilities dropped
- [ ] Resource limits set
- [ ] no-new-privileges enabled
- [ ] Secrets using Docker secrets or vault
- [ ] Minimal exposed ports

## Image Scanning
- [ ] No critical vulnerabilities
- [ ] No high vulnerabilities (or documented exceptions)
- [ ] Regular scanning scheduled
```

### Evaluation Criteria
- Comprehensive security implementation
- All critical vulnerabilities addressed
- Security tools properly utilized
- Secrets properly managed
- Performance not significantly degraded
- Excellent documentation
- Checklist complete and validated

---

## Task 7: Container Monitoring and Logging

### Objective
Implement comprehensive monitoring and logging for containerized applications.

### Requirements
1. **Logging Setup**:
   - Configure different log drivers:
     - json-file (default)
     - syslog
     - journald
   - Implement centralized logging with:
     - ELK Stack (Elasticsearch, Logstash, Kibana) OR
     - Loki + Grafana OR
     - Fluentd + Elasticsearch
   - Configure log rotation
   - Implement structured logging in applications (JSON format)

2. **Metrics Collection**:
   - Deploy Prometheus for metrics collection
   - Configure container metrics export
   - Create Grafana dashboards showing:
     - Container CPU usage
     - Container memory usage
     - Network I/O
     - Disk I/O
     - Custom application metrics (request rate, error rate, duration)

3. **Health Monitoring**:
   - Implement comprehensive health checks
   - Configure alerting for:
     - Container down
     - High resource usage (>80% CPU/memory)
     - Application errors
     - Slow response times (>1s)

4. **Docker Compose Setup**:
   - Main application services
   - Prometheus
   - Grafana
   - Logging stack (choose one from above)
   - Export all data to volumes for persistence

### Deliverables
- `docker-compose.monitoring.yaml` - complete monitoring stack
- `prometheus/prometheus.yml` - Prometheus configuration
- `grafana/dashboards/` - Grafana dashboard JSONs
- `grafana/provisioning/` - Grafana provisioning configs
- `logstash/logstash.conf` - Logstash configuration (if using ELK)
- `test-logging.sh` - script to generate test logs
- `test-metrics.sh` - script to generate test traffic
- `README.md` with access URLs and credentials
- Screenshots of dashboards showing metrics
- Git repository

### Evaluation Criteria
- Complete monitoring stack deployed
- Metrics collected and visualized
- Logs centralized and searchable
- Alerts configured and working
- Dashboards are useful and well-organized
- Performance impact documented
- Comprehensive documentation

---

## Task 8: Container Performance Optimization

### Objective
Analyze and optimize container performance for production workloads.

### Requirements
1. **Image Optimization**:
   - Reduce image size by at least 50%
   - Optimize layer caching
   - Compare different base images (ubuntu vs alpine vs distroless)
   - Document size/security/compatibility trade-offs

2. **Build Optimization**:
   - Implement BuildKit features:
     - Cache mounts
     - Secret mounts
     - SSH mounts
   - Parallelize multi-stage builds
   - Measure and optimize build times

3. **Runtime Optimization**:
   - Tune resource limits (CPU, memory)
   - Optimize application startup time
   - Implement container orchestration best practices
   - Use init systems (tini/dumb-init) where needed

4. **Performance Testing**:
   - Create load testing scripts
   - Measure container performance:
     - Request throughput
     - Response latency (p50, p95, p99)
     - Resource utilization under load
   - Compare performance: native vs container (overhead analysis)
   - Test with different resource limits

5. **Benchmarking**:
   - Use tools like:
     - Apache Bench (ab)
     - wrk
     - hey
     - k6 (optional)
   - Generate performance reports
   - Create comparison charts

### Deliverables
- Multiple Dockerfile versions (unoptimized, optimized)
- `docker-compose.benchmark.yaml` - setup for performance testing
- `benchmark.sh` - comprehensive benchmarking script
- `load-test.sh` - load testing script
- `analyze-performance.py` or `.sh` - analysis script
- `performance-report.md` - detailed findings with graphs
- `optimization-guide.md` - step-by-step optimization process
- Before/after metrics comparison
- Git repository

### Performance Report Should Include
```markdown
## Image Size Comparison
- Unoptimized: 1.2GB
- Optimized: 450MB (62.5% reduction)

## Build Time Comparison
- Without BuildKit: 145s
- With BuildKit cache: 12s (91.7% improvement)

## Runtime Performance
- Native app: 5000 req/s, p95: 45ms
- Docker (unoptimized): 4200 req/s, p95: 65ms
- Docker (optimized): 4800 req/s, p95: 50ms

## Resource Usage Under Load
- CPU: 75% of limit
- Memory: 380MB / 512MB
- Network: 125MB/s

## Recommendations
1. Use alpine base (size) vs distroless (security)
2. Set memory limit to 512MB (optimal for this workload)
3. Enable BuildKit for 90% build time reduction
```

### Evaluation Criteria
- Significant improvements achieved
- Comprehensive benchmarking performed
- Trade-offs clearly documented
- Performance reports are data-driven
- Optimization steps are repeatable
- Recommendations are practical

---

## Task 9: Docker CI/CD Integration

### Objective
Integrate Docker into a CI/CD pipeline for automated build, test, and deployment.

### Requirements
1. **Choose CI/CD Platform**:
   - GitHub Actions OR
   - Bitbucket CI OR
   - Jenkins

2. **Pipeline Stages**:
   - **Lint**: Dockerfile linting (hadolint)
   - **Build**: Build Docker images
   - **Test**: Run unit tests in containers
   - **Scan**: Security scanning (Trivy, Snyk)
   - **Push**: Push to registry (Docker Hub/GitHub Container Registry/AWS ECR)
   - **Deploy**: Deploy to environment

3. **Multi-Architecture Builds**:
   - Build for linux/amd64 and linux/arm64
   - Use Docker buildx
   - Create multi-platform manifest

4. **Image Tagging Strategy**:
   - `latest` for main branch
   - `develop` for develop branch
   - Semantic versioning for releases (v1.0.0)
   - SHA tags for commit tracking

5. **Docker Compose Testing**:
   - Spin up entire stack in CI
   - Run integration tests
   - Collect test results
   - Tear down after tests

6. **Cache Optimization**:
   - Use layer caching in CI
   - Implement registry cache
   - Measure build time improvements

### Deliverables
- `.github/workflows/docker-ci.yaml` (or equivalent for chosen platform)
- `Dockerfile` with build arguments for CI
- `docker-compose.test.yaml` - test environment
- `tests/integration/` - integration test scripts
- `.hadolint.yaml` - Dockerfile linter config
- `scripts/build-multiarch.sh` - multi-platform build script
- `scripts/tag-and-push.sh` - tagging and push script
- `README.md` with pipeline documentation and badge
- Git repository

### Evaluation Criteria
- Complete CI/CD pipeline implemented
- All stages execute successfully
- Multi-architecture support working
- Security scanning integrated
- Proper secret management
- Fast build times (caching)
- Clear pipeline documentation

---

## Submission Guidelines

### For All Tasks:

1. **Git Repository Structure**:
   ```
   docker-task-N/
   ├── README.md
   ├── .gitignore
   ├── .dockerignore
   ├── docker-compose.yaml
   ├── Dockerfile
   ├── src/
   │   └── (application code)
   ├── configs/
   │   └── (configuration files)
   ├── scripts/
   │   └── (automation scripts)
   └── docs/
       └── (additional documentation)
   ```

2. **README.md Must Include**:
   - Task description
   - Architecture diagram (if applicable)
   - Prerequisites
   - Quick start guide
   - Detailed setup instructions
   - Testing procedures
   - Troubleshooting section
   - Cleanup instructions

3. **Code Quality**:
   - Follow Dockerfile best practices
   - Use .dockerignore to minimize context
   - Meaningful image tags
   - Clear comments in complex sections
   - Shell scripts with error handling

4. **Testing**:
   - All commands tested and working
   - Screenshots where applicable
   - Performance benchmarks documented
   - Edge cases considered

5. **.gitignore Must Include**:
   ```
   .env
   *.log
   .DS_Store
   node_modules/
   __pycache__/
   *.pyc
   target/
   dist/
   build/
   volumes/
   ```

6. **Documentation**:
   - Clear and concise
   - Includes command examples
   - Explains design decisions
   - Provides troubleshooting tips

---

## Evaluation Rubric (for each task)

| Criteria | Weight | Description |
|----------|--------|-------------|
| Functionality | 30% | Does it work correctly? All requirements met? |
| Docker Best Practices | 25% | Follows Dockerfile/Compose best practices? |
| Security | 15% | Implements security measures appropriately? |
| Documentation | 15% | Clear, comprehensive README and comments? |
| Code Quality | 10% | Clean, organized, maintainable code? |
| Git Usage | 5% | Proper commits, .gitignore, structure? |

**Total: 100%**

### Grading Scale:
- **90-100%**: Excellent - Production ready, all best practices
- **75-89%**: Good - Works well, minor improvements needed
- **60-74%**: Satisfactory - Meets basic requirements
- **Below 60%**: Needs improvement - Missing key requirements

---

## Additional Resources

### Official Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

### Tools
- [Hadolint](https://github.com/hadolint/hadolint) - Dockerfile linter
- [Trivy](https://github.com/aquasecurity/trivy) - Vulnerability scanner
- [Dive](https://github.com/wagoodman/dive) - Image layer explorer
- [Docker Bench Security](https://github.com/docker/docker-bench-security)

### Learning Resources
- [Play with Docker](https://labs.play-with-docker.com/)
- [Docker Labs](https://github.com/docker/labs)
- [Awesome Docker](https://github.com/veggiemonk/awesome-docker)

---

Remember: *"Containers are not tiny VMs, they're isolated processes."*
