# M08 Candidate Package Profile Policy

This directory is a temporary draft and is not an active installer.

## Canonical inventory

During M08, these repository files remain the canonical installed-package
inventory:

- pkglist_pacman_repo.txt
- pkglist_aur.txt

The legacy pkglist_pacman.txt remains unchanged until its documentation and
compatibility treatment are finalized.

## Native installable profiles

- core
- openbox
- laptop
- dev
- display
- vpn
- live-wallpaper
- optional

No profile may enable, disable, start, or stop a service.

## Non-installable native classifications

- manual-system: kernel, bootloader, firmware, filesystem, sudo, and
  hardware-specific driver packages requiring machine review.
- legacy-disabled: packages already classified as unused or excluded from
  the active minimal Openbox setup.

## Dependency intent

- core: standalone post-install profile.
- openbox: requires core.
- laptop: requires core and hardware detection.
- dev: requires core.
- display: requires core and an X11/Openbox environment.
- vpn: requires core and separate private-config validation.
- live-wallpaper: requires openbox and explicit user selection.
- optional: never selected automatically.

## AUR policy

AUR packages are split from native packages.

- manual-bootstrap contains the AUR helper and cannot be installed through
  itself.
- all other AUR profiles require an already available, explicitly selected
  AUR helper.
- no AUR profile is installed automatically.

## Excluded profile

No AI profile is created because the canonical manifests do not contain a
coherent, uniquely AI-specific package set.

## M08 Frozen Installer Contract

- `packages/native/*.txt` is the canonical native package source.
- `packages/aur/*.txt` is the canonical AUR package source.
- `pkglist_pacman.txt` is compatibility-only and is not canonical.
- Installation defaults to dry-run.
- Actual installation requires explicit `--apply`.
- AUR installation additionally requires `--aur`.
- `manual-system`, `legacy-disabled`, and `manual-bootstrap` are blocked.
- Package profiles never remove packages.
- Package profiles never activate or disable services.
- Private configuration remains local.
