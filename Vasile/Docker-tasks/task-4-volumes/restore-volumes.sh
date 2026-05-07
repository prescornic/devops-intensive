#!/bin/bash
echo "Restoring database from SQL dump..."

cat db_backup.sql | docker compose exec -T db psql -U postgres
echo "Restore complete!"