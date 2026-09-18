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

# Ambil status dari hasil resource_check
memory_status=$(echo "$result" | awk '/Metric 1/ {print $NF}')
load_status=$(echo "$result" | awk '/Metric 2/ {print $NF}')

# Ambil informasi sistem untuk laporan
os_info=$(get_os_info)
users=$(get_regular_users)
processes=$(get_running_processes)
virtualization=$(get_virtualization)

# Status virtualisasi
if [[ "$virtualization" == *"Terdeteksi"* ]]; then
    virt_status="PASS"
else
    virt_status="FAIL"
fi

# Membuat laporan
report_file="sysinfo_report.txt"

{
    echo "================================================================================"
    echo "                        TUGAS 1 OS - KELOMPOK B3"
    echo "================================================================================"

    printf "%-18s | %-25s | %-8s | %s\n" \
        "Check Category" "Item" "Status" "Details"

    echo "--------------------------------------------------------------------------------"

    printf "%-18s | %-25s | %-8s | %s\n" \
        "OS" "$os_info" "PASS" "OS dan Kernel"

    printf "%-18s | %-25s | %-8s | %s\n" \
        "Users" "$users akun" "PASS" "Regular accounts"

    printf "%-18s | %-25s | %-8s | %s\n" \
        "Processes" "$processes proses" "PASS" "Running processes"

    printf "%-18s | %-25s | %-8s | %s\n" \
        "Virtualization" "$virtualization" "$virt_status" "Hypervisor"

    printf "%-18s | %-25s | %-8s | %s\n" \
        "Memory" "$memory_usage%" "$memory_status" "Memory usage"

    printf "%-18s | %-25s | %-8s | %s\n" \
        "Load/Core" "$load_ratio" "$load_status" "Load $load_average / $cores cores"

    echo "================================================================================"

} > "$report_file"

echo ""
echo "Menyimpan laporan ke $report_file..."
echo "Laporan berhasil disimpan."