# VM-Manager

# README Bagian Dyah
## 1. Snapshot (vm_ctl.sh — HOST)

```bash
./vm_ctl.sh snapshot create <nama_vm> <nama_snapshot>
./vm_ctl.sh snapshot list <nama_vm>
```

`snapshot create` validasi input, lalu nantinya memanggil `VBoxManage snapshot <vm> take <nama>` untuk create snapshot baru dan menampilkan konfirmasi & waktu pembuatan. `snapshot list` memanggil `VBoxManage snapshot <vm> list`, filter nama-nama snapshot dari output mentahnya, lalu ditampilkan dalam format yang bernomor.

**Contoh:**
```
$ ./vm_ctl.sh snapshot create OS262-Base-Image-amd64 tes-2
  Membuat snapshot 'tes-2' pada VM 'OS262-Base-Image-amd64'...
  Snapshot 'tes-2' berhasil dibuat pada 2026-09-13 19:40:00.

$ ./vm_ctl.sh snapshot list OS262-Base-Image-amd64
  Daftar snapshot VM 'OS262-Base-Image-amd64':
    1. tes-1
    2. tes-2
```

**Contoh error (input kurang):**
```
$ ./vm_ctl.sh snapshot create OS262-Base-Image-amd64
Error: format command salah.
Gunakan: ./vm_ctl.sh snapshot create <nama_vm> <nama_snapshot>
```

## 2. Basic System Information (sysinfo.sh -> GUEST)

```bash
./sysinfo.sh
```

Bagian saya, sysinfo berfokus mengecek 4 hal dasar yang diwajibkan tugas: info OS & kernel (dari `/etc/os-release` dan `uname -r`), jumlah akun pengguna biasa (dari `/etc/passwd`, UID 1000–59999 supaya akun sistem tidak ikut terhitung), jumlah proses berjalan (`ps -e`), dan deteksi virtualisasi (`systemd-detect-virt`, hasil `oracle` berarti VirtualBox). Keempatnya dapat menjadi bukti bahwa environment yang diperiksa memang VM Ubuntu yang sehat sebelum nantinya digabung dengan hasil Metric 1 & 2 (Bagian Lalita).

**Contoh output:**
```
$ ./sysinfo.sh
  OS/Kernel        : Ubuntu 26.04 LTS (Kernel 7.0.0-30-generic)
  Akun pengguna    : 2 akun
  Proses berjalan  : 136 proses
  Virtualisasi     : Terdeteksi (VirtualBox)
```
