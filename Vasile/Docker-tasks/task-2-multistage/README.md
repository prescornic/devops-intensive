This project provides a comparison between the standard single-stage Docker build and a optimized one, (multi-stage build Python Flask application).

## Optimization Results

By implementing multi-stage builds and switching to a `slim` base image, achieved significant improvements in both performance and security.

![alt text](<../task-2-multistage/evidence/1.png>)

---

## Implementation Details

### Multi-Stage Strategy
The Dockerfile is split into two distinct stages:
1.  **Builder Stage**: Uses the full Python image to install dependencies and build wheels. This stage contains compilers and headers that are not needed at runtime.
2.  **Final Stage**: Uses `python:3.11-slim`. It only copies the pre-built dependencies and the application code.

---

## Security Audit
Performed a security scan using `docker scout` to validate the production readiness of the final image.

### **Scan Summary (`task2app:multi`)**
*   **Critical Vulnerabilities:** 0
*   **High Vulnerabilities:** 3
*   **Medium:** 8
*   **Low:** 37

![alt text](<../task-2-multistage/evidence/2.png>)

### Scout recommendations
**Change base image**
  The list displays new recommended tags in descending order, where the top results are rated as most suitable.

![alt text](<../task-2-multistage/evidence/3.png>)