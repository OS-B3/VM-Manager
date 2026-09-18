#!/bin/bash
export PATH=$PATH:"/c/Program Files/Oracle/VirtualBox"

print_header() {
    echo "==================================="
    echo "     TUGAS 1 OS - KELOMPOK B3      "
    echo "==================================="
}

list_vms() {
    print_header
    echo " Memindai daftar Virtual Machine..."
    echo "    "
    echo " Daftar VM terdaftar:"
    
    local count=1
    VBoxManage list vms | while read -r line; do
        vm_name=$(echo "$line" | awk -F '"' '{print $2}')
        if [ -n "$vm_name" ]; then
            echo "   $count. $vm_name"
            count=$((count + 1))
        fi
    done
    echo " "
}

info_vm() {
    local vm_name="$1"
    
    if [ -z "$vm_name" ]; then
        echo "Error: Nama VM harus diisi."
        echo "Penggunaan: $0 info <nama_vm>"
        exit 1
    fi

    if ! VBoxManage showvminfo "$vm_name" >/dev/null 2>&1; then
        echo "Error: Virtual Machine '$vm_name' tidak ditemukan."
        exit 1
    fi

    print_header
    echo "  VM    : $vm_name"

    local ram=$(VBoxManage showvminfo "$vm_name" --machinereadable | grep "^memory=" | cut -d'=' -f2)
    local vcpu=$(VBoxManage showvminfo "$vm_name" --machinereadable | grep "^cpus=" | cut -d'=' -f2)
    local state=$(VBoxManage showvminfo "$vm_name" --machinereadable | grep "^VMState=" | cut -d'=' -f2 | tr -d '"')

    if [ "$state" == "running" ]; then
        status_str="running"
    else
        status_str="powered off"
    fi

    echo "  RAM dialokasikan : $ram MB"
    echo "  vCPU dialokasikan : $vcpu"
    echo "  Status saat ini  : $status_str"
    echo " "
}

start_vm() {
    local vm_name="$1"

    if [ -z "$vm_name" ]; then
        echo "Error: Nama VM harus diisi."
        echo "Penggunaan: $0 start <nama_vm>"
        exit 1
    fi

    print_header
    echo "  Menyalakan VM '$vm_name' secara headless..."
    
    if VBoxManage startvm "$vm_name" --type headless >/dev/null 2>&1; then
        echo "  VM '$vm_name' berhasil dinyalakan. Status: running"
    else
        echo "  Gagal menyalakan VM '$vm_name' (mungkin VM sudah berjalan atau tidak ditemukan)."
    fi
    echo " "
}

stop_vm() {
    local vm_name="$1"

    if [ -z "$vm_name" ]; then
        echo "Error: Nama VM harus diisi."
        echo "Penggunaan: $0 stop <nama_vm>"
        exit 1
    fi

    print_header
    echo "  Mematikan VM '$vm_name' secara aman..."
    
    if VBoxManage controlvm "$vm_name" acpipowerbutton >/dev/null 2>&1; then
        echo "  VM '$vm_name' berhasil dimatikan. Status: powered off"
    else
        echo "  Gagal mematikan VM '$vm_name' (mungkin VM belum menyala)."
    fi
    echo " "
}

snapshot_create() {
    local vm_name="$1"
    local snapshot_name="$2"

    if [[ -z "$vm_name" || -z "$snapshot_name" ]]; then
        echo "Error: Format command salah."
        echo "Gunakan: $0 snapshot create <nama_vm> <nama_snapshot>"
        exit 1
    fi

    print_header
    echo "  Membuat snapshot '$snapshot_name' pada VM '$vm_name'..."

    if VBoxManage snapshot "$vm_name" take "$snapshot_name" >/dev/null 2>&1; then
        local timestamp
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "  Snapshot '$snapshot_name' berhasil dibuat pada $timestamp."
    else
        echo "  Gagal membuat snapshot. Pastikan nama VM '$vm_name' benar."
        exit 1
    fi
    echo " "
}

snapshot_list() {
    local vm_name="$1"

    if [[ -z "$vm_name" ]]; then
        echo "Error: Format command salah."
        echo "Gunakan: $0 snapshot list <nama_vm>"
        exit 1
    fi

    print_header
    echo "  Daftar snapshot VM '$vm_name':"

    local snapshots
    snapshots=$(VBoxManage snapshot "$vm_name" list 2>/dev/null | grep -oP '(?<=Name: )[^(]+' | sed 's/[[:space:]]*$//')

    if [[ -z "$snapshots" ]]; then
        echo "   (Belum ada snapshot pada VM ini)"
        echo " "
        return 0
    fi

    local i=1
    while IFS= read -r name; do
        echo "   $i. $name"
        ((i++))
    done <<< "$snapshots"
    echo " "
}

COMMAND="$1"
shift

case "$COMMAND" in
    list)
        list_vms
        ;;
    info)
        info_vm "$1"
        ;;
    start)
        start_vm "$1"
        ;;
    stop)
        stop_vm "$1"
        ;;
    snapshot)
        SUBCOMMAND="$1"
        shift
        case "$SUBCOMMAND" in
            create)
                snapshot_create "$1" "$2"
                ;;
            list)
                snapshot_list "$1"
                ;;
            *)
                echo "Error: Gunakan 'snapshot create' atau 'snapshot list'."
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Penggunaan: $0 {list|info|start|stop|snapshot}"
        exit 1
        ;;
esac
