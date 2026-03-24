#!/bin/bash

set -Eeuo pipefail

LOG_FILE="test-results.log"

POSTGRES_CONTAINER="task4-postgres"
RESTORE_CONTAINER="task4-postgres-restored"

POSTGRES_DB="appdb"
POSTGRES_USER="appuser"

BACKUP_DIR="./backups"

exec > >(tee -a "${LOG_FILE}") 2>&1

print_header() {
  echo
  echo "=================================================="
  echo "$1"
  echo "=================================================="
}

wait_for_postgres() {
  local container_name="$1"

  for i in {1..20}; do
    if docker exec "${container_name}" pg_isready -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" >/dev/null 2>&1; then
      echo "PostgreSQL container '${container_name}' is ready."
      return 0
    fi

    if [[ "$i" -eq 20 ]]; then
      echo "ERROR: PostgreSQL container '${container_name}' did not become ready in time."
      docker logs "${container_name}" || true
      exit 1
    fi

    sleep 2
  done
}

print_header "Starting Task 4 persistence tests"
echo "Log file: ${LOG_FILE}"

print_header "Waiting for PostgreSQL"
wait_for_postgres "${POSTGRES_CONTAINER}"

print_header "Test 1: Named volume persistence"
echo "Creating table if needed..."
docker exec "${POSTGRES_CONTAINER}" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c "CREATE TABLE IF NOT EXISTS users (id SERIAL PRIMARY KEY, name TEXT NOT NULL);"

echo "Resetting table contents for deterministic test..."
docker exec "${POSTGRES_CONTAINER}" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c "TRUNCATE TABLE users RESTART IDENTITY;"

echo "Inserting sample data..."
docker exec "${POSTGRES_CONTAINER}" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c "INSERT INTO users (name) VALUES ('Gabriel'), ('DevOps');"

echo "Reading inserted data..."
docker exec "${POSTGRES_CONTAINER}" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c "SELECT * FROM users;"

echo "Recreating PostgreSQL container without deleting volume..."
docker stop "${POSTGRES_CONTAINER}"
docker rm -f "${POSTGRES_CONTAINER}"
docker compose -f docker-compose-volumes.yaml up -d postgres

wait_for_postgres "${POSTGRES_CONTAINER}"

echo "Verifying persisted data..."
docker exec "${POSTGRES_CONTAINER}" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c "SELECT * FROM users;"

print_header "Test 2: Bind mount"
echo "Current nginx page content:"
curl -s http://localhost:8082/ | head -n 10

echo
echo "Bind mount validation note:"
echo "Edit ./nginx/html/index.html locally, then reload nginx with:"
echo "  docker exec task4-nginx nginx -s reload"
echo "Then run:"
echo "  curl http://localhost:8082/"

print_header "Test 3: tmpfs non-persistence"
echo "Creating temporary file in tmpfs mount..."
docker exec task4-tmpfs sh -c "echo 'ephemeral' > /tmp/cache/manual.txt && cat /tmp/cache/manual.txt"

echo "Restarting tmpfs container..."
docker restart task4-tmpfs >/dev/null
sleep 2

echo "Verifying temporary file does not persist..."
docker exec task4-tmpfs sh -c "if [ -f /tmp/cache/manual.txt ]; then echo 'FAIL: tmpfs data still exists'; exit 1; else echo 'PASS: tmpfs data did not persist after restart'; fi"

print_header "Test 4: Shared volume consistency"
echo "Reading shared file from reader..."
docker exec task4-reader cat /shared/message.txt

echo "Updating shared file from writer..."
docker exec task4-writer sh -c "echo 'Shared volume updated successfully' > /shared/message.txt"

echo "Reading updated shared file from reader..."
docker exec task4-reader cat /shared/message.txt

print_header "Test 5: Backup and restore using pg_dump"
./backup-volume.sh "${BACKUP_DIR}"

LATEST_BACKUP="$(ls -1t "${BACKUP_DIR}"/appdb-backup-*.sql | head -n 1)"

if [[ -z "${LATEST_BACKUP}" ]]; then
  echo "ERROR: No backup file found in ${BACKUP_DIR}"
  exit 1
fi

echo "Latest backup detected: ${LATEST_BACKUP}"

./restore-volume.sh "${LATEST_BACKUP}"

echo "Verifying restored data..."
docker exec -i "${RESTORE_CONTAINER}" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c "SELECT * FROM users;"

print_header "Task 4 tests completed successfully"
echo "All results have been logged to ${LOG_FILE}"