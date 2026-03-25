#!/bin/bash

set -Eeuo pipefail

IMAGE_NAME="secure-app:1.0.0"
SCAN_DIR="scan-results"

mkdir -p "${SCAN_DIR}"

echo "Building secure image..."
docker build -f Dockerfile.secure -t "${IMAGE_NAME}" .

echo
echo "Running Trivy scan..."
if command -v trivy >/dev/null 2>&1; then
  trivy image --severity HIGH,CRITICAL "${IMAGE_NAME}" | tee "${SCAN_DIR}/trivy.txt"
else
  echo "Trivy not installed. Skipping Trivy scan." | tee "${SCAN_DIR}/trivy.txt"
fi

echo
echo "Running docker scan..."
if docker scan "${IMAGE_NAME}" >/dev/null 2>&1; then
  docker scan "${IMAGE_NAME}" | tee "${SCAN_DIR}/docker-scan.txt"
else
  echo "docker scan not available. Skipping docker scan." | tee "${SCAN_DIR}/docker-scan.txt"
fi

echo
echo "Running Grype..."
if command -v grype >/dev/null 2>&1; then
  grype "${IMAGE_NAME}" | tee "${SCAN_DIR}/grype.txt"
else
  echo "Grype not installed. Skipping Grype scan." | tee "${SCAN_DIR}/grype.txt"
fi

echo
echo "Scans completed. Results saved in ${SCAN_DIR}/"