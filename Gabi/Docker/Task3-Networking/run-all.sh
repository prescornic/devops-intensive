#!/bin/bash

set -Eeuo pipefail

LOG_FILE="run.log"
exec > >(tee -a "$LOG_FILE") 2>&1

ACTION="${1:-}"

REQUIRED_SCRIPTS=(
  "./setup-networks.sh"
  "./deploy-containers.sh"
  "./test-connectivity.sh"
  "./cleanup.sh"
)

print_header() {
  echo
  echo "=================================================="
  echo "$1"
  echo "=================================================="
}

check_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "Error: Docker is not installed or not in PATH."
    exit 1
  fi

  if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker daemon is not running or not reachable."
    exit 1
  fi
}

check_required_scripts() {
  for script in "${REQUIRED_SCRIPTS[@]}"; do
    if [[ ! -f "$script" ]]; then
      echo "Error: Required script not found: $script"
      exit 1
    fi

    if [[ ! -x "$script" ]]; then
      echo "Making $script executable..."
      chmod +x "$script"
    fi
  done
}

wait_for_container() {
  local container_name="$1"
  local max_attempts="${2:-15}"
  local sleep_seconds="${3:-2}"

  echo "Waiting for container '$container_name' to be running..."

  for ((i=1; i<=max_attempts; i++)); do
    if docker ps --format '{{.Names}}' | grep -qx "$container_name"; then
      echo "Container '$container_name' is running."
      return 0
    fi
    echo "Attempt $i/$max_attempts: '$container_name' not ready yet..."
    sleep "$sleep_seconds"
  done

  echo "Warning: Container '$container_name' did not become ready in time."
  return 1
}

wait_for_http() {
  local container_name="$1"
  local url="$2"
  local max_attempts="${3:-20}"
  local sleep_seconds="${4:-2}"

  echo "Waiting for HTTP endpoint '$url' inside container '$container_name'..."

  for ((i=1; i<=max_attempts; i++)); do
    if docker exec "$container_name" sh -c "command -v wget >/dev/null 2>&1 && wget -qO- '$url' >/dev/null 2>&1"; then
      echo "Endpoint '$url' is reachable from '$container_name'."
      return 0
    fi
    echo "Attempt $i/$max_attempts: endpoint not ready yet..."
    sleep "$sleep_seconds"
  done

  echo "Warning: Endpoint '$url' did not become reachable in time."
  return 1
}

show_running_containers() {
  print_header "Running containers"
  docker ps
}

setup() {
  print_header "Setting up networks"
  ./setup-networks.sh
}

deploy() {
  print_header "Deploying containers"
  ./deploy-containers.sh

  print_header "Waiting for core containers"
  wait_for_container "frontend" || true
  wait_for_container "backend" || true
  wait_for_container "database" || true
  wait_for_container "network-bridge" || true

  print_header "Waiting for backend application readiness"
  wait_for_http "backend" "http://127.0.0.1:5000/health" || true

  show_running_containers
}

test() {
  print_header "Testing connectivity"
  ./test-connectivity.sh
}

cleanup() {
  print_header "Cleaning up resources"
  ./cleanup.sh
}

all() {
  print_header "Starting full Docker networking workflow"

  setup
  deploy
  test

  echo
  read -r -p "Do you want to clean up resources now? (y/n): " answer
  case "$answer" in
    y|Y|yes|YES)
      cleanup
      ;;
    *)
      echo "Cleanup skipped. Resources are still running."
      ;;
  esac
}

usage() {
  cat <<EOF
Usage:
  ./run-all.sh setup
  ./run-all.sh deploy
  ./run-all.sh test
  ./run-all.sh cleanup
  ./run-all.sh all

Description:
  setup    Create all Docker networks
  deploy   Deploy all containers
  test     Run connectivity and isolation tests
  cleanup  Remove containers, networks, and related resources
  all      Run setup, deploy, test, and optionally cleanup

Logs:
  All output is saved to: $LOG_FILE
EOF
}

main() {
  check_docker
  check_required_scripts

  case "$ACTION" in
    setup)
      setup
      ;;
    deploy)
      deploy
      ;;
    test)
      test
      ;;
    cleanup)
      cleanup
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