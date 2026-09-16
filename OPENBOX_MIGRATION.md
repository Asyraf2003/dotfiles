# Openbox Migration

## Goal

Migrate the primary desktop session from Hyprland to raw Openbox while preserving the workflows and hardware functions that are actually useful.

### Required final state

- Raw Openbox as the primary desktop.
- No wallpaper, panel, compositor, or decorative desktop component unless explicitly added later.
- F8 emoji functionality remains available.
- Other required Fn/Fx hardware keys remain functional.
- Existing important SUPER+... application shortcuts are migrated to Openbox.
- Login, sudo, and other password authentication should eventually support Zenbook camera-based face verification.
- Microphone and speakers work correctly.
- Connectivity functions work correctly, including Wi-Fi and Bluetooth.
- Thunar works fully, including required right-click/context-menu integrations.
- Hyprland remains installed as fallback until the Openbox migration is fully PASS.

## Current proven state

- Openbox 3.6.1 installed.
- Xorg and xorg-xinit installed.
- `startx` now enters an Xorg/Openbox session.
- `~/.xinitrc` points to `openbox/xinitrc`.
- Openbox raw session successfully starts.
- Live Openbox config was reset to the standard package baseline from `/etc/xdg/openbox/`.
- Touchpad tap-to-click works through `/etc/X11/xorg.conf.d/30-touchpad.conf`.
- Linux VT switching itself is healthy: `chvt` works.
- Ctrl+Alt+Fx failure was traced to Fn-lock/F-key mode; changing Fn mode makes VT switching work.
- Hyprland is still available as fallback.

## Known cleanup item

There are currently conflicting ASUS Fn-lock modprobe definitions:

- `/etc/modprobe.d/asus-fnlock.conf`
- `/etc/modprobe.d/asus-wmi-fnlock.conf`

Resolve this during the structured migration, not ad-hoc.

## Next session

Design the migration workflow first, then execute it phase-by-phase from the clean Openbox baseline.

Do not remove Hyprland until all required Openbox functionality has been validated.
