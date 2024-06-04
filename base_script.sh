#!/bin/bash

pem_file="/Users/pragadeeswaran.s/Downloads/pem/abc.pem"
server_name="1.2.3.4"
metric=$(ssh -i "$pem_file"  "$server_name" "
    cpu_usage=\$(top -b -n1 | grep '^%Cpu' | awk '{print \$2 + \$4}')
    mem_total=\$(free -m | grep 'Mem:' | awk '{print \$2}')
    mem_used=\$(free -m | grep 'Mem:' | awk '{print \$3}')
    mem_usage=\$(echo \"scale=2; 100 * (\$mem_used / \$mem_total)\" | bc)
    disk_usage=\$(df -h / | grep '/' | awk '{print \$5}')
    echo \"CPU Usage: \$cpu_usage%\"
    echo \"Memory Usage: \$mem_usage%\"
    echo \"Disk Usage (/): \$disk_usage\"
  " 2>&1)

echo "$metric"
log=$(ssh -i "$pem_file" "$server_name" "grep -i -e 'error' \"/var/log\"/* | grep -E \"^$(date --date=-15 minutes +%Y-%m-%dT%H:%M).*\"" 2>/dev/null)

if [[ ! -z "$log" ]]; then
    message="$metric\n\n$log"
    echo -e "$message" | mail -s "Error in Logs" "sample@test.com"
fi
