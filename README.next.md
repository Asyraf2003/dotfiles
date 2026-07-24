# Asyraf Arch Linux Dotfiles

Dotfiles pribadi untuk memulihkan workflow Arch Linux setelah instalasi sistem dasar selesai.

Repository ini berfokus pada konfigurasi yang dapat dipindahkan antar-PC:

* Bash dan command aliases
* Openbox dan keyboard shortcuts
* Neovim
* Terminal
* Notification daemon
* Script CLI pribadi
* Package manifest
* Profil opsional untuk laptop, development, VPN, dan tampilan

Repository ini tidak dimaksudkan untuk mengotomatiskan seluruh instalasi Arch Linux atau menyalin konfigurasi hardware secara membabi buta.

## Status

Migrasi dotfiles sedang berlangsung.

Saat ini beberapa konfigurasi sudah memakai symlink, sementara konfigurasi lain masih berada langsung di `$HOME`.

Symlink yang sudah aktif:

```text
~/bin                           -> ~/.dotfiles/bin
~/.config/openbox/autostart     -> ~/.dotfiles/openbox/autostart
~/.config/openbox/environment   -> ~/.dotfiles/openbox/environment
```

Installer dan struktur profil belum final. Jangan menganggap `bootstrap.sh` saat ini aman untuk semua komputer sebelum proses hardening selesai.

## Yang Tetap Dilakukan Manual

Instalasi dasar Arch tetap dilakukan manual atau memakai installer Arch yang dipilih sendiri.

Bagian berikut tidak dikelola langsung oleh dotfiles:

* Partisi disk
* Format filesystem
* Mount point
* Bootloader
* Kernel
* Initramfs
* Microcode CPU
* Driver GPU
* Hostname
* User account
* Password
* Konfigurasi awal `sudo`
* UUID dan `/etc/fstab`
* Secure Boot
* Konfigurasi display yang sangat spesifik
* Private key dan credential

Dotfiles digunakan setelah sistem dapat boot, user sudah dibuat, jaringan aktif, dan Git tersedia.

## Rencana Profil Instalasi

### Core

Profil yang seharusnya aman pada hampir semua instalasi Arch milik saya.

Mencakup:

* Bash
* Git
* tmux
* Neovim
* Terminal
* Script `helpme`
* Script Wi-Fi dan Bluetooth
* Package utilities dasar
* Symlink konfigurasi utama

### Openbox

Profil desktop X11 berbasis Openbox.

Mencakup:

* Openbox
* Alacritty
* Dunst
* Thunar
* PipeWire
* Shortcut aplikasi
* Screenshot tools
* Window management tools

Konfigurasi resolusi tetap seperti `1920x1080` harus diganti dengan logic yang mendeteksi ukuran layar sebelum profil ini dianggap portable.

### Laptop

Profil khusus perangkat dengan baterai.

Mencakup:

* `bat`
* `tune-laptop.sh`
* `acpi`
* `brightnessctl`
* CPU power management
* Battery threshold jika hardware mendukung

Profil ini tidak boleh dipasang otomatis pada desktop.

### Development

Profil development tambahan.

Mencakup fitur yang dipilih sesuai kebutuhan:

* PHP
* Composer
* Node.js dan npm
* PostgreSQL
* MariaDB
* Nginx
* Docker
* LazyGit
* LazyDocker
* DBeaver
* Go tooling

Database dan Docker bersifat opsional. Service tidak boleh otomatis diaktifkan hanya karena paketnya terpasang.

### VPN

Profil WireGuard pribadi.

Mencakup:

* `wireguard-tools`
* Script `vpn`
* Dokumentasi lokasi config

Tidak mencakup:

* WireGuard private key
* File `/etc/wireguard/*.conf`
* Password
* Endpoint rahasia
* Credential provider

Profil ini memerlukan review khusus karena dapat mengubah route, DNS, interface jaringan, MTU, dan status IPv6.

### Display

Profil khusus monitor dan HDMI.

Mencakup:

* `display-menu`
* Shortcut HDMI
* Konfigurasi monitor eksternal

Konfigurasi nama output seperti `HDMI-*` dan `eDP-*` harus dideteksi pada mesin tujuan.

### Live Wallpaper

Profil tampilan opsional.

Mencakup:

* `livewp`
* `mpv`
* X11 root-window utilities
* Path wallpaper yang dapat dikonfigurasi

Media wallpaper tidak wajib disimpan di repository.

## Script CLI

