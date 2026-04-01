FROM maven:3.9.8-eclipse-temurin-17 AS build
WORKDIR /app

COPY pom.xml .
RUN mvn -B -q -DskipTests dependency:go-offline

COPY src ./src
RUN mvn -B -q -DskipTests package

FROM eclipse-temurin:17-jre
WORKDIR /app

RUN addgroup --system app && adduser --system --ingroup app app

# Create logs directory for observability
RUN mkdir -p /app/logs && chown -R app:app /app/logs

COPY --from=build /app/target/demo-api-0.0.1-SNAPSHOT.jar /app/app.jar

USER app
EXPOSE 8080

# Health check for Kubernetes/Docker orchestration
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD java -cp /app/app.jar com.example.demo.HealthCheck || exit 1

# Start application with observability support
# Environment variables can be passed at runtime for Grafana Cloud configuration
ENTRYPOINT ["sh", "-c", "OTLP_TRACES_AUTH_HEADER=\"$OTLP_TRACES_AUTH_HEADER\"; OTLP_METRICS_AUTH_HEADER=\"$OTLP_METRICS_AUTH_HEADER\"; if [ -z \"$OTLP_TRACES_AUTH_HEADER\" ] && [ -n \"$TEMPO_USER\" ] && [ -n \"$GRAFANA_CLOUD_TOKEN\" ]; then OTLP_TRACES_AUTH_HEADER=\"Basic $(printf '%s' \"$TEMPO_USER:$GRAFANA_CLOUD_TOKEN\" | base64 | tr -d '\\n')\"; fi; if [ -z \"$OTLP_METRICS_AUTH_HEADER\" ] && [ -n \"$PROM_USER\" ] && [ -n \"$GRAFANA_CLOUD_TOKEN\" ]; then OTLP_METRICS_AUTH_HEADER=\"Basic $(printf '%s' \"$PROM_USER:$GRAFANA_CLOUD_TOKEN\" | base64 | tr -d '\\n')\"; fi; export OTLP_TRACES_AUTH_HEADER OTLP_METRICS_AUTH_HEADER; exec java -Dspring.profiles.active=prod,grafana -Dspring.application.name=demo-api -Djava.util.logging.config.file=/dev/null -jar /app/app.jar"]

