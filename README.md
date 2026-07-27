# Asyraf Arch Linux Dotfiles

Dotfiles publik untuk lingkungan Arch Linux minimal berbasis Openbox.

Repository ini menyimpan konfigurasi yang aman dipublikasikan dan dapat
digunakan kembali saat setup PC. Credential, key, session, cache, serta
konfigurasi private tetap berada di luar repository ini.

## Komponen

- Bash
- Git
- Openbox
- Alacritty
- Neovim
- tmux
- script maintenance dan laptop
- package profiles
- command `dot`
- bootstrap wrapper

## Command Dot

```text
dot doctor
dot status
dot install [--dry-run|--apply] [--aur] PROFILE...
dot link [--dry-run|--apply]
dot rollback [--dry-run|--apply]
dot help
```

Operasi yang dapat mengubah sistem menggunakan dry-run secara default.

## Package Profiles

Profile yang dapat digunakan:

```text
core
openbox
laptop
dev
display
vpn
live-wallpaper
optional
```

Profile berikut tidak dijalankan otomatis:

```text
manual-system
legacy-disabled
manual-bootstrap
```

AUR hanya diproses ketika `--aur` digunakan secara eksplisit.

## Bootstrap

`bootstrap.sh` adalah wrapper untuk `bin/dot`.

Default:

```text
dry-run core
```

Contoh:

```bash
./bootstrap.sh
./bootstrap.sh --dry-run core
./bootstrap.sh --apply core
```

Bootstrap tidak mengaktifkan service secara otomatis.

## Setup Awal

```bash
git clone <URL_REPOSITORY_PUBLIC> ~/.dotfiles
cd ~/.dotfiles

bin/dot doctor
bin/dot status
bin/dot install core
bin/dot link
```

Periksa hasil dry-run sebelum menggunakan `--apply`.

## Private Overlay

Konfigurasi private dapat dimuat dari:

```text
~/.dotfiles-private/shell/private.bash
```

Repository publik hanya mengecek atau melakukan source terhadap path tersebut.
Isi private overlay tidak disimpan atau dicetak oleh repository publik.

Data berikut harus tetap lokal:

- password dan token;
- SSH dan GPG keys;
- OAuth dan credential aplikasi;
- WireGuard private key;
- shell history dan session;
- cache dan data runtime.

## Dokumentasi

- `MIGRATION_STATUS.md`: status dan bukti migrasi.
- `SHORTCUTS.md`: shortcut dan command aktif.
- `packages/PROFILE_POLICY.md`: aturan package profile.
- `packages/CORE_DECISION.md`: keputusan profile core.
- `README.next.md`: draft historis migrasi.
- `CHANGELOG.md`: catatan historis.

## Aturan Repository

Sebelum commit:

```bash
bin/dot doctor
git diff --check
git status --short --branch
git diff --stat
```

Backup lokal seperti `.pre-*` dan `.structure-backup` bukan output publik dan
tidak boleh ikut commit.

Commit dan push hanya dilakukan setelah review dan persetujuan eksplisit.
