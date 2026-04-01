# System Health Monitor

A lightweight, self-healing monitoring suite designed to track system resources, manage critical services, and automate log versioning via Git.

## Features

- **Resource Tracking:** Real-time monitoring of CPU, Memory, and Disk usage.
- **Service Management:** Auto-recovery for `nginx`, `sshd`, and `mysql`. If a service is down, the script attempts a restart and logs the event.
- **Smart Logging:** Clean, timestamped logs stored in `/home/var/logs/health-monitor/`.
- **Threshold Alerts:** Instant console alerts if:
  - CPU > 80%
  - Memory > 85%
  - Disk > 90%
- **Automated Version Control:** Daily midnight commits of log summaries to Git, keeping the repository history clean and lightweight.

## File Structure

- `monitor.sh` – Main monitoring and self-healing script.
- `git-sync.sh` – Automation script for daily Git commits and summaries.
- `.gitignore` – Configured to exclude raw `.log` files while tracking summaries.
- `README.md` – Project documentation.

## Installation & Setup

### 1. Grant Execution Permissions
Before executing the scripts, you must ensure the system has permission to run them:
```bash
chmod +x monitor.sh git-sync.sh