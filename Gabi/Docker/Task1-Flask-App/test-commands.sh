#!/bin/bash

echo "Testing /"
curl -s http://localhost:8080/

echo -e "\nTesting /health"
curl -s http://localhost:8080/health

echo -e "\nTesting /info"
curl -s http://localhost:8080/info