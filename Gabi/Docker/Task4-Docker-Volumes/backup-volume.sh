#!/bin/bash

set -Eeuo pipefail

BACKUP_DIR="${1:-./backups}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_FILE="${BACKUP_DIR}/appdb-backup-${TIMESTAMP}.sql"

POSTGRES_CONTAINER="task4-postgres"
POSTGRES_DB="appdb"
POSTGRES_USER="appuser"

mkdir -p "${BACKUP_DIR}"

if ! docker ps --format '{{.Names}}' | grep -qx "${POSTGRES_CONTAINER}"; then
  echo "Error: PostgreSQL container '${POSTGRES_CONTAINER}' is not running."
  echo "Start it first with:"
  echo "  docker compose -f docker-compose-volumes.yaml up -d postgres"
  exit 1
fi

echo "Creating PostgreSQL logical backup..."
echo "Source container : ${POSTGRES_CONTAINER}"
echo "Database         : ${POSTGRES_DB}"
echo "User             : ${POSTGRES_USER}"
echo "Output file      : ${BACKUP_FILE}"

docker exec "${POSTGRES_CONTAINER}" pg_dump -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" > "${BACKUP_FILE}"

if [[ ! -s "${BACKUP_FILE}" ]]; then
  echo "Error: Backup file was created but is empty."
  exit 1
fi

echo
echo "Backup completed successfully."
ls -lh "${BACKUP_FILE}"