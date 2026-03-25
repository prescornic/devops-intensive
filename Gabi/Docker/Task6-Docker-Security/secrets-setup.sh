#!/bin/bash

set -Eeuo pipefail

mkdir -p secrets

if [[ -f secrets/app_secret.txt ]]; then
  echo "Secret file already exists: secrets/app_secret.txt"
else
  echo "Creating secret file..."
  openssl rand -hex 16 > secrets/app_secret.txt
  echo "Secret created at secrets/app_secret.txt"
fi

chmod 600 secrets/app_secret.txt
ls -l secrets/app_secret.txt