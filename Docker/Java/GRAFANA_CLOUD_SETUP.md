# Grafana Cloud Observability Setup

This guide explains how to configure the demo-api application to send metrics, logs, and traces to Grafana Cloud.

## Prerequisites

- Grafana Cloud account (https://grafana.com/auth/sign-up/create-account)
- OpenTelemetry Collector (optional, for advanced setups)
- Docker (for containerized deployment)

## Grafana Cloud Components

The application integrates with three Grafana Cloud services:

1. **Prometheus** - Metrics collection via Micrometer
2. **Loki** - Centralized logging 
3. **Tempo** - Distributed tracing via OpenTelemetry

## Step 1: Create Grafana Cloud Instance

1. Navigate to https://grafana.com/auth/sign-up/create-account
2. Create a new stack (choose a region closest to you)
3. Once created, you'll have access to three service URLs and credentials
4. Note your **Grafana API Token** (used for authentication)

## Step 2: Find Your Service Credentials

In your Grafana Cloud instance, find the connection details:

1. **Prometheus Remote Write URL**: Usually `https://<prometheus-id>.grafana-cloud.com/api/prom/push`
   - Username: `<prometheus-id>` 
   - API Token: `<your-api-token>`

2. **Loki URL**: Usually `https://<logs-id>.grafana-cloud.com`
   - Username: `<logs-id>`
   - API Token: `<your-api-token>`

3. **Tempo URL**: Usually `https://<traces-id>.grafana-cloud.com/tempo`
   - Username: `<traces-id>`
   - API Token: `<your-api-token>`

4. **OTLP Endpoint**: `https://traces-<region>-<traces-id>.grafana-cloud.com/otlp`

## Step 3: Environment Variables

Set these environment variables when running the application:

```bash
# General
APP_ENV=prod
HOSTNAME=demo-api-instance-1

# Database
DB_URL=jdbc:postgresql://localhost:5432/mydb
DB_USER=user
DB_PASSWORD=password

# Grafana Cloud - Token (shared across all services)
GRAFANA_CLOUD_TOKEN=your-grafana-api-token

# Loki Configuration
LOKI_URL=https://<logs-id>.grafana-cloud.com
LOKI_USER=<logs-id>
LOKI_PASSWORD=${GRAFANA_CLOUD_TOKEN}

# OpenTelemetry OTLP Configuration (for traces and metrics)
OTEL_EXPORTER_OTLP_ENDPOINT=https://traces-<region>-<traces-id>.grafana-cloud.com:443/otlp
OTEL_EXPORTER_OTLP_HEADERS=Authorization=Bearer%20${GRAFANA_CLOUD_TOKEN}

# Spring Boot OpenTelemetry
MANAGEMENT_TRACING_SAMPLING_PROBABILITY=1.0
MANAGEMENT_OTLP_TRACING_ENDPOINT=https://traces-<region>-<traces-id>.grafana-cloud.com:443/otlp

# Spring Profile
SPRING_PROFILES_ACTIVE=prod,grafana
```

## Step 4: Running Locally with Docker Compose

Add a `.env` file in the Docker directory:

```bash
# Copy and fill in your actual credentials
DB_URL=jdbc:postgresql://db:5432/mydb
DB_USER=user
DB_PASSWORD=password
APP_ENV=dev
GRAFANA_CLOUD_TOKEN=your-token
LOKI_URL=https://<logs-id>.grafana-cloud.com
LOKI_USER=<logs-id>
OTEL_EXPORTER_OTLP_ENDPOINT=https://traces-<region>-<traces-id>.grafana-cloud.com:443/otlp
```

Update your `docker-compose.yaml`:

```yaml
services:
  backend:
    build: 
      context: ./Java
      dockerfile: Dockerfile
    image: java-backend:latest
    restart: always
    environment:
      MY_ARGUMENT: "PROD"
      DB_URL: ${DB_URL}
      DB_USER: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
      APP_ENV: ${APP_ENV:-dev}
      GRAFANA_CLOUD_TOKEN: ${GRAFANA_CLOUD_TOKEN}
      LOKI_URL: ${LOKI_URL}
      LOKI_USER: ${LOKI_USER}
      OTEL_EXPORTER_OTLP_ENDPOINT: ${OTEL_EXPORTER_OTLP_ENDPOINT}
      SPRING_PROFILES_ACTIVE: prod,grafana
    ports:
      - "8080:8080"
    depends_on:
      - db
    networks:
      - db-network
      - frontend-network
```

## Step 5: Building and Running

### Local development:

```bash
# Build the application
cd Docker/Java
mvn clean package

# Run with local settings (logs to console and file)
java -jar target/demo-api-0.0.1-SNAPSHOT.jar

# View logs at: ./logs/application.log
```

### With Docker Compose:

```bash
cd Docker
# Create .env file with credentials
echo "GRAFANA_CLOUD_TOKEN=your-token" > .env
echo "LOKI_URL=https://..." >> .env
echo "OTEL_EXPORTER_OTLP_ENDPOINT=..." >> .env

# Build and run
docker-compose build backend
docker-compose up backend
```

## Step 6: Verify Data is Being Sent

### Check Prometheus Metrics

1. Go to your Grafana instance → Prometheus
2. Query: `app_users_created_total`
3. You should see metrics being scraped

### Check Loki Logs

1. Go to your Grafana instance → Explore → Loki
2. Run query: `{app_name="demo-api"}`
3. You should see structured logs

### Check Tempo Traces

1. Go to your Grafana instance → Explore → Tempo
2. Search for service: `demo-api`
3. You should see distributed traces for each request

## Available Endpoints

### Application Endpoints
- `GET /api/users` - List all users
- `GET /api/users/{id}` - Get user by ID
- `POST /api/users` - Create new user

### Observability Endpoints (Actuator)
- `GET /actuator/health` - Application health
- `GET /actuator/health/live` - Liveness probe
- `GET /actuator/health/ready` - Readiness probe
- `GET /actuator/metrics` - Available metrics
- `GET /actuator/prometheus` - Prometheus formatted metrics
- `GET /actuator/info` - Application info

### Testing the Application

```bash
# Create a user
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}'

# List users
curl http://localhost:8080/api/users

# Check metrics
curl http://localhost:8080/actuator/prometheus

# Check health
curl http://localhost:8080/actuator/health
```

## Custom Metrics Collected

The application automatically collects:

1. **app.users.created.total** - Counter for new users created
2. **app.users.retrieved.total** - Counter for user retrieval requests
3. **app.api.errors.total** - Counter for API errors
4. **app.user.creation.duration** - Timer for creation operation (p50, p95, p99)
5. **app.user.retrieval.duration** - Timer for retrieval operation (p50, p95, p99)
6. **http.server.requests** - Standard HTTP metrics
7. **jvm.*** - JVM metrics (memory, GC, threads)
8. **process.*** - Process metrics (cpu, memory)

## Structured Logging

Logs are output in JSON format with correlation IDs for easy querying in Loki:

```json
{
  "@timestamp": "2024-03-25T10:30:45.123Z",
  "app_name": "demo-api",
  "environment": "prod",
  "service": "backend",
  "level": "INFO",
  "logger_name": "com.example.demo.UserController",
  "message": "Creating new user: John Doe",
  "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736",
  "span_id": "00f067aa0ba902b7"
}
```

## Troubleshooting

### Logs not appearing in Loki

1. Verify `LOKI_URL` is correct (should end with proper path)
2. Check `LOKI_USER` and `LOKI_PASSWORD` credentials
3. Tail application logs: `tail -f logs/application.log`
4. Check for certificate issues if using HTTPS

### Traces not appearing in Tempo

1. Verify `OTEL_EXPORTER_OTLP_ENDPOINT` is accessible
2. Check Bearer token is correct
3. Enable debug logs: `LOGGING_LEVEL_IO_OPENTELEMETRY=DEBUG`
4. Test OTLP endpoint: `curl -v https://your-tempo-endpoint`

### Metrics showing but not in Prometheus

1. Access `/actuator/prometheus` endpoint directly
2. Verify Prometheus scrape config in Grafana Cloud
3. Check if time is synchronized on your machine

## Docker Build with Observability

The Dockerfile will automatically include all observability capabilities. No special build flags are needed:

```bash
docker build -t java-backend:latest -f Docker/Java/Dockerfile Docker/Java
docker run -e GRAFANA_CLOUD_TOKEN=your-token java-backend:latest
```

## Next Steps

1. **Create Dashboards** in Grafana to visualize:
   - User creation rates
   - API response times
   - Error rates by endpoint
   - JVM memory usage

2. **Set Up Alerts** for:
   - High error rates
   - Slow response times
   - Memory threshold exceeded

3. **Configure Sampling** (in production):
   - Reduce trace sampling to 10% if high volume
   - Use `MANAGEMENT_TRACING_SAMPLING_PROBABILITY=0.1`

## References

- [Grafana Cloud Documentation](https://grafana.com/docs/grafana-cloud/)
- [OpenTelemetry Java](https://opentelemetry.io/docs/instrumentation/java/)
- [Micrometer Documentation](https://micrometer.io/)
- [Logback Configuration](https://logback.qos.ch/manual/configuration.html)
