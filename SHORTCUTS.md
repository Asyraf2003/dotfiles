# Shortcuts

Referensi command dan shortcut untuk dotfiles Arch Linux.

Dokumen ini sedang dimigrasikan secara bertahap. Hanya command yang sudah ditemukan pada repository atau konfigurasi aktif yang dicantumkan. Detail opsi akan dilengkapi setelah setiap script dan konfigurasi Openbox selesai diaudit.

## Shell

| Command | Fungsi |
|---|---|
| `helpme` | Membuka dokumen ini |
| `lg` | Menjalankan LazyGit jika tersedia |
| `vim` | Menjalankan Neovim jika tersedia |
| `nvim help` | Membuka bantuan Neovim lokal jika script tersedia |

## Script CLI

| Command | Profil |
|---|---|
| `bt` | Core atau Openbox |
| `wifi` | Core |
| `clean-system` | Maintenance |
| `maria` | Development |
| `nvim-help` | Development |
| `bat` | Laptop |
| `pc-health` | Laptop atau hardware |
| `tune-laptop.sh` | Laptop |
| `livewp` | Display opsional |
| `vpn` | VPN opsional |

Script yang menggunakan `sudo`, hardware, service, jaringan, atau VPN harus diaudit sebelum dianggap portable.

## Profil Bash

Modul Bash tersedia berdasarkan profil:

- `core`
- `dev`
- `laptop`
- `display`

Alias project pribadi tidak disimpan di repository public. Credential, token, password, endpoint pribadi, dan data jaringan lokal tidak dicantumkan di dokumen ini.

## Openbox

Shortcut Openbox akan ditambahkan setelah konfigurasi aktif `rc.xml` dibandingkan dengan repository.

Jangan memakai daftar shortcut lama sebagai sumber kebenaran sebelum audit tersebut selesai.
