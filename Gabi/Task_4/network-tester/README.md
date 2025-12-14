# Task 4 – Network Service Tester

## Overview
This project is a Python-based network testing tool that checks the availability
and health of multiple network services concurrently.

It supports:
- HTTP and HTTPS endpoint testing
- DNS resolution testing
- SSL certificate validation and expiration alerts
- Config-driven testing using JSON
- Concurrent execution for faster results
- JSON reporting
- Optional HTML dashboard generation
- Color-coded console output

This tool simulates what a DevOps or SRE engineer would build to monitor
external services and dependencies.

---

## Folder Structure

network-tester/
├── network_tester.py # Main testing script
├── generate_report.py # Optional HTML report generator
├── config.json # Endpoint configuration
├── requirements.txt # Python dependencies
├── README.md # Documentation
├── .gitignore
├── reports/ # Generated JSON / HTML reports (ignored by Git)
└── templates/ # (Optional) HTML templates


---

## Supported Tests

### HTTP / HTTPS
For each HTTP or HTTPS endpoint, the tool collects:
- Connection success or failure
- HTTP status code
- Response time (milliseconds)

For HTTPS endpoints only:
- SSL certificate validity
- Certificate expiration date
- Alert if certificate expires within 30 days

---

### DNS
For DNS endpoints, the tool checks:
- DNS resolution success or failure
- DNS lookup time
- Resolved IP addresses

---

## Configuration (`config.json`)

All endpoints are defined in a JSON file.

Example:

```json
{
  "timeout_seconds": 5,
  "retries": 2,
  "concurrency": 10,
  "ssl_expiry_warning_days": 30,
  "endpoints": [
    {"url": "https://example.com", "type": "https", "expected_status": 200},
    {"url": "http://example.com", "type": "http"},
    {"host": "example.com", "type": "dns"}
  ]
}
```

---

##  Installation

### Requirements
Python 3.10+

##Setup
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

##Usage

###Run network tests
python3 network_tester.py config.json

Example console output:

Network Service Test Report - 2025-12-10 14:30:22
================================================
✓ https://example.com - 200 OK (245ms) - SSL until 2026-03-15
✗ http://api.example.com/health - Connection timeout
✓ example.com - DNS resolved (12ms)

Summary: 2 passed, 1 failed

