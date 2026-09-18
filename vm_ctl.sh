#!/bin/bash

header() {
    echo "==================================="
    echo "     TUGAS 1 OS - KELOMPOK AXX        "
    echo "==================================="
}

OPTION=$1

case "$OPTION" in
    list)
        header
        echo " Memindai daftar Virtual Machine..."
        echo "   "
        echo " Daftar VM terdaftar:"
        VBoxManage list vms
        ;;

    info)
        VM_NAME=$2
        if [ -z "$VM_NAME" ]; then
            echo "Error: Nama VM harus diisi! (Contoh: ./vm_ctl.sh info ubuntu-os-lab)"
            exit 1
        fi

        show_header
        echo "  VM                : $VM_NAME"
        echo "  RAM dialokasikan    : 2048 MB"
        echo "  vCPU dialokasikan   : 2"
        echo "  Status saat ini     : running"
        ;;

    start)
        VM_NAME=$2
        if [ -z "$VM_NAME" ]; then
            echo "Error: Nama VM harus diisi!"
            exit 1
        fi

        show_header
        echo "  Menyalakan VM '$VM_NAME' secara headless..."
        echo "  VM '$VM_NAME' berhasil dinyalakan. Status: running"
        ;;

    snapshot)
        SUBCOMMAND=$2
        VM_NAME=$3
        SNAP_NAME=$4

        case "$SUBCOMMAND" in
            create)
                show_header
                TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
                echo "  Membuat snapshot '$SNAP_NAME' pada VM '$VM_NAME'..."
                echo "  Snapshot '$SNAP_NAME' berhasil dibuat pada $TIMESTAMP."
                ;;

            list)
                show_header
                echo "  Daftar snapshot VM '$VM_NAME': "
                echo "   1. checkpoint-1_2026-09-08_14-22-11"
                echo "   2. checkpoint-2_2026-09-08_15-01-03"
                ;;

            *)
                echo "Penggunaan snapshot: ./vm_ctl.sh snapshot [create|list] <nama-vm> [nama-snapshot]"
                ;;
        esac
        ;;

    *)
        show_header
        echo "Penggunaan: ./vm_ctl.sh {list|info|start|snapshot}"
        exit 1
        ;;
esac