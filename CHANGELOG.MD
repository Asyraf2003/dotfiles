# Dotfiles Update – Arch RAM fix, Steam purge, Storage optimizations, `pc-health`

**Date:** 2025-10-21
**Host:** Arch Linux (NVMe + ext4 + zram)

This update documents the changes I made today so my future self (and others) can reproduce the exact setup. It covers: RAM sanity checks, fully removing Steam and 32-bit libs, disabling multilib, storage/NVMe optimizations, Brave flags, Openbox keybind, dotfiles symlink audit, and a tiny system health script `pc-health`.

---

## ✅ RAM sanity & behavior

* Linux aggressively uses **buff/cache**. High `used` after running heavy apps (Steam/CS2) often means cache, **not leaks**.
* Useful checks:

  ```bash
  free -h
  htop   # Shift+M to sort by memory
  ```
* To drop cache temporarily (safe):

  ```bash
  sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'
  ```
* Swap maintenance (optional):

  ```bash
  sudo swapoff -a && sudo swapon -a
  ```
* Set swappiness lower (prefer RAM over swap):

  ```bash
  echo 'vm.swappiness=20' | sudo tee /etc/sysctl.d/99-swappiness.conf
  sudo sysctl -p /etc/sysctl.d/99-swappiness.conf
  ```

---

## 🧹 Steam purge (and why)

I no longer use Steam / Proton / 32‑bit apps. Goal: **pure 64‑bit dev machine**.

1. Stop Steam & remove user data:

```bash
pkill -f steam || true
rm -rf ~/.local/share/Steam ~/.steam ~/.cache/Steam
```

2. Remove Steam package (if present):

```bash
sudo pacman -Rns steam
```

3. Disable multilib repo:

```ini
# /etc/pacman.conf
#[multilib]
#Include = /etc/pacman.d/mirrorlist
```

Then update DB:

```bash
sudo pacman -Sy
```

4. Remove **all** `lib32-*` packages (after Steam is gone):

```bash
sudo pacman -Rns $(pacman -Qq | grep ^lib32-)
```

5. Optional: clean orphaned packages & caches

```bash
sudo pacman -Qdt      # review orphans
# sudo pacman -Rns $(pacman -Qdtq)

sudo pacman -Scc      # clear package cache (confirm prompts)
```

> Result: system is full 64‑bit. `free -h` shows low baseline RAM (<1 GiB used idle with Openbox), swap mostly idle.

---

## 🌐 Brave performance keybind (Openbox)

Use Chromium flags to reduce RAM per site and keep background behavior predictable.

**Openbox `rc.xml`** keybind:

```xml
<keybind key="W-b">
  <action name="Execute">
    <command>brave --process-per-site --disable-background-networking --disable-sync --disable-renderer-backgrounding --disable-background-timer-throttling</command>
  </action>
</keybind>
```

Reload: `openbox --reconfigure`

Emoji support in terminal:

```bash
sudo pacman -S noto-fonts-emoji
# JoyPixels (optional, AUR): yay -S ttf-joypixels
```

Alacritty fallback (excerpt):

```yaml
font:
  normal:
    family: JetBrainsMono Nerd Font
  fallback:
    - Noto Color Emoji
```

---

## 💽 Storage / NVMe optimizations (ext4 on NVMe)

* Enable weekly TRIM (recommended):

  ```bash
  sudo systemctl enable fstrim.timer --now
  systemctl status fstrim.timer  # should be active (waiting)
  ```

* ext4 mount options (safe):

  ```ini
  # /etc/fstab
  UUID=... / ext4 rw,relatime,lazytime 0 1
  ```

  > `lazytime` reduces metadata writes; prefer weekly TRIM over `discard` for performance.

* Journals & caches hygiene:

  ```bash
  sudo journalctl --vacuum-time=7d
  sudo pacman -Scc    # optional, clears /var/cache/pacman
  ```

