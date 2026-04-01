#!/bin/bash

# Allow standard web ports
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
# Allow SSH
sudo ufw allow 22/tcp
# Flask internal (for local testing)
sudo ufw allow 5000/tcp

# Block all other incoming, allow all outgoing
sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw --force enable

echo "Firewall configured: Ports 22, 80, 443, and 5000 are open."