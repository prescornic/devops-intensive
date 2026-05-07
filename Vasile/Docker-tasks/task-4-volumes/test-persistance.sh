#!/bin/bash

echo "Inserting data into Database..."
docker compose exec db psql -U postgres -c "CREATE TABLE test (val TEXT); INSERT INTO test VALUES ('Docker is persistent!');"

echo "Destroying Database Container..."
docker compose stop db
docker compose rm -f db

echo "Recreating Database Container..."
docker compose up -d db
sleep 5

echo "Verifying data persistence:"
docker compose exec db psql -U postgres -c "SELECT * FROM test;"

echo "Writing to tmpfs..."
docker compose exec cache touch /tmp/cache-data/secret.txt
docker compose restart cache
echo "Checking tmpfs after restart (Should be empty):"
docker compose exec cache ls /tmp/cache-data/