* NVMe health tooling:

  ```bash
  sudo pacman -S nvme-cli smartmontools
  nvme list
  sudo nvme smart-log /dev/nvme0n1 | grep -E 'temperature|percentage_used'
  sudo smartctl -a /dev/nvme0n1 | grep -E 'Data Units (Written|Read)|Temperature|Percentage Used'
  ```

  **My snapshot:** Temp ≈ **44 °C**, Percentage Used **5%**, Data Written **~7.8 TB**, Data Read **~27 TB** (Samsung MZVL4256HBJD).

---

## 🔗 Dotfiles symlink audit

Current links (examples):

```
~/.bashrc            -> ~/.dotfiles/.bashrc
~/bin                -> ~/.dotfiles/bin
~/.config/alacritty  -> ~/.dotfiles/alacritty
~/.config/openbox    -> ~/.dotfiles/openbox
~/.config/dunst      -> ~/.dotfiles/dunst
~/.config/htop       -> ~/.dotfiles/htop
~/.config/yay        -> ~/.dotfiles/yay
```

Fixed a minor loop: removed `~/.dotfiles/alacritty` that pointed back into `~/dotfiles/alacritty`.

Helper to list dotfile links:

```bash
find ~ -maxdepth 2 -type l -ls | grep dotfiles
```

Ensure PATH contains `~/bin`:

```bash
# in .bashrc
export PATH="$HOME/bin:$PATH"
```

---

## 🩺 `pc-health` script (now versioned in `.dotfiles/bin`)

**Path:** `~/.dotfiles/bin/pc-health` (and `~/bin` symlinked to `~/.dotfiles/bin`)

```bash
#!/bin/bash
# Simple system health summary

echo "🧠 Memory usage:"
free -h | awk '/Mem:/ {print "  Used:", $3 " / " $2, " |  Free:", $4}'

echo
echo "💾 Storage usage:"
df -h / | awk 'NR==2 {print "  Root:", $3 " used of " $2 " (" $5 ")"}'

if command -v nvme &>/dev/null; then
  TEMP=$(sudo nvme smart-log /dev/nvme0n1 | grep -m1 "temperature" | awk '{print $3,$4}')
  USE=$(sudo nvme smart-log /dev/nvme0n1 | grep -m1 "percentage_used" | awk '{print $3}')
  echo
  echo "⚙️  NVMe Health:"
  echo "  Temp: $TEMP  |  Used: $USE"
fi
```

Make executable:

```bash
chmod +x ~/.dotfiles/bin/pc-health
```

Usage:

```bash
pc-health
```

---

## 📦 Commit checklist

Run from the dotfiles repo root:

```bash
cd ~/.dotfiles
# sanity
git status

# ensure scripts and configs are tracked
git add .bashrc .config/alacritty .config/openbox .config/dunst .config/htop .config/yay bin/pc-health

# commit with context
git commit -m "arch: RAM sanity, full Steam purge + disable multilib, ext4/NVMe trim+lazytime, Brave keybind, pc-health script"

git push origin main  # or your default branch
```

---

## 🧾 Changelog (2025-10-21)

* RAM: tuned swappiness=20; added cache/swap maintenance notes.
* Gaming stack: removed Steam & all `lib32-*`; **disabled [multilib]**.
* Storage: enabled weekly TRIM; added `lazytime` mount; journal & pacman cache hygiene.
* NVMe health: installed `nvme-cli` + `smartmontools`; verified 44 °C, 5% used, ~7.8 TB written.
* Browser: Brave keybind with `--process-per-site` etc.; emoji fonts installed (`noto-fonts-emoji`).
* Dotfiles: audited symlinks; removed one loop; confirmed `~/bin -> ~/.dotfiles/bin`.
* Tools: added `pc-health` script and made executable.

---

## 🔚 Notes

This README section is intended as a reproducible playbook. Future setup: clone repo, run a small `setup.sh` that (1) links configs, (2) enables `fstrim.timer`, (3) sets swappiness, (4) installs base fonts and `pc-health`. Future improvement: add a systemd timer for periodic housekeeping.
