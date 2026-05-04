#!/bin/bash
echo "Deploying Containers..."
echo -e "\n"

echo "Deploying containers A and B on custom-bridge-net"
docker run -d --name container-a --network custom-bridge-net alpine sleep 3600
docker run -d --name container-b --network custom-bridge-net alpine sleep 3600

echo "Deploying host-app on Host Network"
docker run -d --name host-app --network host nginx:alpine

echo "Deploying isolated-app on None Network"
docker run -d --name isolated-app --network none alpine sleep 3600

echo "Deploying frontend on frontend-net"
docker run -d --name frontend --network frontend-net alpine sleep 3600

echo "Deploying backend on backend-net and frontend-net"
docker run -d --name backend --network backend-net alpine sleep 3600
docker network connect frontend-net backend

echo "Deploying database on backend-net"
docker run -d --name database --network backend-net alpine -e POSTGRES_PASSWORD=secret -e POSTGRES_DB=appdb postgres:16-alpine sleep 3600

echo "Deployment complete."