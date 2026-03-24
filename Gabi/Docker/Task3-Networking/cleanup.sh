#!/bin/bash
set +e

echo "Stopping and removing containers..."
docker rm -f bridge-a bridge-b isolated-a isolated-b network-bridge frontend backend database none-demo host-demo

echo "Removing networks..."
docker network rm custom-bridge-net frontend-net backend-net isolated-net-a isolated-net-b

echo "Removing backend image..."
docker rmi network-backend:1.0.0

echo "Cleanup complete."