#!/usr/bin/env bash
set -euo pipefail

CERT_DIR_LOCAL="$(pwd)/certs"
CERT_DIR_NGINX="/etc/nginx/ssl/multi-proto"

mkdir -p "$CERT_DIR_LOCAL"
sudo mkdir -p "$CERT_DIR_NGINX"

openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout "$CERT_DIR_LOCAL/selfsigned.key" \
  -out "$CERT_DIR_LOCAL/selfsigned.crt" \
  -days 365 \
  -subj "/C=RO/ST=Bucharest/L=Bucharest/O=DevOps/CN=localhost"

sudo cp "$CERT_DIR_LOCAL/selfsigned.crt" "$CERT_DIR_NGINX/selfsigned.crt"
sudo cp "$CERT_DIR_LOCAL/selfsigned.key" "$CERT_DIR_NGINX/selfsigned.key"
sudo chmod 600 "$CERT_DIR_NGINX/selfsigned.key"
sudo chmod 644 "$CERT_DIR_NGINX/selfsigned.crt"

echo "SSL cert installed to: $CERT_DIR_NGINX"
