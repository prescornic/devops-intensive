# Docker Volumes and Data Persistence

## 📌 Overview

This project demonstrates Docker volume strategies for data persistence and data sharing between containers.

The following concepts were implemented and verified:

* Named volumes for persistent database storage
* Bind mounts for local configuration and live file updates
* tmpfs mounts for ephemeral in-memory storage
* Shared volumes between multiple containers
* Backup and restore using PostgreSQL logical backups (`pg_dump`)
* Automated testing and logging

---

## 🧱 Architecture

### Multi-container setup

```text
nginx (bind mount)
postgres (named volume)
tmpfs-demo (tmpfs)
writer <--> shared volume <--> reader
```

---

## 📦 Volume Types Demonstrated

### 1. Named Volume (PostgreSQL)

* Volume: `postgres_data`
* Mount path: `/var/lib/postgresql/data`

✔ Data persists after container removal
✔ Used for database storage

---

### 2. Bind Mount (nginx)

* Local path: `./nginx/`
* Mounted into container:

  * `/etc/nginx/nginx.conf`
  * `/usr/share/nginx/html`

✔ Changes on host reflect instantly inside container

---

### 3. tmpfs Mount

* Path: `/tmp/cache`

✔ Stored in memory
✔ Data disappears after restart

---

### 4. Shared Volume

* Volume: `shared_data`
* Used by:

  * writer container
  * reader container

✔ One container writes, another reads
✔ Data consistency verified

---

## 🔄 Backup and Restore (PostgreSQL)

Instead of raw volume backup, this project uses:

* `pg_dump` → backup
* `psql` → restore

This is the **recommended production approach**.

### Backup

```bash
./backup-volume.sh
```

### Restore

```bash
./restore-volume.sh backups/appdb-backup-YYYYMMDD-HHMMSS.sql
```

### Why this approach?

* ensures consistency
* avoids corrupted backups
* works across environments
* aligns with real DevOps practices

---

## ⚙️ Automation

### Run everything

```bash
./run-all.sh all
```

### Available commands

```bash
./run-all.sh setup
./run-all.sh test
./run-all.sh cleanup
./run-all.sh cleanup-all
```

---

## 🧪 Testing

Run all persistence tests:

```bash
./test-persistence.sh
```

### What is tested

* database persistence after container recreation
* bind mount functionality
* tmpfs non-persistence
* shared volume consistency
* backup and restore validation

---

## 📝 Logging

### Test logs

```text
test-results.log
```

Contains:

* all test outputs
* database operations
* PASS/FAIL indicators

---

### Workflow logs

```text
run.log
```

Contains:

* full execution of `run-all.sh`
* setup + test + cleanup logs

---

## 📂 Project Structure

```text
Task4-Docker-Volumes/
├── docker-compose-volumes.yaml
├── backup-volume.sh
├── restore-volume.sh
├── test-persistence.sh
├── run-all.sh
├── README.md
├── nginx/
│   ├── nginx.conf
│   └── html/
│       └── index.html
├── backups/
├── run.log
├── test-results.log
```

---

## 🔐 Security & Best Practices

### Named Volumes

✔ Best for persistent data
✔ Managed by Docker
✔ Safe for databases

---

### Bind Mounts

✔ Good for development
⚠️ Avoid exposing sensitive host paths

---

### tmpfs

✔ No disk persistence
✔ Ideal for sensitive or temporary data

---

### Backup Strategy

✔ Use logical backups (`pg_dump`)
✔ Always verify restore
✔ Do not rely on raw volume copy for databases

---

## 🚀 Key Takeaways

* Containers are ephemeral, data is not
* Named volumes ensure persistence
* Bind mounts enable live development workflows
* tmpfs provides fast, temporary storage
* Shared volumes enable inter-container communication
* Logical database backups are safer than raw volume copies
* Automation and logging improve reproducibility

---

## 🏁 Conclusion

This project demonstrates:

* proper use of Docker volume types
* real-world database backup strategies
* automated testing and validation
* production-style DevOps practices