#!/bin/bash

set -Eeuo pipefail

LOG_FILE="run.log"

exec > >(tee -a "${LOG_FILE}") 2>&1

print_header() {
  echo
  echo "=================================================="
  echo "$1"
  echo "=================================================="
}

check_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "Error: Docker is not installed."
    exit 1
  fi

  if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker daemon is not running."
    exit 1
  fi
}

get_container_id() {
  local service="$1"
  docker compose ps -q "$service"
}

wait_for_service() {
  local service="$1"

  echo "Waiting for service '${service}' to be healthy..."

  for i in {1..30}; do
    local container_id
    container_id="$(get_container_id "$service")"

    if [[ -z "${container_id}" ]]; then
      echo "Service '${service}' has no container yet. Retrying..."
      sleep 2
      continue
    fi

    local health_status
    health_status="$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "${container_id}" 2>/dev/null || echo "unknown")"

    if [[ "${health_status}" == "healthy" || "${health_status}" == "running" ]]; then
      echo "Service '${service}' is ${health_status}."
      return 0
    fi

    echo "Current status for '${service}': ${health_status}"
    sleep 2
  done

  echo "ERROR: Service '${service}' did not become healthy in time."
  docker compose ps
  docker compose logs "${service}" || true
  exit 1
}

print_header "Starting Task 5 Full Stack Workflow"

check_docker

print_header "Starting stack"
docker compose down -v >/dev/null 2>&1 || true
docker compose up -d --build

print_header "Waiting for services"
wait_for_service postgres
wait_for_service redis
wait_for_service backend
wait_for_service frontend
wait_for_service nginx

print_header "Running tests"

echo "Test 1: docker compose ps"
docker compose ps

echo
echo "Test 2: Frontend"
curl -s http://localhost/ | head -n 10

echo
echo "Test 3: Backend health"
curl -s http://localhost/api/health
echo

echo
echo "Test 4: Users endpoint"
curl -s http://localhost/api/users
echo

echo
echo "Test 5: Redis cache"
curl -s http://localhost/api/cache
echo
curl -s http://localhost/api/cache
echo

print_header "Scaling backend"

docker compose up -d --scale backend=3
docker compose ps

print_header "Workflow completed successfully"
echo "All output has been saved to ${LOG_FILE}"

echo
read -r -p "Do you want to clean up (containers + volumes)? (y/n): " answer

if [[ "${answer}" =~ ^[Yy]$ ]]; then
  docker compose down -v
  echo "Cleanup complete."
else
  echo "Cleanup skipped."
fi