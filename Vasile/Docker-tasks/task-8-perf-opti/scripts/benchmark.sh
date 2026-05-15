#!/bin/bash

mkdir -p benchmark-results

echo "Benchmarking unoptimized container..."

ab -n 5000 -c 50 http://localhost:5001/ > benchmark-results/unoptimized.txt

echo "Benchmarking optimized container..."

ab -n 5000 -c 50 http://localhost:5002/ > benchmark-results/optimized.txt

echo "Benchmark complete."

echo "Benchmarking native container..."

ab -n 1000 -c 50 http://localhost:5003/ > benchmark-results/native.txt