#!/bin/bash
echo "Creating Docker Networks..."

docker network create custom-bridge-net
echo -e "\n"

docker network create frontend-net
echo -e "\n"

docker network create backend-net
echo -e "\n"

echo "Networks created successfully:"
echo -e "\n"
docker network ls