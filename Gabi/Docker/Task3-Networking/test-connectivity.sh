#!/bin/bash
set -e

echo "=== Test 1: bridge network DNS resolution ==="
docker exec bridge-a ping -c 2 bridge-b || true

echo
echo "=== Test 2: bridge network name resolution using nslookup ==="
docker exec bridge-a sh -c "apk add --no-cache bind-tools >/dev/null 2>&1 && nslookup bridge-b" || true

echo
echo "=== Test 3: isolated networks should NOT communicate ==="
docker exec isolated-a ping -c 2 isolated-b && echo "Unexpected success" || echo "Expected failure: isolated-a cannot reach isolated-b"

echo
echo "=== Test 4: multi-network bridge can reach frontend and backend side names ==="
docker exec network-bridge sh -c "apk add --no-cache bind-tools iputils >/dev/null 2>&1 && ping -c 2 backend" || true

echo
echo "=== Test 5: frontend can reach backend ==="
docker exec frontend sh -c "apk add --no-cache curl >/dev/null 2>&1 && curl -s http://backend:5000/health" || true

echo
echo "=== Test 6: frontend should NOT reach database directly ==="
docker exec frontend sh -c "apk add --no-cache bind-tools >/dev/null 2>&1 && nslookup database" \
  && echo "Unexpected success: frontend resolved database" \
  || echo "Expected failure: frontend cannot resolve database"

echo
echo "=== Test 7: backend should reach database by name ==="
docker exec backend ping -c 2 database || true

echo
echo "=== Test 8: none network should be isolated ==="
docker exec none-demo ping -c 2 8.8.8.8 && echo "Unexpected success" || echo "Expected failure: none-demo has no network access"

echo
echo "=== Test 9: inspect backend networks ==="
docker inspect backend --format '{{json .NetworkSettings.Networks}}'