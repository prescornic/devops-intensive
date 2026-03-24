# System Health Monitor

This project provides a simple system health monitor using Bash scripts.

## Features

- Monitor CPU, memory, and disk usage
- Check services: nginx, docker, sshd
- Log results to `logs/health-monitor.log`
- Generate daily summaries and commit them to Git

## Files

- `monitor.sh` – main monitoring script (runs every 5 minutes via cron)
- `git-commit-logs.sh` – creates daily summary and commits it
- `.gitignore` – excludes raw logs, includes daily summaries
- `crontab.txt` – example cron configuration

## Usage

Run once manually:

```bash
./monitor.sh
