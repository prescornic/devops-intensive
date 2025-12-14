# Task 3 – Automated Backup and Restore Tool

## Overview
This project implements an automated backup solution using Bash scripts.
It supports:
- Local backups
- Remote backups over SSH
- Compression
- Integrity verification
- Retention policy
- Logging
- Restore / rollback
- Git version control for logs

The solution is designed to run on Linux systems (Ubuntu).

---

## Folder Structure

backup-tool/
├── backup.sh # Main backup script
├── restore.sh # Restore / rollback script
├── backup.conf # Configuration file
├── scripts/
│ └── git-commit-backup-logs.sh
├── logs/ # Backup and restore logs
├── crontab.txt # Sample cron configuration
└── README.md

## Features

### Backup
- Timestamped archives:  
  `backup-YYYY-MM-DD-HHMMSS.tar.gz`
- Local or remote destination
- SSH connectivity test before remote backup
- Disk space validation
- Archive integrity verification
- Compression ratio calculation
- Progress indicator for large backups (if `pv` is installed)
- Retention policy (keep last 7 backups)
- Logging to file and console

### Restore / Rollback
- Restore any backup archive
- Restore latest backup (rollback)
- Integrity verification before restore

### Git Integration
- Backup logs are committed daily
- Commit message format:  
  `Backup logs - YYYY-MM-DD`
- Backup archives are excluded from Git

---

## Requirements

Install required tools:

```bash
sudo apt update
sudo apt install -y tar gzip openssh-client coreutils
