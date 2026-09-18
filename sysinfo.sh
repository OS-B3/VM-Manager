#!/bin/bash

# Metric 1: Memory Usage
total=$(free -m | awk '/Mem:/ {print $2}')
available=$(free -m | awk '/Mem:/ {print $7}')

# Ini rumusnya perlu di cross-check lagi karena gak diinfoin persis di Brief
memory_usage=$(awk "BEGIN {printf \"%.2f\", (($total - $available) / $total) * 100}")

echo "Memory Usage: $memory_usage%"

# Metric 2: Load Average vs Number of Cores
load_average=$(awk '{print $1}' /proc/loadavg)
cores=$(nproc)

load_ratio=$(awk "BEGIN {printf \"%.2f\", $load_average / $cores}")

echo "Load Average: $load_average"
echo "CPU Cores: $cores"
echo "Load/Core Ratio: $load_ratio"

# Send metrics to resource_check
result=$(echo "$memory_usage $load_ratio" | ./resource_check)

echo "$result"