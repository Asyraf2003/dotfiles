# 💻 Dotfiles: Asyraf Dev-Ops Minimalist Setup

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

## ⌨️ Keybinds & Aliases

Setup ini sangat bergantung pada pintasan keyboard (keybind) Openbox dan alias Bash kustom Anda (di `~/.bashrc` dan *script* `~/bin`).

| Kategori | Keybind / Alias | Perintah | Fungsi |
| :--- | :--- | :--- | :--- |
| **Aplikasi Utama** | `W + Return` | `alacritty` | Buka Terminal |
| | `W + B` | `brave-browser` | Buka Brave Browser |
| | `W + V` | `code` | Buka VS Code |
| | `W + S` | `spotify` | Buka Spotify |
| | `W + C` | `cheese` | Buka Kamera |
| | `W + O` | `obs` | Buka OBS Studio |
| | `W + F` | `thunar` | Buka File Manager |
| **Sistem** | `W + R` | `openbox --reconfigure` | Restart Openbox (reload config) |
| | `W + Q` | `systemctl poweroff` | Matikan Komputer |
| | `W + D` | `toggle_show_desktop` | Tampilkan Desktop |
| | `A + F4` | `kill` | Tutup Jendela Aktif |
| **Navigasi Jendela** | `A + Space` | `ShowMenu` | Buka Menu Jendela |
| | `A + Tab` / `A + S + Tab` | `CycleWindows` | Pindah Antar Jendela |
| | `W + Arrow` | `ResizeToHalfScreen` | Geser Jendela Setengah Layar |
| | `W + S + Arrow` | `MoveToCorner` | Geser Jendela ke Pojok |
| **Desktop** | `C + A + Arrow` | `DesktopSwitch` | Pindah Antar Desktop |
| | `S + A + Arrow` | `SendToDesktop` | Kirim Jendela ke Desktop Lain |
| **Screenshot** | `Print` | `screenshot-full` | Screenshot Penuh |
| | `A + Print` | `screenshot-window` | Screenshot Jendela Aktif |
| | `S + Print` | `screenshot-area` | Screenshot Area Tertentu |

### 🔨 Skrip Kustom & Aliases (Scripts in `~/bin/` & `.bashrc`)

| Kategori | Perintah (Alias/Script) | Fungsi | Lokasi |
| :--- | :--- | :--- | :--- |
| **VPN (WireGuard)** | `vpn-on` | N/A | Aktifkan ProtonVPN (WireGuard) |
| | `vpn-off` | N/A | Matikan ProtonVPN & pulihkan DNS |
| **Bluetooth (Script `bt`)** | `bt on/off` | N/A | Nyalakan/matikan Bluetooth |
| | `bt connect MAC` | N/A | Hubungkan ke perangkat Bluetooth |
| | `bt trust MAC` | N/A | Tandai perangkat agar *auto connect* |
| **Wi-Fi (Script `wifi`)** | `wifi on/off` | N/A | Aktif/nonaktif Wi-Fi |
| | `wifi connect "SSID" [PASS]` | N/A | Sambung ke jaringan Wi-Fi |
| | `wifi status` | N/A | Lihat status koneksi Wi-Fi |
| **Perawatan Sistem** | `update` | `sudo pacman -Syu` | Update sistem Arch |
| | `cleanpkg` | `sudo pacman -Scc` | Bersihkan *cache* paket |
| | `btr` | N/A | Cek status baterai |
| | `lsd` | N/A | List direktori detail (*alias* `ls -l` custom) |
| **Database** | `mariastart` | N/A | Jalankan MySQL/phpMyAdmin |
| | `mariastop` | N/A | Matikan MySQL/phpMyAdmin |
| **Lain-lain** | `helpme` | N/A | Tampilkan catatan *keybind* ini |
| | `livewall [file/--stop]` | N/A | Kelola Live Wallpaper |

---

## 🌐 Network Info

Informasi jaringan penting untuk setup ini (biasanya dikonfigurasi di *script* `vpn-on/off`):

* **Interface Wi-Fi:** `wlp2s0`
* **Gateway:** `192.168.8.1`
* **DNS Default:** `8.8.8.8, 1.1.1.1`
* **IPv6:** `disabled`
  
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
Langkah ini membuat tautan simbolik dari file konfigurasi Anda di folder ```~/dotfiles kembali ke lokasi aslinya (~/.config/).```

```Bash

cd ~
```
Creating Symlinks...

# Configs Utama
```Bash
ln -s ~/dotfiles/.bashrc ~/.bashrc
ln -s ~/dotfiles/openbox ~/.config/openbox
ln -s ~/dotfiles/alacritty ~/.config/alacritty
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

