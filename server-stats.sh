#!/bin/bash

echo "=========================="
echo "  SERVER STATS"
echo "=========================="

# OS & Uptime
echo ""
echo "--- OS & Uptime ---"
cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2
uname -r
uptime -p 2>/dev/null || uptime
echo "Load Average: $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
echo "Logged in users: $(who | wc -l)"

# CPU Usage
echo ""
echo "--- CPU Usage ---"
top -bn1 | grep "Cpu(s)" | awk '{printf "Used: %.1f%%  Idle: %.1f%%\n", 100-$8, $8}'

# Memory Usage
echo ""
echo "--- Memory Usage ---"
free -h | awk '/^Mem:/ {printf "Total: %s  Used: %s  Free: %s  Usage: %.1f%%\n", $2, $3, $4, $3/$2*100}'
free -h | awk '/^Swap:/ {if($2!="0B") printf "Swap:  Total: %s  Used: %s  Free: %s\n", $2, $3, $4}'

# Disk Usage
echo ""
echo "--- Disk Usage ---"
df -h --total -x tmpfs -x devtmpfs 2>/dev/null | grep -E '^/|^total' | \
  awk '{printf "%-20s Size:%-6s Used:%-6s Avail:%-6s Use:%s\n", $6, $2, $3, $4, $5}'

# Top 5 by CPU
echo ""
echo "--- Top 5 Processes by CPU ---"
ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "%-8s %5s%% %s\n", $2, $3, $11}'

# Top 5 by Memory
echo ""
echo "--- Top 5 Processes by Memory ---"
ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "%-8s %5s%% %s\n", $2, $4, $11}'

echo ""
echo "=========================="