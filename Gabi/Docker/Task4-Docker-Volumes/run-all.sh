#!/bin/bash

set -Eeuo pipefail

ACTION="${1:-}"
COMPOSE_FILE="docker-compose-volumes.yaml"
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

check_required_files() {
  local files=(
    "${COMPOSE_FILE}"
    "./test-persistence.sh"
    "./backup-volume.sh"
    "./restore-volume.sh"
  )

  for file in "${files[@]}"; do
    if [[ ! -f "${file}" ]]; then
      echo "Error: Required file not found: ${file}"
      exit 1
    fi
  done

  chmod +x ./test-persistence.sh ./backup-volume.sh ./restore-volume.sh
}

setup() {
  print_header "Starting Task 4 services"
  docker compose -f "${COMPOSE_FILE}" up -d
}

test_all() {
  print_header "Running Task 4 tests"
  ./test-persistence.sh
}

cleanup() {
  print_header "Stopping Task 4 services"
  docker compose -f "${COMPOSE_FILE}" down
  docker rm -f task4-postgres-restored 2>/dev/null || true
  echo "Containers stopped."
}

cleanup_all() {
  print_header "Stopping Task 4 services and removing volumes"
  docker compose -f "${COMPOSE_FILE}" down -v
  docker rm -f task4-postgres-restored 2>/dev/null || true
  docker volume rm postgres_data_restored 2>/dev/null || true
  echo "Containers and volumes removed."
}

all() {
  print_header "Starting full Task 4 workflow"
  setup
  test_all

  echo
  read -r -p "Do you want to remove containers and volumes now? (y/n): " answer
  case "${answer}" in
    y|Y|yes|YES)
      cleanup_all
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
  setup        Start all services
  test         Run persistence and backup/restore tests
  cleanup      Stop containers
  cleanup-all  Stop containers and remove volumes
  all          Run setup + tests + optional cleanup

Logs:
  Full workflow log: ${LOG_FILE}
  Test log: test-results.log
EOF
}

main() {
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

main