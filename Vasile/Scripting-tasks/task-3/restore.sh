#!/bin/bash

# --- 1. Initialization & Configuration ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONF_FILE="$SCRIPT_DIR/backup.conf"

if [ -f "$CONF_FILE" ]; then
    source "$CONF_FILE"
else
    echo "Error: Configuration file $CONF_FILE not found."
    exit 1
fi

# Arguments: 1=Archive Path (Optional), 2=Target Directory (Optional)
ARCHIVE_INPUT=$1
TARGET_INPUT=${2:-$SOURCE_DIR}

# --- 2. Auto-Discovery Logic ---
if [ -z "$ARCHIVE_INPUT" ]; then
    echo "No archive specified. Looking for the most recent backup in $LOCAL_BACKUP_DIR..."
    
    # Find the newest .tar.gz file in the local backup directory
    LATEST_BACKUP=$(ls -t "$LOCAL_BACKUP_DIR"/backup-*.tar.gz 2>/dev/null | head -n 1)

    if [ -z "$LATEST_BACKUP" ]; then
        echo "ERROR: No backups found in $LOCAL_BACKUP_DIR. Cannot perform rollback."
        exit 1
    fi
    ARCHIVE_INPUT="$LATEST_BACKUP"
fi

# --- 3. Validation ---
if [ ! -f "$ARCHIVE_INPUT" ]; then
    echo "ERROR: Archive file '$ARCHIVE_INPUT' does not exist."
    exit 1
fi

echo "--- Rollback Initiated ---"
echo "Archive: $(basename "$ARCHIVE_INPUT")"
echo "Target:  $TARGET_INPUT"
echo "--------------------------"

read -p "Are you sure you want to restore? This may overwrite existing files. (y/n): " CONFIRM
if [[ $CONFIRM != [yY] ]]; then
    echo "Restore cancelled."
    exit 0
fi

# --- 4. Execution ---
mkdir -p "$TARGET_INPUT"

# Extract
# -x: extract, -z: ungzip, -v: verbose, -f: file
tar -xzvf "$ARCHIVE_INPUT" -C "$TARGET_INPUT"

if [ $? -eq 0 ]; then
    echo "SUCCESS: System rolled back to state from $(basename "$ARCHIVE_INPUT")"
else
    echo "ERROR: Restore failed during extraction."
    exit 1
fi