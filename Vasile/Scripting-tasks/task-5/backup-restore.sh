#!/bin/bash

if [[ "$1" == "--restore" ]]; then
    if [[ -f "$2" ]]; then
        iptables-restore < "$2"
        echo "Restored rules from $2"
    else
        echo "Error: Backup file not found."
    fi
fi