| Script           | Fungsi                                 |         Profil |     Sudo | Catatan                            |
| ---------------- | -------------------------------------- | -------------: | -------: | ---------------------------------- |
| `bat`            | Menampilkan status baterai             |         Laptop |    Tidak | Membaca `/sys/class/power_supply`  |
| `bt`             | Mengelola Bluetooth                    |   Core/Openbox |    Tidak | Memerlukan `bluetoothctl`          |
| `clean-system`   | Membersihkan cache dan journal         |    Maintenance | Sebagian | Perlu dibuat lebih konservatif     |
| `helpme`         | Menampilkan dokumentasi shortcut       |           Core |    Tidak | Dapat memakai `glow` atau `bat`    |
| `livewp`         | Menjalankan live wallpaper             | Live wallpaper |    Tidak | Memerlukan X11 dan `mpv`           |
| `maria`          | Start, stop, dan status web stack      |    Development |       Ya | MariaDB, PHP-FPM, dan Nginx        |
| `nvim-help`      | Dokumentasi workflow Neovim            |    Development |    Tidak | Bukan dependency Neovim            |
| `pc-health`      | Membaca kesehatan NVMe                 |       Hardware |       Ya | Saat ini menganggap `/dev/nvme0n1` |
| `tune-laptop.sh` | Mengatur CPU dan baterai               |         Laptop |       Ya | Sangat tergantung hardware         |
| `vpn`            | Mengelola WireGuard                    |            VPN |       Ya | Mengubah networking sistem         |
| `wifi`           | Mengelola Wi-Fi melalui NetworkManager |           Core |    Tidak | Memerlukan `nmcli`                 |

## Command Sudo

Tidak semua command `sudo` memiliki tingkat risiko yang sama.

### Pemeliharaan Rutin

#### Update sistem

```bash
sudo pacman -Syu
```

Fungsi:

* Sinkronisasi database package
* Upgrade semua package

Status: direkomendasikan.

Jangan mengganti command ini dengan `sudo pacman -Sy` tanpa upgrade karena dapat menyebabkan partial upgrade.

#### Membersihkan journal lama

```bash
sudo journalctl --vacuum-time=3d
```

Fungsi:

* Menghapus journal systemd yang lebih lama dari tiga hari

Status: opsional dan relatif aman.

#### Membersihkan cache Pacman secara terkendali

```bash
sudo paccache -rk2
sudo paccache -ruk0
```

Fungsi:

* Menyimpan dua versi terakhir package terpasang
* Menghapus cache package yang sudah tidak terpasang

Status: direkomendasikan untuk maintenance.

Memerlukan package:

```text
pacman-contrib
```

### Development Service

#### MariaDB stack

```bash
sudo systemctl start mariadb.service
sudo systemctl start php-fpm.service
sudo systemctl start nginx.service
```

Fungsi:

* Menjalankan local PHP web stack

Status: opsional, hanya untuk profil development.

Service sebaiknya dijalankan saat dibutuhkan, bukan selalu diaktifkan saat boot.

#### Docker

```bash
sudo systemctl enable --now docker.service
sudo systemctl enable --now containerd.service
```

Fungsi:

* Mengaktifkan Docker saat boot
* Menjalankan Docker langsung

Status: opsional.

Installer tidak boleh menjalankan command ini tanpa pilihan eksplisit pengguna.

### Laptop dan Hardware

#### Laptop tuning

```bash
sudo tune-laptop.sh
sudo tune-laptop.sh --mode perf --bat 80
sudo tune-laptop.sh --mode save --bat 70
sudo tune-laptop.sh --status
```

Fungsi:

* Mengatur CPU governor
* Mengatur energy performance preference
* Mengatur battery charge threshold jika didukung
* Me-restart service power management

Status: khusus laptop.

Risiko:

* Tidak semua laptop memiliki path battery threshold yang sama
* Tidak semua CPU memakai driver yang sama
* `tlp`, `cpupower`, dan `power-profiles-daemon` dapat saling bertabrakan

Script wajib mendeteksi hardware dan service sebelum melakukan perubahan.

#### NVMe health

```bash
sudo nvme smart-log /dev/nvme0n1
```

Fungsi:

* Membaca temperatur
* Membaca persentase usia pakai NVMe

Status: opsional.

Risiko:

* Nama device belum tentu `/dev/nvme0n1`
* Mesin mungkin memakai SATA SSD, eMMC, atau beberapa NVMe

Script harus mendeteksi device, bukan mengunci satu path.

### VPN dan Networking

Script VPN dapat menjalankan operasi berikut:

```bash
sudo wg-quick up
sudo wg-quick down
sudo ip route replace
sudo ip route del
sudo ip link set
sudo ip link del
sudo sysctl -w
```

Script juga dapat menyentuh:

```text
/etc/wireguard
/etc/resolv.conf
/run/wireguard
```

Fungsi:

* Membuat interface WireGuard
* Mengubah route
* Mengubah MTU
* Mengubah DNS
* Menonaktifkan atau mengaktifkan IPv6
* Mengatur permission file WireGuard

Status: opsional dan berisiko tinggi.

Script ini tidak boleh menjadi bagian dari instalasi core. Penggunaan harus dilakukan setelah config VPN diperiksa pada mesin tujuan.

## Command yang Tidak Direkomendasikan untuk Otomatisasi

### Drop kernel cache

