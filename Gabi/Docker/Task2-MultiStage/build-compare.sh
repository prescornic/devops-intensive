#!/bin/bash
set -e

echo "Building single-stage image..."
docker build -f Dockerfile.single -t myapp-single:1.0.0 .

echo
echo "Building multi-stage image..."
docker build -f Dockerfile -t myapp-multi:1.0.0 .

echo
echo "Comparing image sizes..."
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep myapp