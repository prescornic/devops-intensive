#!/bin/bash
echo "Backing up database using pg_dump..."

docker compose exec -t db pg_dump -U postgres > db_backup.sql
echo "Backup saved as db_backup.sql"