```bash
echo 3 | sudo tee /proc/sys/vm/drop_caches
```

Ini biasanya tidak perlu untuk pemakaian normal. Linux menggunakan RAM kosong sebagai cache dengan sengaja, bukan karena ia sedang panik.

Status: hapus dari maintenance default atau jadikan opsi manual.

### Menghapus seluruh cache Pacman

```bash
sudo pacman -Scc
```

Ini menghapus seluruh package cache dan mengurangi kemampuan rollback.

Status: manual saja.

### Partial upgrade

```bash
sudo pacman -Sy
```

Status: jangan digunakan sendiri.

Gunakan:

```bash
sudo pacman -Syu
```

### Menghapus semua package lib32

```bash
sudo pacman -Rns $(pacman -Qq | grep '^lib32-')
```

Status: jangan diotomatisasi.

Package `lib32` mungkin dibutuhkan Wine, Steam, driver, atau aplikasi lain.

### Menghapus orphan tanpa review

```bash
sudo pacman -Rns $(pacman -Qdtq)
```

Status: review daftar terlebih dahulu.

Gunakan:

```bash
pacman -Qdt
```

sebelum menghapus apa pun.

## Package Manifest

Target akhir repository:

```text
packages/
├── core.txt
├── openbox.txt
├── laptop.txt
├── dev.txt
└── aur.txt
```

Aturan:

* Package repository resmi hanya masuk file profil resmi
* Package AUR hanya masuk `aur.txt`
* Package hardware masuk profil terkait
* Package development tidak dipasang bersama core
* Package besar tidak dipasang tanpa pilihan eksplisit

File lama:

```text
pkglist_pacman.txt
pkglist_pacman_repo.txt
pkglist_aur.txt
```

harus diaudit dan diganti setelah klasifikasi package selesai.

## Target Symlink

Setelah installer selesai, target berikut akan dikelola repository:

```text
~/.bashrc                         -> ~/.dotfiles/core/bash/bashrc
~/.bash_profile                  -> ~/.dotfiles/core/bash/bash_profile
~/.gitconfig                     -> ~/.dotfiles/core/git/gitconfig
~/.tmux.conf                     -> ~/.dotfiles/core/tmux/tmux.conf
~/.xinitrc                       -> ~/.dotfiles/core/x11/xinitrc

~/bin                            -> ~/.dotfiles/bin

~/.config/alacritty              -> ~/.dotfiles/config/alacritty
~/.config/kitty                  -> ~/.dotfiles/config/kitty
~/.config/nvim                   -> ~/.dotfiles/config/nvim
~/.config/dunst                  -> ~/.dotfiles/config/dunst
~/.config/openbox                -> ~/.dotfiles/config/openbox
```

Installer harus:

1. Memeriksa sumber dan tujuan
2. Tidak menimpa file tanpa backup
3. Membuat satu snapshot
4. Menggunakan symlink absolut atau relatif secara konsisten
5. Dapat dijalankan ulang
6. Melaporkan konflik
7. Memiliki mode dry-run
8. Memiliki rollback

## Data Rahasia

Jangan commit:

```text
SSH private keys
GPG private keys
GitHub tokens
API keys
.env
Wi-Fi passwords
VPN private keys
WireGuard config
Database dump
Browser profiles
Cloud credentials
Docker registry credentials
npm tokens
Composer auth.json
```

File berikut harus diperiksa atau diabaikan:

```text
~/.ssh/
~/.gnupg/
~/.config/github-copilot/
~/.config/gcloud/
~/.aws/
~/.docker/config.json
~/.npmrc
~/.config/composer/auth.json
/etc/wireguard/
```

## Alur PC Baru

Setelah installer final tersedia, urutan setup adalah:

1. Install Arch Linux dasar
2. Buat user dan konfigurasi `sudo`
3. Sambungkan jaringan
4. Install Git
5. Clone repository ke `~/.dotfiles`
6. Jalankan dry-run installer
7. Pasang profil core
8. Login ulang dan verifikasi shell
9. Pasang profil Openbox
10. Pilih profil tambahan
11. Tambahkan credential secara manual
12. Reboot setelah seluruh verifikasi lolos

## Verifikasi

Setelah pemasangan:

```bash
readlink -f ~/bin
readlink -f ~/.bashrc
readlink -f ~/.config/nvim
readlink -f ~/.config/openbox
```

Periksa command:

```bash
command -v nvim
command -v nmcli
command -v bluetoothctl
command -v alacritty
command -v openbox
```

Periksa service:

```bash
systemctl --user status pipewire
systemctl --user status wireplumber
```

## Prinsip Repository

* Core harus kecil
* Hardware harus bersifat conditional
* Service berat harus opsional
* Credential tidak boleh masuk Git
* Config aktif harus berasal dari repository
* Tidak ada symlink yang dibuat diam-diam
* Tidak ada command destruktif tanpa review
* Semua perubahan harus dapat dipulihkan
