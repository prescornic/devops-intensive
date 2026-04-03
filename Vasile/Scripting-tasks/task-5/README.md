# Firewall Configuration Manager

## Overview

This project provides a robust, **declarative** firewall management system using Bash. 
It allows DevOps engineers to define firewall states in a JSON configuration file and apply them safely with an integrated **automatic rollback** mechanism.

The script is designed to be platform-independent across Linux distributions, requiring only `iptables` and standard core utilities (`grep`, `sed`, `bash`).

## Key Features

- **Declarative Configuration:** Define rules in `rules.json` instead of manual commands.
- **Safety First:** Automatically creates a timestamped backup before any changes are applied.
- **Atomic Rollback:** Includes a **60-second confirmation timer**. If the user does not confirm the connection (by typing `yes`), the script automatically restores the previous firewall state to prevent accidental lockouts.
- **Dry-Run Mode:** Preview exactly what `iptables` commands would be executed without touching the system.
- **Persistent Logging:** All actions, confirmations, and rollbacks are logged to `/var/log/firewall-manager.log`.

---

## File Structure

- `firewall-manager.sh`: The main execution engine.
- `rules.json`: The source of truth for firewall rules.
- `backup-restore.sh`: A utility script for manual restoration of previous states.

---
