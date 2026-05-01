#!/bin/bash

echo "--- Testing Root Endpoint ---"
curl -s http://localhost:8080/
echo -e "\n"

echo "--- Testing Health Endpoint ---"
curl -s http://localhost:8080/health | jq .
echo -e "\n"

echo "--- Testing Info Endpoint ---"
curl -s http://localhost:8080/info | jq .
echo -e "\n"