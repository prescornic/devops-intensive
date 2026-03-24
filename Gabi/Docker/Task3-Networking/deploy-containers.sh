#!/bin/bash
set -e

echo "Building backend image..."
docker build -t network-backend:1.0.0 ./backend

echo "Deploying custom bridge network demo containers..."
docker run -d --name bridge-a --network custom-bridge-net alpine:3.20 sleep 3600
docker run -d --name bridge-b --network custom-bridge-net alpine:3.20 sleep 3600

echo "Deploying isolated network demo containers..."
docker run -d --name isolated-a --network isolated-net-a alpine:3.20 sleep 3600
docker run -d --name isolated-b --network isolated-net-b alpine:3.20 sleep 3600

echo "Deploying multi-network bridge container..."
docker run -d --name network-bridge --network frontend-net alpine:3.20 sleep 3600
docker network connect backend-net network-bridge

echo "Deploying frontend container..."
docker run -d --name frontend --network frontend-net nginx:alpine

echo "Deploying backend container..."
docker run -d --name backend --network frontend-net -e DB_HOST=database network-backend:1.0.0
docker network connect backend-net backend

echo "Deploying database container..."
docker run -d \
  --name database \
  --network backend-net \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=appdb \
  postgres:16-alpine

echo "Deploying none network demo container..."
docker run -d --name none-demo --network none alpine:3.20 sleep 3600

echo "Deploying host network demo container..."
docker run -d --name host-demo --network host nginx:alpine || echo "Host network may be limited on Docker Desktop/macOS"

echo
echo "Deployment complete."
docker ps