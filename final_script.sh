#!/bin/bash

# Configuration (move to separate file for security)
source config.sh  # Replace with your actual config file path

# Define functions (modularized for better readability)
function get_error_logs() {
  local server_name="$1"
  local pem_file=$(grep "^$server_name:" "$SERVER_LIST_FILE" | awk -F':' '{print $2}')
  ssh -i "$pem_file" -o ConnectTimeout=10 "$server_name" "grep -r \"$ERROR_TERM\" \"/var/log\"/* | grep -E \"^$(date --date=-15 minutes +%Y-%m-%dT%H:%M).*\"" 2>/dev/null
}

function get_server_stats() {
  local server_name="$1"
  local pem_file=$(grep "^$server_name:" "$SERVER_LIST_FILE" | awk -F':' '{print $2}')
  ssh -i "$pem_file" -o ConnectTimeout=10 "$server_name" "
    # Get CPU usage
    cpu_usage=\$(top -b -n1 | grep '^%Cpu' | awk '{print \$2 + \$4}')
    # Get memory usage
    mem_total=\$(free -m | grep 'Mem:' | awk '{print \$2}')
    mem_used=\$(free -m | grep 'Mem:' | awk '{print \$3}')
    mem_usage=\$(echo \"scale=2; 100 * (\$mem_used / \$mem_total)\" | bc)
    # Get disk usage (example for '/')
    disk_usage=\$(df -h / | grep '/' | awk '{print \$5}')
    
    echo \"CPU Usage: \$cpu_usage%\"
    echo \"Memory Usage: \$mem_usage%\"
    echo \"Disk Usage (/): \$disk_usage\"
  " 2>/dev/null
}

function send_email_notification() {
  local message="$1"
  echo "$message" | mail -s "$EMAIL_SUBJECT" "$EMAIL_TO"
}

function send_slack_notification() {
  local message="$1"
  curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"$message\"}" "$SLACK_WEBHOOK_URL"
}

function process_server() {
  local server_name="$1"
  # Get server stats (used for both resource usage and error checks)
  local server_stats=$(get_server_stats "$server_name")

  # Check for high resource usage
  local cpu_usage=$(echo "$server_stats" | grep 'CPU Usage:' | awk -F':' '{print $2}' | tr -d '%')
  local mem_usage=$(echo "$server_stats" | grep 'Memory Usage:' | awk -F':' '{print $2}' | tr -d '%')
  local disk_usage=$(echo "$server_stats" | grep 'Disk Usage:' | awk -F':' '{print $2}' | tr -d '%')

  if (( $(echo "$cpu_usage > 85" | bc -l) )) || (( $(echo "$mem_usage > 85" | bc -l) )) || (( $(echo "$disk_usage > 85" | bc -l) )); then
    local error_message="**High Resource Usage Alert** for server $server_name:\n$server_stats"
    
    # Send notifications for high resource usage
    if [[ ! -z "$EMAIL_TO" ]]; then
      send_email_notification "$error_message"
    fi
    if [[ ! -z "$SLACK_WEBHOOK_URL" ]]; then
      send_slack_notification "$error_message"
    fi

    echo "** Additional actions can be taken here for $server_name based on high resource usage. **"
  fi

  # Check for errors (if needed)
  local error_logs=$(get_error_logs "$server_name")
  local error_count=$(echo "$error_logs" | wc -l)
  
  if [[ ! -z "$error_logs" ]] && [[ -z "$SUPPRESS_ALERTS" ]]; then
    local error_message="**$error_count Errors** found in server logs ($server_name - last 15 minutes):\n$error_logs\nServer Stats: $server_stats"

    # Send notifications for errors (if configured)
    if [[ ! -z "$EMAIL_TO" ]]; then
      send_email_notification "$error_message"
    fi
    if [[ ! -z "$SLACK_WEBHOOK_URL" ]]; then
      send_slack_notification "$error_message"
    fi
  fi
}

# Main execution flow

# Server list file path
SERVER_LIST_FILE="server_list.txt"

# Iterate through each server in the server list and process it
while IFS= read -r line; do
  server_name=$(echo "$line" | awk -F':' '{print $1}')
  process_server "$server_name"
done < "$SERVER_LIST_FILE"
