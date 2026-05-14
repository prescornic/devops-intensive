from flask import Flask
from prometheus_client import Counter, Histogram, generate_latest
import time
import logging
import json

app = Flask(__name__)

logging.basicConfig(level=logging.INFO)

REQUEST_COUNT = Counter(
    "app_requests_total",
    "Total App Requests"
)

REQUEST_LATENCY = Histogram(
    "app_request_duration_seconds",
    "Request latency"
)

@app.route("/")
def home():
    start = time.time()

    REQUEST_COUNT.inc()

    log = {
        "level": "INFO",
        "message": "Home endpoint accessed"
    }

    print(json.dumps(log))

    time.sleep(0.2)

    REQUEST_LATENCY.observe(time.time() - start)

    return {
        "message": "Monitoring app running"
    }

@app.route("/health")
def health():
    return {
        "status": "healthy"
    }

@app.route("/metrics")
def metrics():
    return generate_latest()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
