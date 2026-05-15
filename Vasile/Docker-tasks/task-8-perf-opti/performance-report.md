# Performance Report

## Project Overview

This project demonstrates container performance optimization techniques using Flask applications running in three environments:

1. Native Flask application
2. Dockerized unoptimized container
3. Dockerized optimized container

The goal was to reduce image size, improve security, optimize runtime performance, and benchmark resource utilization under load.

---

# Image Size Comparison

| Image | Disk Usage | Content Size |
|---|---|---|
| Native App Image | 1.63GB | 406MB |
| Docker Unoptimized | 947MB | 245MB |
| Docker Optimized | 88.5MB | 20.6MB |

## Result

- Optimized image reduced from **947MB → 88.5MB**
- Total reduction: **~90.6%**

## Optimization Techniques Used

- Switched from Ubuntu → Alpine
- Multi-stage builds
- Removed unnecessary packages
- Reduced image layers
- Used minimal Python base image
- Excluded build dependencies from final image

---

# Build Optimization

## BuildKit Features Used

- Cache mounts for pip dependencies
- Multi-stage builds
- Optimized layer caching

## Build Improvements

| Technique | Benefit |
|---|---|
| BuildKit cache mounts | Faster rebuilds |
| Multi-stage builds | Smaller final image |
| Alpine base image | Reduced download size |
| Layer optimization | Improved caching efficiency |

---

# Runtime Performance Benchmark

## Native Flask Application

| Metric | Value |
|---|---|
| Requests/sec | 1521.41 |
| Mean latency | 32.86ms |
| p50 latency | 30ms |
| p95 latency | 46ms |
| p99 latency | 70ms |
| Max latency | 83ms |

### Notes

- Fastest runtime performance
- No container overhead
- Uses Flask development server
- Not production ready

---

## Docker Unoptimized Container

| Metric | Value |
|---|---|
| Requests/sec | 1202.25 |
| Mean latency | 41.59ms |
| p50 latency | 34ms |
| p95 latency | 63ms |
| p99 latency | 67ms |
| Max latency | 73ms |

### Notes

- Moderate performance degradation from containerization
- Large Ubuntu-based image
- Includes unnecessary packages and tooling
- Uses Flask development server

---

## Docker Optimized Container

| Metric | Value |
|---|---|
| Requests/sec | 77.69 |
| Mean latency | 643.54ms |
| p50 latency | 644ms |
| p95 latency | 659ms |
| p99 latency | 665ms |
| Max latency | 680ms |

### Notes

- Uses Gunicorn production server
- Highly optimized image size
- Lower memory limit applied (512MB)
- Significant resource constraints impacted throughput

---

# Runtime Comparison Summary

| Environment | Requests/sec | p95 Latency |
|---|---|---|
| Native Flask | 1521.41 | 46ms |
| Docker Unoptimized | 1202.25 | 63ms |
| Docker Optimized | 77.69 | 659ms |

---

# Resource Usage Under Load

| Container | CPU Usage | Memory Usage | Memory Limit | PIDs |
|---|---|---|---|---|
| Native App | 0.02% | 22.7MiB | 7.75GiB | 1 |
| Unoptimized Container | 0.02% | 22.3MiB | 1GiB | 1 |
| Optimized Container | 0.01% | 33.11MiB | 512MiB | 2 |

---

# Network Usage

| Container | Network I/O |
|---|---|
| Native App | 555kB / 614kB |
| Unoptimized Container | 2.76MB / 3.06MB |
| Optimized Container | 2.25MB / 2.96MB |

---

# Key Findings

## 1. Image Optimization Success

The optimized Alpine-based image achieved over 90% size reduction compared to the unoptimized Ubuntu container.

### Benefits

- Faster image pulls
- Reduced storage usage
- Smaller attack surface
- Faster deployments

---

## 2. Runtime Trade-offs

While the optimized image dramatically improved image efficiency, the applied resource limits and Gunicorn configuration significantly reduced throughput.

### Trade-off Summary

| Optimization | Benefit | Cost |
|---|---|---|
| Alpine image | Smaller size | Possible compatibility issues |
| Gunicorn | Production readiness | Higher latency with default workers |
| Memory limits | Controlled resource usage | Reduced throughput |
| Multi-stage build | Cleaner image | Slightly more complex build |

---

## 3. Container Overhead Analysis

Containerization introduced measurable overhead compared to native execution.

### Comparison

| Environment | Relative Performance |
|---|---|
| Native Flask | Baseline |
| Unoptimized Docker | ~21% slower |
| Optimized Docker | Significantly constrained by limits |

---
