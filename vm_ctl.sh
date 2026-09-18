#!/bin/bash
VM_NAME="OS262-Base-Image-amd64"

snapshot_create() {
        local vm_name="$1"
        local snapshot_name="$2"

        if [[ -z "$vm_name" || -z "$snapshot_name" ]]; then
                echo "Error: format command salah."
                echo "Gunakan: ./vm_ctl.sh snapshot create <nama_vm> <nama_snapshot>"
                return 1
        fi
        echo "Membuat snapshot '$snapshot_name' pada VM '$vm_name'..."

        if VBoxManage.exe snapshot "$vm_name" take "$snapshot_name" > /dev/null 2>&1; then
                local timestamp
                timestamp=$(date '+%Y-%m-%d %H:%M:%S')
                echo "Snapshot '$snapshot_name' berhasil dibuat pada $timestamp."
        else
                echo "Gagal membuat snapshot. Pastikan nama VM '$vm_name' benar dan VM terdaftar."
                return 1
        fi
}

snapshot_list() {
    local vm_name="$1"

    if [[ -z "$vm_name" ]]; then
        echo "Error: format command salah."
        echo "Gunakan: ./vm_ctl.sh snapshot list <nama_vm>"
        return 1
    fi

    local snapshots
    snapshots=$(VBoxManage.exe snapshot "$vm_name" list 2>/dev/null | grep -oP '(?<=Name: )[^(]+' | sed 's/[[:space:]]*$//')

    if [[ -z "$snapshots" ]]; then
        echo "  VM '$vm_name' belum punya snapshot."
        return 0
    fi

    echo "  Daftar snapshot VM '$vm_name':"
    local i=1
    while IFS= read -r name; do
        echo "    $i. $name"
        ((i++))
    done <<< "$snapshots"
}

case "$1" in
    snapshot)
        case "$2" in
            create) snapshot_create "$3" "$4" ;;
            list)   snapshot_list "$3" ;;
            *) echo "Error: gunakan 'snapshot create' atau 'snapshot list'." ;;
        esac
        ;;
    *)
        echo "Usage: ./vm_ctl.sh snapshot {create|list} ..."
        ;;
esac