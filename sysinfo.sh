#!/bin/bash

get_os_info(){
    local pretty_name kernel
    pretty_name=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
    kernel=$(uname -r)
    echo "$pretty_name (Kernel $kernel)"
}

get_regular_users(){
    awk -F: '$3 >= 1000 && $3 <6000 {count++} END {print count+0}' /etc/passwd
}

get_running_processes(){
    ps -e --no-headers | wc -l
}

get_virtualization(){
    local virt
    virt=$(systemd-detect-virt 2>/dev/null)
    case "$virt" in
        oracle) echo "Terdeteksi (VirtualBox)" ;;
        none|"") echo "Tidak terdeteksi (kemungkinan mesin fisik)" ;;
        *) echo "Terdeteksi ($virt)";; 
    esac
}

echo "OS/Kernel: $(get_os_info)"
echo "Akun pengguna: $(get_regular_users) akun"
echo "Prose berjalan: $(get_running_processes) proses"
echo "Virtualisasi: $(get_virtualization)"

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