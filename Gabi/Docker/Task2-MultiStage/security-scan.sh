#!/bin/bash
set -e

echo "Scanning single-stage image..."
trivy image myapp-single:1.0.0

echo
echo "Scanning multi-stage image..."
trivy image myapp-multi:1.0.0