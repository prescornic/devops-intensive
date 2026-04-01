# Automated Backup and Deployment System

A robust Bash-based solution for automated backups, featuring remote SSH transfer, integrity verification, and rolling retention.

## Project Structure
* `backup.sh`: Main script to compress and transfer data.
* `restore.sh`: Rollback script to extract backups to a target directory.
* `backup.conf`: Centralized configuration for paths and remote server details.
* `git-commit-logs.sh`: Automates version control for backup activity.
* `backups/`: Local storage for generated archives.
* `logs/`: Storage for execution history.

## Getting Started

### 1. Prerequisites
* **SSH Key-Based Auth:** Ensure your public key is on the remote server to allow non-interactive `scp` transfers.
* **Permissions:** Ensure the scripts are executable:
    ```bash
    chmod +x backup.sh restore.sh git-commit-logs.sh
    ```

### 2. Configuration
Edit `backup.conf` to match your environment:
* `SOURCE_DIR`: The default folder you want to protect.
* `REMOTE_HOST` / `REMOTE_DEST`: Your off-site backup details.
* `RETENTION_DAYS`: Set to `7` to comply with the requirement to keep only the last week of backups.

## Usage Examples

### Local Backup
Uses the default source defined in the config and saves it to the local backup folder.
```bash
./backup.sh
```