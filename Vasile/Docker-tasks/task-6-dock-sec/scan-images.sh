#!/bin/bash

mkdir -p scans

echo "Running Trivy scan..."

trivy image task-6-dock-sec-app > scans/trivy-report.txt

echo "Running Docker Scout scan..."

docker scout quickview task-6-dock-sec-app > scans/docker-scout-report.txt

echo "Scans completed."