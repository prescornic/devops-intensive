#!/bin/bash
echo "--- Testing DNS Resolution (Custom Bridge) ---"
docker exec container-a ping -c 2 container-b

echo -e "\n--- Testing Isolation (Frontend -> DB should FAIL) ---"
# This should timeout/fail because they are on different networks
docker exec frontend ping -c 2 database || echo "Success: Frontend cannot reach Database."

echo -e "\n--- Testing Multi-Network (Backend -> DB should PASS) ---"
docker exec backend ping -c 2 database

echo -e "\n--- Testing Multi-Network (Backend -> Frontend should PASS) ---"
docker exec backend ping -c 2 frontend

echo -e "\n--- Testing 'None' Network (Should have no internet/IP) ---"
docker exec isolated-app ip addr