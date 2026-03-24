#!/usr/bin/env bash
set -euo pipefail

# Default drop inbound, allow outbound. Keep SSH open so you don't lock yourself out.

sudo iptables -F
sudo iptables -X

sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

sudo iptables -A INPUT -p tcp --dport 22  -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80  -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT

sudo iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "IPTABLES_DROP: " --log-level 4

echo "Firewall rules applied:"
sudo iptables -S
