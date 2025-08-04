#!/bin/bash

# Duck DNS Auto Update Script
# Add this to crontab to run every 5 minutes: */5 * * * * /path/to/update-duckdns.sh

DOMAIN="buq"
TOKEN="dfe377ca-478f-4f48-9d9d-3abbc069f5c0"
LOG_FILE="/var/log/duckdns-update.log"

# Get current public IP
CURRENT_IP=$(curl -s http://checkip.amazonaws.com)

if [ -z "$CURRENT_IP" ]; then
    echo "$(date): Error - Could not get current public IP" >> "$LOG_FILE"
    exit 1
fi

# Check if IP has changed (optional - saves API calls)
LAST_IP_FILE="/tmp/duckdns_last_ip"
if [ -f "$LAST_IP_FILE" ]; then
    LAST_IP=$(cat "$LAST_IP_FILE")
    if [ "$CURRENT_IP" = "$LAST_IP" ]; then
        # IP hasn't changed, no need to update
        exit 0
    fi
fi

# Update Duck DNS
RESPONSE=$(curl -s "https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&ip=$CURRENT_IP")

if [ "$RESPONSE" = "OK" ]; then
    echo "$(date): Duck DNS updated successfully - IP: $CURRENT_IP" >> "$LOG_FILE"
    echo "$CURRENT_IP" > "$LAST_IP_FILE"
else
    echo "$(date): Error updating Duck DNS - Response: $RESPONSE" >> "$LOG_FILE"
    exit 1
fi
