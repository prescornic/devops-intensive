# Task 4: Docker Volumes and Data Persistence

## Features
- **Named Volume**: Persistent PostgreSQL data storage (`db_data`).
- **Bind Mount**: Live-reloading Nginx configuration and HTML content.
- **tmpfs**: Ephemeral memory-backed storage for the cache service.
- **Shared Volume**: Data exchange between `writer` and `reader` services.

## Scripts
- `backup-volume.sh`: Logical backup using `pg_dump`.
- `restore-volumes.sh`: Database restoration via SQL dump.
- `test-persistance.sh`: Automated verification of data survival and tmpfs clearing.

## Commands
- **Start**: `docker compose up -d`
- **Stop**: `docker compose down -v`
- **Test**: `./test-persistance.sh`
- **Backup**: `./backup-volume.sh`
- **Restore**: `./restore-volumes.sh`

## Evidence

1. **The containers:**
![alt text](<../task-4-volumes/evidence/1.png>)

2. **Test:**
![alt text](<../task-4-volumes/evidence/2.png>)

3. **Localhost:**
![alt text](<../task-4-volumes/evidence/3.png>)

4. **Localhost after changes:**
- The browser showing the updated text. This proves the container is "reading" directly from the folder.
![alt text](<../task-4-volumes/evidence/4.png>)

5. **Backup & Restore:**
- Backup strategy using `pg_dump` to create logical backups of the PostgreSQL database.
![alt text](<../task-4-volumes/evidence/5.png>)

6. **Transitioned from `tar.gz` archive backups to `pg_dump` logical backup**
- Because `tar` attempted to copy raw database files while the service was running, resulting in empty 86-byte archives.
![alt text](<../task-4-volumes/evidence/6.png>)