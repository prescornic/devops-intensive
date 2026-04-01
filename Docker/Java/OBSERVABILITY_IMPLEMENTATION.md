# Grafana Cloud Observability Implementation Summary

This document summarizes the observability implementation for publishing metrics, logs, and traces to Grafana Cloud.

## Implementation Overview

The demo-api application now includes complete observability instrumentation across three pillars:

### 1. **Traces** (Distributed Tracing)
- **Technology**: OpenTelemetry API + SDK + OTLP Exporter
- **Destination**: Grafana Cloud Tempo
- **Protocol**: gRPC OTLP
- **Coverage**: 
  - All HTTP requests (Spring WebMVC interceptor)
  - Database queries (JDBC instrumentation)
  - Manual instrumentation in controllers

### 2. **Metrics** (Performance & Usage Monitoring)
- **Technology**: Micrometer + Prometheus exporter
- **Destination**: Grafana Cloud Prometheus via remote write
- **Endpoint**: `/actuator/prometheus` (scraped automatically)
- **Coverage**:
  - JVM metrics (memory, garbage collection, threads)
  - HTTP metrics (requests, latency, errors)
  - Custom business metrics (user creation, retrieval, errors)

### 3. **Logs** (Event Logging)
- **Technology**: Logback + Logstash encoder + Loki4j
- **Destination**: Grafana Cloud Loki (JSON log format)
- **Output Formats**: Console (structured JSON) + File (rolling)
- **Correlation**: Trace IDs embedded in logs for correlation

---

## Files Modified/Created

### Maven Dependencies (pom.xml)
Added observability stack:
- `spring-boot-starter-actuator` - Metrics endpoints
- `micrometer-registry-prometheus` - Prometheus metrics
- `opentelemetry-api`, `opentelemetry-sdk` - Tracing
- `opentelemetry-exporter-otlp` - OTLP export
- `logstash-logback-encoder` - Structured JSON logging
- `loki-logback-appender` - Loki integration
- OpenTelemetry instrumentation libraries for Spring WebMVC and JDBC

### Spring Configuration (application.yml)
```yaml
✅ Actuator endpoints enabled
✅ Metrics collection and tags
✅ Trace sampling configuration
✅ OTLP endpoint setup
✅ Logging configuration
```

### Logging Configuration (logback-spring.xml)
```
✅ Console appender with JSON formatting
✅ File appender with rolling policy
✅ Async appender for performance
✅ Logback profiles for dev/prod
✅ Loki integration
```

### Custom Metrics (metrics/ApplicationMetrics.java)
- **Counters**:
  - `app.users.created.total` - New user creations
  - `app.users.retrieved.total` - User retrieval requests
  - `app.api.errors.total` - API errors
- **Timers**:
  - `app.user.creation.duration` - Duration of user creation (p50, p95, p99)
  - `app.user.retrieval.duration` - Duration of user retrieval (p50, p95, p99)

### OpenTelemetry Configuration (config/OpenTelemetryConfig.java)
- OTLP exporter setup
- Resource configuration with service metadata
- Trace provider initialization
- HTTP gRPC transport

### Global Exception Handler (config/GlobalExceptionHandler.java)
- Centralized error logging
- Metrics recording for errors
- Structured error responses

### Enhanced UserController (UserController.java)
- Integrated custom metrics
- Detailed logging with log levels
- Error tracking
- Structured logs with trace context

### Dockerfile Updates
- Log directory creation
- Health check configuration
- Spring profile activation for observability
- Proper signal handling

### Docker Compose Template (docker-compose.grafana.yml)
- Environment variables for Grafana Cloud
- Volume mounts for logs
- Health checks
- Network configuration

### Documentation
- **GRAFANA_CLOUD_SETUP.md** - Complete setup guide
- **.env.grafana.example** - Environment template
- **OBSERVABILITY_IMPLEMENTATION.md** - This file

---

## Auto-Instrumented Components

The application automatically instruments:

### HTTP Server
- Request/response metrics
- Latency percentiles
- Error rates by endpoint
- Request tracing with trace IDs

### Database (JDBC)
- Query execution time
- Connection pool metrics
- Error tracking
- SQL instrumentation (when enabled)

### JVM Runtime
- Memory usage (heap, non-heap)
- Garbage collection
- Thread count and state
- CPU utilization

---

## Metrics Available

### System Metrics
```
jvm.memory.used
jvm.memory.max
jvm.gc.* (garbage collection)
jvm.threads.* (thread statistics)
process.cpu.usage
process.memory.usage
system.cpu.usage
```

### HTTP Metrics
```
http.server.requests (with tags: method, uri, status)
http.server.requests.duration.seconds (histogram)
```

### Custom Business Metrics
```
app.users.created.total
app.users.retrieved.total
app.api.errors.total
app.user.creation.duration
app.user.retrieval.duration
```

### Spring Application Metrics
```
spring.cloud.bus.* (if using bus)
spring.data.jpa.* (if using JPA)
```

---

## Tracing Integration

### Trace Context
- Trace IDs and Span IDs automatically generated
- Propagated through HTTP headers (W3C Trace Context)
- Included in logs for correlation
- Sent to Grafana Cloud Tempo

### Sampling
- Configurable via `MANAGEMENT_TRACING_SAMPLING_PROBABILITY`
- Default: 100% (send all traces)
- Recommended for production: 10-20%

