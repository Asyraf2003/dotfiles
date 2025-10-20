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

# Kloning dotfiles ke home directory
Bash

```bashecho git clone [https://github.com/Asyraf2003/dotfiles.git](https://github.com/Asyraf2003/dotfiles.git) ~/dotfiles
```

# Instal paket resmi (pacman)
# Perintah ini akan menginstal semua tools utama (Openbox, Alacritty, Dunst, dsb.)
```sudo pacman -S --needed - < ~/dotfiles/pkglist_pacman.txt
```

# Instal paket AUR (yay)
# Jika ada paket dari AUR, jalankan ini
```yay -S --needed - < ~/dotfiles/pkglist_aur.txt
```

```cd ~
```

echo "Creating Symlinks..."

# Configs Utama
```ln -s ~/dotfiles/.bashrc ~/.bashrc
ln -s ~/dotfiles/openbox ~/.config/openbox
ln -s ~/dotfiles/alacritty ~/.config/alacritty
ln -s ~/dotfiles/dunst ~/.config/dunst
ln -s ~/dotfiles/htop ~/.config/htop
ln -s ~/dotfiles/yay ~/.config/yay
ln -s ~/dotfiles/bin ~/bin
```
echo "Symlink Complete Yeaayyy! Time to reboot."
