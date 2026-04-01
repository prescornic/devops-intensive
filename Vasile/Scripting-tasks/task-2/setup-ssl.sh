#!/bin/bash

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CERT_DIR="$PROJECT_ROOT/certs"

mkdir -p "$CERT_DIR"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$CERT_DIR/server.key" \
  -out "$CERT_DIR/server.crt" \
  -subj "/C=MD/ST=Chisinau/L=Chisinau/O=DevOps/OU=AndreisTraining/CN=localhost"

sed "s|PROJECT_PATH_PLACEHOLDER|$PROJECT_ROOT|g" nginx.conf.template > nginx.conf

echo "SSL Certificate generated successfully!"
echo "Certificate: $CERT_DIR/server.crt"
echo "Key: $CERT_DIR/server.key"