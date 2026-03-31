# Simple Python Web Server with Nginx SSL Proxy

This project implements a Flask web server with HTTP and WebSocket support, secured via Nginx and a self-signed SSL certificate.

## Prerequisites
- Python 3.x
- Nginx
- OpenSSL

## Setup Instructions

1. **Install Python dependencies:**
   `python3 -m pip install flask flask-sock`

2. **Generate SSL & Nginx Configuration:**
   Run the following script to generate certificates and configure Nginx paths automatically:
   `chmod +x setup-ssl.sh && ./setup-ssl.sh`

3. **Configure Firewall:**
   `chmod +x setup-firewall.sh && ./setup-firewall.sh`

4. **Start the Flask Application:**
   `python3 app.py`

5. **Start Nginx:**
   `sudo nginx -c $(pwd)/nginx.conf`

## Endpoints
- **HTTP Status:** `http://localhost/status` (Redirects to HTTPS)
- **HTTPS Status:** `https://localhost/status`
- **WebSocket:** `wss://localhost/ws`

## Portability & Path Handling
To ensure this project works on any machine (regardless of the absolute path or spaces in folder names), the setup uses an `nginx.conf.template`. 

The `setup-ssl.sh` script automatically:
1. Detects the current project root using `PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"`.
2. Injects this path into the final `nginx.conf`.
3. Wraps paths in double quotes to handle system environments with spaces in the directory tree.

## Prerequisites (Mac/Homebrew)
If Nginx is not installed, you can install it via Homebrew:
```bash
brew install nginx
```

### Test WAF (SQL Injection Blocking)
Try to "hack" the server by sending an SQL injection pattern in the URL:
`curl -k "https://localhost/status?id=1' OR '1'='1"`

**Expected Result:** You should receive a `403 Forbidden` response instead of your JSON status.