#!/bin/bash

echo "Building Single-Stage Image..."
docker build -t task2app:single -f Dockerfile.single .
echo -e "\n"

echo "Building Multi-Stage Image..."
docker build -t task2app:multi -f Dockerfile .
echo -e "\n"

echo -e "--- IMAGE SIZE COMPARISON ---"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep task2app
echo -e "\n"