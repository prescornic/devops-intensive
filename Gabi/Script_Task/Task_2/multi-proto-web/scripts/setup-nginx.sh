#!/usr/bin/env bash
set -euo pipefail

SRC_CONF="$(pwd)/nginx/multi-proto.conf"
DEST_CONF="/etc/nginx/sites-available/multi-proto"

sudo cp "$SRC_CONF" "$DEST_CONF"
sudo ln -sf "$DEST_CONF" /etc/nginx/sites-enabled/multi-proto
sudo rm -f /etc/nginx/sites-enabled/default

sudo nginx -t
sudo systemctl reload nginx

echo "Nginx configured and reloaded."
