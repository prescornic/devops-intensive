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

mkdir -p "$LOCAL_BACKUP_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
BACKUP_NAME="backup-$TIMESTAMP.tar.gz"

# --- 2. Logging Function ---
log_message() {
    local MESSAGE="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $MESSAGE" | tee -a "$LOG_FILE"
}

# --- 3. Pre-Backup Validation ---
validate_env() {
    local source=$1
    
    if [ ! -d "$source" ] && [ ! -f "$source" ]; then
        log_message "ERROR: Source '$source' does not exist."
        exit 1
    fi

    local src_size=$(du -sk "$source" | cut -f1)
    local avail_space=$(df -k "$LOCAL_BACKUP_DIR" | awk 'NR==2 {print $4}')

    if [ "$avail_space" -lt "$src_size" ]; then
        log_message "ERROR: Insufficient space in $LOCAL_BACKUP_DIR. Need ${src_size}KB, have ${avail_space}KB."
        exit 1
    fi
}

# --- 4. Backup Execution ---
perform_backup() {
    local src=$1
    local dest_path="$LOCAL_BACKUP_DIR/$BACKUP_NAME"

    log_message "Starting backup: $src -> $dest_path"
    
    # Calculate sizes for comparison
    local initial_size=$(du -sh "$src" | cut -f1)

    # Progress Indicator: Prints a dot every 50 checkpoints
    echo -n "Progress: "
    tar --checkpoint=50 --checkpoint-action=dot \
        -czf "$dest_path" -C "$(dirname "$src")" "$(basename "$src")"
    echo " Done!"

    # --- 5. Integrity Verification ---
    if tar -tzf "$dest_path" > /dev/null 2>&1; then
        local archive_size=$(du -sh "$dest_path" | cut -f1)
        log_message "SUCCESS: Archive integrity verified."
        log_message "Stats: Initial: $initial_size | Compressed: $archive_size"
    else
        log_message "ERROR: Archive corrupted during creation."
        rm -f "$dest_path"
        exit 1
    fi
}

# --- 6. Remote Transfer (SSH) ---
remote_transfer() {
    local local_file="$LOCAL_BACKUP_DIR/$BACKUP_NAME"
    local remote_target="$1"

    local remote_host=$(echo "$remote_target" | cut -d'@' -f2 | cut -d':' -f1)
    
    log_message "Testing connectivity to $remote_host on port $SSH_PORT..."
    if nc -zvw5 "$remote_host" "$SSH_PORT" > /dev/null 2>&1; then
        log_message "Connectivity OK. Starting SCP transfer..."
        
        scp -P "$SSH_PORT" -i "$SSH_KEY_PATH" "$local_file" "$remote_target"
        
        if [ $? -eq 0 ]; then
            log_message "Remote transfer successful."
        else
            log_message "ERROR: SCP transfer failed."
        fi
    else
        log_message "WARNING: Remote host $remote_host unreachable. Skipping remote backup."
    fi
}

# --- 7. Retention Policy ---
apply_retention() {
    log_message "Applying retention policy (Keeping last $RETENTION_DAYS backups)..."
    # List backups by time (newest first), skip the first 7, delete the rest
    ls -tp "$LOCAL_BACKUP_DIR"/backup-*.tar.gz | grep -v '/$' | tail -n +$((RETENTION_DAYS + 1)) | xargs -I {} rm -- {}
}

# --- Main Execution ---

# Logic: Use the arguments if provided by the user. Otherwise, config defaults.
SOURCE_INPUT=${1:-$SOURCE_DIR}
DEST_INPUT=${2:-$LOCAL_BACKUP_DIR}

validate_env "$SOURCE_INPUT"
perform_backup "$SOURCE_INPUT"

# Check if destination is remote
if [[ "$DEST_INPUT" == *"@"* ]]; then
    remote_transfer "$DEST_INPUT"
fi

apply_retention

log_message "Backup sequence finished successfully."