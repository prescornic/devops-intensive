# Task 2 - Multi-Protocol Web Server Setup (Nginx + Python + WebSocket + Firewall)

## What this does
- Python aiohttp app listens on 127.0.0.1:5000
- Nginx is internet-facing:
  - Port 80 redirects to HTTPS
  - Port 443 terminates TLS and proxies to the app
  - /status returns JSON
  - /ws is a WebSocket echo endpoint
- Basic WAF blocks common SQL injection patterns and logs blocked requests
- iptables firewall allows only 22/80/443 inbound and blocks everything else

## Install requirements (Ubuntu)
```bash
sudo apt update
sudo apt install -y python3 python3-venv python3-pip nginx openssl iptables
