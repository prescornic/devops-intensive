#!/bin/bash

echo "Scanning Multi-Stage Image for vulnerabilities..."

docker scout quickview task2app:multi
