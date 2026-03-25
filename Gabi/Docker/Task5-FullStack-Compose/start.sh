#!/bin/bash

set -e

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not running."
  exit 1
fi

if [[ ! -f ".env" ]]; then
  echo ".env file not found. Creating it from .env.example"
  cp .env.example .env
fi

docker compose up -d --build
docker compose ps