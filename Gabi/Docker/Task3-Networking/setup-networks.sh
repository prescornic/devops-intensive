#!/bin/bash
set -e

echo "Creating Docker networks..."

docker network create custom-bridge-net || true
docker network create frontend-net || true
docker network create backend-net || true
docker network create isolated-net-a || true
docker network create isolated-net-b || true

echo
echo "Created networks:"
docker network ls