# Task 5 - Firewall Configuration Manager (Declarative)

## What this does
- Reads firewall rules from `rules.yaml`
- Backs up current iptables rules before applying changes
- Applies rules via `iptables-restore` (fast + consistent)
- Validates rules are active
- Prevents SSH lockout (requires tcp/22 accept rule)
- Has dry-run mode
- Has confirmation prompt
- Automatic rollback after 60 seconds unless confirmed
- Logs all changes with timestamps

## Files
- `firewall-manager.py` - main tool (dry-run/apply/rollback)
- `rules.yaml` - declarative firewall configuration
- `backup-restore.sh` - manual backup/restore helper
- `logs/` - runtime logs (ignored by git)
- `backups/` - iptables backups (ignored by git)

## Requirements
Ubuntu + iptables:
```bash
sudo apt update
sudo apt install -y iptables python3 python3-venv
