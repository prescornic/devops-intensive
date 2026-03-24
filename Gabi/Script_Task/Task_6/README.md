# Task 6: API Data Operations and Monitoring

## What it does
- Fetches users and posts from JSONPlaceholder
- Generates daily reports in JSON/CSV/TXT under `reports/YYYY-MM-DD/`
- Tracks API response time
- Optional system operations (safe by default):
  - Create Linux users based on API usernames
  - Create `/home/username/{logs,data,backup}`
  - Generate SSH keys for users
  - Generate nginx vhost config files for each user website domain

## Prerequisites
Ubuntu/Debian:
```bash
sudo apt update
sudo apt install -y python3 python3-pip
