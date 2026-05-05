#!/bin/bash
echo "Cleaning up containers and networks..."
docker rm -f container-a container-b host-app isolated-app frontend backend database
docker network rm custom-bridge-net frontend-net backend-net