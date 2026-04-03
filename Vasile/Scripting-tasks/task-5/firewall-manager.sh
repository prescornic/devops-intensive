#!/bin/bash

# Configuration
CONFIG_FILE="rules.json"
BACKUP_DIR="/var/backups/firewall"
LOG_FILE="/var/log/firewall-manager.log"
CONFIRM_TIMEOUT=60

# Ensure root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (sudo)." 
   exit 1
fi

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

backup_rules() {
    mkdir -p "$BACKUP_DIR"
    local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    local backup_path="$BACKUP_DIR/firewall-$timestamp.rules"
    iptables-save > "$backup_path" 2>/dev/null
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup created at $backup_path" >> "$LOG_FILE"
    echo "$backup_path"
}

rollback() {
    local backup_path=$1
    log "ROLLING BACK to $backup_path..."
    iptables-restore < "$backup_path"
    log "Rollback complete."
}

apply_firewall() {
    local dry_run=$1
    log "Applying firewall from $CONFIG_FILE (Dry-run: $dry_run)"

    # This extracts the port, protocol, and action from rules.json
    local rules=$(grep -E '\{|port|protocol|action|source|name' "$CONFIG_FILE")

    if [[ "$dry_run" == "false" ]]; then
        # 1. Flush & Safety Rule
        iptables -F
        iptables -A INPUT -p tcp --dport 22 -j ACCEPT
        
        # 2. Set Default Policies (Extracted from JSON)
        local in_pol=$(grep '"input":' "$CONFIG_FILE" | cut -d'"' -f4 | tr '[:lower:]' '[:upper:]')
        iptables -P INPUT ${in_pol:-DROP}
        iptables -P FORWARD DROP
        iptables -P OUTPUT ACCEPT
    else
        echo "[DRY-RUN] Would execute: iptables -F"
        echo "[DRY-RUN] Would execute: iptables -A INPUT -p tcp --dport 22 -j ACCEPT"
    fi

    # 3. Simple loop to apply rules
    # It looks for blocks in the JSON and applies them.
    while read -r line; do
        if [[ $line =~ \"port\":\ ([0-9]+) ]]; then port="${BASH_REMATCH[1]}"; fi
        if [[ $line =~ \"protocol\":\ \"([^\"]+)\" ]]; then proto="${BASH_REMATCH[1]}"; fi
        if [[ $line =~ \"action\":\ \"([^\"]+)\" ]]; then action="${BASH_REMATCH[1]}"; fi
        
        # When we hit the end of a JSON object "}", apply the rule
        if [[ $line == *"}"* && -n $port ]]; then
            local cmd="iptables -A INPUT -p ${proto:-tcp} --dport $port -j ${action^^}"
            if [[ "$dry_run" == "true" ]]; then
                echo "[DRY-RUN] Would execute: $cmd"
            else
                $cmd
                log "Applied rule for port $port"
            fi
            unset port proto action
        fi
    done <<< "$rules"
}

# Main Logic
case "$1" in
    --dry-run)
        apply_firewall "true"
        ;;
    --apply)
        BACKUP_FILE=$(backup_rules)
        apply_firewall "false"
        
        echo -e "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "RULES APPLIED. TEST YOUR CONNECTION NOW."
        echo "You have $CONFIRM_TIMEOUT seconds to type 'yes' to confirm."
        echo "Otherwise, I will ROLLBACK automatically."
        echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"

        read -t "$CONFIRM_TIMEOUT" -p "Confirm changes? (yes/no): " user_input
        
        if [[ "$user_input" == "yes" ]]; then
            log "Changes confirmed by user."
        else
            log "No confirmation or denied. Triggering rollback."
            rollback "$BACKUP_FILE"
        fi
        ;;
    *)
        echo "Usage: sudo $0 {--dry-run|--apply}"
        exit 1
        ;;
esac