### Spans Captured
- HTTP server spans (all endpoints)
- JDBC database query spans
- Custom spans from business logic
- Nested spans showing request hierarchy

---

## Logging Features

### Structured Logging
All logs output as JSON with fields:
```json
{
  "@timestamp": "2024-03-25T10:30:45.123Z",
  "app_name": "demo-api",
  "environment": "prod",
  "level": "INFO",
  "logger": "com.example.demo.UserController",
  "message": "...",
  "trace_id": "...",
  "span_id": "..."
}
```

### Log Levels
- `DEBUG` - Development environments (com.example package)
- `INFO` - Default level (app logs)
- `WARN` - Framework logs (Spring, Hibernate, PostgreSQL)
- `ERROR` - Exception logging with full stack traces

### Log Rotation
- Max file size: 100MB
- Retention: 7 days
- Max total size: 1GB

---

## Environment Variables

### Required for Grafana Cloud
```
GRAFANA_CLOUD_TOKEN          # Shared authentication token
LOKI_URL                      # Loki endpoint URL
LOKI_USER                     # Loki credentials
OTEL_EXPORTER_OTLP_ENDPOINT  # Tempo/Traces endpoint
```

### Database
```
DB_URL                        # PostgreSQL connection
DB_USER                       # Database user
DB_PASSWORD                   # Database password
```

### Application
```
APP_ENV                       # Environment (dev/prod)
SPRING_PROFILES_ACTIVE       # Spring profiles
```

---

## Deployment Instructions

### Local Development
```bash
cd Docker/Java
mvn clean package
java -jar target/demo-api-0.0.1-SNAPSHOT.jar
```

### Container with Grafana Cloud
```bash
cp Docker/.env.grafana.example Docker/.env
# Edit .env with your Grafana Cloud credentials
docker-compose -f Docker/docker-compose.grafana.yml up
```

### Kubernetes with Helm
See `K8S/helm/backend/values.yaml` for Kubernetes observability configuration

---

## Monitoring Dashboard Setup

### Recommended Dashboards to Create

1. **User Operations Dashboard**
   - User creation rate (query: `rate(app_users_created_total[5m])`)
   - User retrieval rate (query: `rate(app_users_retrieved_total[5m])`)
   - Error rate (query: `rate(app_api_errors_total[5m])`)

2. **Performance Dashboard**
   - P95 user creation latency
   - P99 user retrieval latency
   - HTTP request latency by endpoint

3. **System Health Dashboard**
   - JVM heap usage
   - Garbage collection time
   - Thread count
   - Database connection count

4. **Logs Dashboard**
   - Query logs by service: `{app_name="demo-api"}`
   - Filter by level: `{app_name="demo-api"} | json | level="ERROR"`
   - Trace correlation from traces to logs

---

## Testing Observability

### Generate Metrics
```bash
# Create users to generate metrics
for i in {1..10}; do
  curl -X POST http://localhost:8080/api/users \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"User $i\",\"email\":\"user$i@example.com\"}"
done

# View metrics
curl http://localhost:8080/actuator/prometheus | grep app_users
```

### View Logs
```bash
# Local file logs
tail -f logs/application.log

# JSON formatted output
tail -f logs/application.log | jq '.'
```

### Verify Traces in Grafana Cloud
1. Navigate to Grafana Cloud → Explore → Tempo
2. Search for service: `demo-api`
3. Filter by operation: `POST /api/users`
4. View trace details with spans, timing, and logs

---

## Production Best Practices

1. **Trace Sampling**: Reduce to 10-20% in production
2. **Log Level**: Set root level to INFO in production
3. **Metrics**: Enable resource limits for Prometheus scraping
4. **Security**: Keep API tokens in GitHub Secrets or Key Vault
5. **Alerting**: Set up alerts for:
   - High error rates (> 1%)
   - High latency (P95 > 500ms)
   - Low success rates (< 99%)
   - JVM memory pressure (> 80%)

---

## Troubleshooting

### Metrics not appearing
- Check `/actuator/prometheus` returns data
- Verify Grafana Cloud Prometheus data source
- Monitor token expiration

### Logs not in Loki
- Verify LOKI_URL and credentials
- Check application.log file exists and has content
- Tail logs to see JSON structure

### Traces not in Tempo
- Verify OTEL_EXPORTER_OTLP_ENDPOINT
- Check Bearer token in headers
- Verify sampling probability > 0

### Performance Issues
- Reduce trace sampling
- Use async appenders for logging
- Monitor OpenTelemetry SDK metrics

---

## Next Steps

1. ✅ Deploy application with observability enabled
2. ✅ Verify data is flowing to Grafana Cloud
3. ✅ Create dashboards for visualization
4. ✅ Set up alerting rules
5. ✅ Test log correlation and trace context
6. ✅ Document SLOs (Service Level Objectives)
7. ✅ Train team on observability workflows

---

## References

- [Grafana Cloud Documentation](https://grafana.com/docs/grafana-cloud/)
- [OpenTelemetry Java](https://opentelemetry.io/docs/instrumentation/java/)
- [Micrometer Documentation](https://micrometer.io/)
- [Spring Boot Actuator](https://spring.io/guides/gs/actuator-service/)
- [Logback Documentation](https://logback.qos.ch/)
