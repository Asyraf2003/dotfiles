# 💻 Dotfiles: The Asyraf Dev-Ops Minimalist Setup

Selamat datang di repositori dotfiles saya! Ini adalah blueprint untuk setup Arch Linux minimalis saya, dirancang untuk **kecepatan, kontrol keyboard penuh, dan efisiensi tingkat programmer**.

Jika Anda suka terminal, *keybind*, dan menghindari *bloatware*, ini adalah *setup* yang tepat.

## 🚀 Filosofi Setup

Setup ini bertujuan untuk menciptakan lingkungan kerja yang:

* **Keyboard-Centric:** Menggunakan *keybind* Openbox dan *script* `~/bin` untuk menjalankan semua fungsi sistem, menghindari penggunaan mouse.
* **Zero-Bloat:** Hanya menginstal program yang mutlak dibutuhkan.
* **Instan:** Waktu *loading* aplikasi (terutama Alacritty) harus mendekati nol.

## ✨ Komponen Inti

| Komponen | Tujuan | Config File/Location |
| :--- | :--- | :--- |
| **Window Manager** | Openbox (Ringan dan Konfigurasi Penuh) | `openbox/rc.xml` |
| **Terminal Emulator** | Alacritty (Akselerasi GPU, Ultra-Cepat) | `alacritty/` |
| **Shell** | Bash (dengan *aliases* dan *function* kustom) | `.bashrc` |
| **Keybind Scripts** | Skrip utilitas harian (*reboot*, *vpn*, dll.) | `bin/` |
| **Notifikasi** | Dunst (Notifikasi Minimalis) | `dunst/` |

---

## 🛠️ Proses Instalasi Cepat (Full Automation Mode)

Setelah instalasi Arch dasar selesai, ikuti langkah-langkah ini:

### 1. Kloning dan Instal Paket Dasar

Pastikan Anda memiliki `git` dan AUR Helper (misalnya `yay` atau `paru`) terinstal.

#### Kloning Repositori

# Kloning dotfiles ke home directory

```bash
git clone [https://github.com/Asyraf2003/dotfiles.git](https://github.com/Asyraf2003/dotfiles.git) ~/dotfiles
```
Instalasi Paket Resmi (Pacman)
```Bash
sudo pacman -S --needed - < ~/dotfiles/pkglist_pacman.txt
```
Instalasi Paket AUR (yay/paru)

# Jika ada paket dari AUR, jalankan ini
```Bash
yay -S --needed - < ~/dotfiles/pkglist_aur.txt
```
2. Membuat Symlink (Mengaktifkan Konfigurasi)
Langkah ini membuat tautan simbolik dari file konfigurasi Anda di folder ~/dotfiles kembali ke lokasi aslinya (~/.config/).

```Bash

cd ~
```
Creating Symlinks...

# Configs Utama
```Bash
ln -s ~/dotfiles/.bashrc ~/.bashrc
ln -s ~/dotfiles/openbox ~/.config/openbox
ln -s ~/dotfiles/alacritty ~/.config/alacritty
ln -s ~/dotfiles/dunst ~/.config/dunst
ln -s ~/dotfiles/htop ~/.config/htop
ln -s ~/dotfiles/yay ~/.config/yay
ln -s ~/dotfiles/bin ~/bin
```

Symlink Complete Yeaayyy!"

3. Selesai dan Reboot
Setelah semua symlink dibuat, logout dan login kembali, atau reboot sistem Anda agar konfigurasi Openbox, Bash, dan Alacritty yang baru dapat dimuat.

```Bash

# Perintah terakhir
systemctl reboot
```

