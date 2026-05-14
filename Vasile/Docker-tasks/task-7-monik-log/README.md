# Container Monitoring and Logging

This project demonstrates container monitoring and centralized logging using:

- Flask application
- Prometheus
- Grafana
- Loki
- Promtail

## Stack Components

| Service | Purpose |
|---|---|
| Flask App | Application |
| Prometheus | Metrics collection |
| Grafana | Dashboards |
| Loki | Log aggregation |
| Promtail | Log shipping |

## Access URLs

| Service | URL |
|---|---|
| App | http://localhost:5000 |
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3000 |

Grafana credentials:

admin / admin (then it forces you to set a different one)

## Start Stack

```bash
docker compose -f docker-compose.monitoring.yaml up -d --build
```

## Generate Logs

```bash
./scripts/test-logging.sh
```

## Generate Metrics

```bash
./scripts/test-metrics.sh
```

# Evidence

## Application Running

![Application](<../task-7-monik-log/evidence/1.png>)

---

## Script running (same output for both scripts)

![Script](<../task-7-monik-log/evidence/2.png>)

---

## Prometheus Targets

![Prometheus Targets](<../task-7-monik-log/evidence/3.png>)

---

## Grafana Data Sources

![Grafana Data Sources](<../task-7-monik-log/evidence/4.png>)

---

## Grafana Dashboards

### Size bytes count

![Size bytes count](<../task-7-monik-log/evidence/5.png>)

---

### Requests total

![Requests total](<../task-7-monik-log/evidence/6.png>)

---

## Containers running

![Containers](<../task-7-monik-log/evidence/7.png>)

---
