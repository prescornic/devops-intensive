#!/bin/bash

set -Eeuo pipefail

LOG_FILE="run.log"
COMPOSE_FILE="docker-compose.secure.yaml"
SERVICE_NAME="secure-app"

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

check_required_files() {
  local files=(
    "./Dockerfile.secure"
    "./${COMPOSE_FILE}"
    "./scan-images.sh"
    "./secrets-setup.sh"
    "./generate-security-docs.sh"
    "./app/app.py"
    "./app/requirements.txt"
  )

  for file in "${files[@]}"; do
    if [[ ! -f "${file}" ]]; then
      echo "Error: Required file not found: ${file}"
      exit 1
    fi
  done

  chmod +x ./scan-images.sh ./secrets-setup.sh ./generate-security-docs.sh
}

get_container_id() {
  docker compose -f "${COMPOSE_FILE}" ps -q "${SERVICE_NAME}"
}

wait_for_service() {
  echo "Waiting for service '${SERVICE_NAME}' to be healthy..."

  for i in {1..30}; do
    local container_id
    container_id="$(get_container_id)"

    if [[ -z "${container_id}" ]]; then
      echo "Container for service '${SERVICE_NAME}' not created yet. Retrying..."
      sleep 2
      continue
    fi

    local health_status
    health_status="$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "${container_id}" 2>/dev/null || echo "unknown")"

    if [[ "${health_status}" == "healthy" || "${health_status}" == "running" ]]; then
      echo "Service '${SERVICE_NAME}' is ${health_status}."
      return 0
    fi

    echo "Current status: ${health_status}"
    sleep 2
  done

  echo "Error: Service '${SERVICE_NAME}' did not become healthy in time."
  docker compose -f "${COMPOSE_FILE}" ps
  docker compose -f "${COMPOSE_FILE}" logs "${SERVICE_NAME}" || true
  exit 1
}

setup() {
  print_header "Setting up secrets"
  ./secrets-setup.sh

  print_header "Building and starting secure container"
  docker compose -f "${COMPOSE_FILE}" down >/dev/null 2>&1 || true
  docker compose -f "${COMPOSE_FILE}" up -d --build
}

test_all() {
  print_header "Waiting for service health"
  wait_for_service

  print_header "Running runtime tests"

  echo "Test 1: docker compose ps"
  docker compose -f "${COMPOSE_FILE}" ps

  echo
  echo "Test 2: Health endpoint"
  curl -s http://localhost:8080/health
  echo

  echo
  echo "Test 3: Secret file endpoint"
  curl -s http://localhost:8080/secret-check
  echo

  print_header "Running image scans"
  ./scan-images.sh

  print_header "Generating security documentation"
  ./generate-security-docs.sh

  print_header "Generated files"
  ls -lh security-report.md security-checklist.md
}

cleanup() {
  print_header "Cleaning up secure stack"
  docker compose -f "${COMPOSE_FILE}" down
  echo "Containers stopped."
}

cleanup_all() {
  print_header "Cleaning up secure stack and generated artifacts"
  docker compose -f "${COMPOSE_FILE}" down
  echo "Containers stopped."

  echo "Keeping scan-results/, run.log, security-report.md, and security-checklist.md for evidence."
  echo "Secrets file is kept locally for repeat runs."
}

all() {
  print_header "Starting full Task 6 workflow"
  setup
  test_all

  print_header "Workflow completed successfully"
  echo "All output has been saved to ${LOG_FILE}"

  echo
  read -r -p "Do you want to stop containers now? (y/n): " answer
  case "${answer}" in
    y|Y|yes|YES)
      cleanup
      ;;
    *)
      echo "Cleanup skipped."
      ;;
  esac
}

usage() {
  cat <<EOF
Usage:
  ./run-all.sh setup
  ./run-all.sh test
  ./run-all.sh cleanup
  ./run-all.sh cleanup-all
  ./run-all.sh all

Commands:
  setup        Initialize secrets and start the secure stack
  test         Run endpoint tests, scans, and generate security docs
  cleanup      Stop the secure stack
  cleanup-all  Stop the secure stack (artifacts are intentionally kept)
  all          Run setup + tests + optional cleanup

Generated outputs:
  - run.log
  - scan-results/
  - security-report.md
  - security-checklist.md
EOF
}

main() {
  ACTION="${1:-}"

  check_docker
  check_required_files

  case "${ACTION}" in
    setup)
      setup
      ;;
    test)
      test_all
      ;;
    cleanup)
      cleanup
      ;;
    cleanup-all)
      cleanup_all
      ;;
    all)
      all
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"