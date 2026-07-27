# Dotfiles Migration Status

Updated: 2026-07-25
Repository: ~/.dotfiles
Branch: sync-origin-main

## Workflow Rules

1. Dokumen ini adalah sumber status operasional utama.
2. SESSION_HANDOFF_UPDATED_20260725.md adalah baseline historis.
3. README dan CHANGELOG bukan sumber status migrasi.
4. Hanya satu milestone boleh berstatus ACTIVE.
5. Setiap ide baru diklasifikasikan sebagai ACTIVE, BACKLOG, DECISION, atau REJECTED.
6. Setiap perubahan membutuhkan FACT, GAP, DECISION, COMMAND PLAN, dan PROOF.
7. Tidak ada commit atau push tanpa persetujuan eksplisit.
8. Tidak ada cleanup backup sebelum restore test lulus.
9. Progress hanya berubah saat sebuah milestone selesai penuh.
10. Status Git dan bukti runtime harus dicatat sebelum pindah milestone.

## Progress Model

Total milestone: 10

| ID | Milestone | Weight | Status |
|---|---|---:|---|
| M01 | Baseline audit, snapshot, checkpoint | 10% | DONE |
| M02 | Bash public modular migration | 10% | DONE |
| M03 | Git config public/local split | 10% | DONE |
| M04 | Private shell overlay | 10% | DONE |
| M05 | Core application configs | 15% | DONE |
| M06 | Openbox, display, launcher integration | 10% | DONE |
| M07 | Script hardening and sudo review | 15% | DONE |
| M08 | Package profiles, installer, dot command | 10% | DONE |
| M09 | Cleanup, restore test, fresh-install test | 5% | DONE |
| M10 | Final documentation, review, commit, push | 5% | DONE |

Confirmed progress: 100%
Active milestone: NONE
## Completed

### Repository safety

- Rollback snapshot created and validated.
- Git checkpoint f996a74 exists.
- No automatic commit or push.
- Temporary cleanup artefact removed.

### Bash

- shell/bashrc created.
- shell/bash_profile created.
- shell/bash.d/core.bash created.
- shell/bash.d/dev.bash created.
- shell/bash.d/laptop.bash created.
- shell/bash.d/display.bash created.
- Interactive and login shell tests passed.
- ~/.bashrc symlink active.
- ~/.bash_profile symlink active.
- notes/shortcuts.txt removed after reference migration.
- SHORTCUTS.md is the replacement.
- bin/helpme sanitized.

### Git

- Public git/gitconfig created.
- ~/.gitconfig symlink active.
- Local-only config stored at ~/.config/git/local.gitconfig.
- GitHub CLI credential helper remains local.
- safe.directory remains local.
- Runtime identity and helper tests passed.

### Private overlay

- GitHub repository Asyraf2003/dotfiles-private exists and is private.
- Local clone exists at ~/.dotfiles-private.
- shell/private.bash created and active.
- Private aliases tes, sv, deploy, svyourapi, and sai passed runtime tests.
- No private commit or push yet.

### Application configs completed

- tmux candidate created.
- ~/.tmux.conf symlink active.
- tmux runtime test passed.
- Neovim candidate created without init.lua.bak.
- ~/.config/nvim symlink active.
- Lua and lazy-lock.json parse tests passed.
- Alacritty repo config updated from active config.
- ~/.config/alacritty symlink active.
- TOML validation passed.

- Final M05 application scope approved.
- Tmux, Neovim, and Alacritty runtime proofs passed.
- Kitty remains rejected.
- Dunst was classified as unused and excluded from the migration scope.
- M05 tracker validation passed without modifying public or private Git status.

### Cleanup already completed

- images/preview_video_thumbnail.png removed.
- notes/shortcuts.txt removed.
- Temporary cleanup directory removed.

## Final Milestone

### M10 — Final documentation, review, commit, push

Current scope:

- reconcile final repository documentation with validated runtime state;
- review the complete Git diff and untracked canonical outputs;
- confirm rollback backups and temporary quarantine disposition;
- validate final README, tracker, package policy, and command documentation;
- prepare a final commit plan without committing automatically;
- require explicit user approval before commit or push;
- do not modify packages, services, credentials, or private overlay.

## Decisions

### D001 — Docker

Status: KEEP

Reason:
Docker and containerd remain optional backup tools on Arch Linux.

### D002 — System cleanup commands

Status: KEEP AND HARDENED

Items:
S004-S008

Implementation:
- `bin/clean-system` defaults to read-only dry-run.
- Cleanup changes require explicit `--apply`.
- Pacman cache cleanup uses controlled `paccache` policies.
- Journal vacuum requires explicit `--journal-days N`.
- Automatic `drop_caches` execution is rejected.
- Automatic Yay/Paru cache cleanup is deferred for package-level review.
- Invalid arguments return exit status 2.
- Help returns exit status 0.

Proof:
- Bash parse: PASS.
- Executable mode preserved: PASS.
- Default dry-run: PASS.
- Cleanup applied during validation: NO.
- Sudo commands executed during validation: NO.
- Rollback backups created and preserved.

### D003 — Local PHP stack

Status: KEEP AND HARDENED

Items:
S009-S014

Services:
- MariaDB
- PHP-FPM
- Nginx

Implementation:
- `bin/maria` performs no action when called without arguments.
- `start` and `stop` require explicit actions.
- Service unit availability is validated before modification.
- Sudo authentication is requested before privileged operations.
- Partial start failure triggers rollback for services started by that invocation.
- `stackstatus` provides read-only state for all three services.
- Invalid or extra arguments return exit status 2.
- Service enablement remains disabled for on-demand local development.

Proof:
- Bash parse and executable mode: PASS.
- No-argument and help behavior: PASS.
- Read-only stack status: PASS.
- Start runtime: PASS.
- All stack services active after start: PASS.
- Stop runtime: PASS.
- Pre-runtime inactive state restored: PASS.
- Service enablement modified: NO.
- Packages modified: NO.
- Rollback backup created and preserved.

### D004 — VPN

Status: KEEP AND HARDENED

File:
`bin/vpn`

Result:
- Runtime `vpn on`: PASS.
- WireGuard handshake and traffic: PASS.
- Runtime `vpn status`: PASS.
- Runtime `vpn off`: PASS after target correction.
- Shutdown now uses `/run/wireguard/asyraf.conf` when that effective configuration exists.
- Interface, policy rules, and route table are removed after shutdown.
- Final WireGuard state: OFF.
- Final IPv6 state restored to normal.
- DNS state restored.
- Rollback backups created and preserved.

Accepted remaining scope:
- Direct DNS, IPv6, route, and config-normalization behavior remains legacy.
- Further redesign is deferred unless runtime reliability requires it.

### D005 — PC health and laptop tuning

Status: KEEP AND HARDENED

Items:
S044-S050

Completed — `bin/pc-health`:
- Resolves the root disk dynamically instead of hard-coding `/dev/nvme0n1`.
- Reads NVMe SMART data once using JSON output.
- Supports the actual `percent_used` field with compatibility fallback.
- Converts Kelvin temperature safely when required.
- Provides `--no-nvme` for fully unprivileged reporting.
- Help exits with status 0.
- Invalid options exit with status 2.
- Does not change power settings, services, filesystems, or devices.

PC health proof:
- Bash parse and executable mode: PASS.
- Dynamic NVMe resolution: PASS.
- NVMe SMART runtime: PASS.
- Temperature field: PASS.
- Percent-used field: PASS.
- Read-only runtime status: PASS.
- Power profile unchanged: PASS.
- Power service state unchanged: PASS.
- Rollback backups created and preserved.

Completed — `bin/tune-laptop.sh`:
- Uses read-only status as the default action.
- Status does not require root.
- Profile changes require explicit `perf`, `balanced`, or `save` commands.
- Uses `powerprofilesctl` as the only power-profile controller.
- Maps `perf` to `performance`, `balanced` to `balanced`, and `save` to `power-saver`.
- Validates profile availability before modification.
- Saves the previous profile for rollback.
- Verifies the resulting profile and attempts rollback on verification failure.
- Provides an explicit rollback command.
- Performs no direct CPU sysfs writes.
- Does not restart cpupower, TLP, or power-profiles-daemon.
- Reports battery threshold capability without writing to it.
- Help exits with status 0.
- Invalid arguments exit with status 2.

Laptop tuning proof:
- Bash parse and executable mode: PASS.
- Help and invalid-argument handling: PASS.
- Default and explicit status output match: PASS.
- Read-only status runtime: PASS.
- Direct CPU sysfs writes disabled: PASS.
- Service restarts disabled: PASS.
- Battery detected as `BAT0`: PASS.
- Battery type reported as `Battery`: PASS.
- Battery threshold path detected: PASS.
- Battery threshold reported as `AVAILABLE_NOT_MANAGED`: PASS.
- Battery threshold value during validation: 50.
- `power-saver` to `balanced` runtime change: PASS.
- Rollback from `balanced` to `power-saver`: PASS.
- Final power profile restored to `power-saver`: PASS.
- Power service state unchanged during validation: PASS.
- Script and rollback backup preserved: PASS.

### D006 — Kitty

Status: REJECTED

Reason:
Kitty is not installed and is not needed.

Action:
Do not migrate ~/.config/kitty.
Do not create a Kitty symlink.
Existing local config remains untouched until cleanup phase.

### D007 — Minimal Openbox session

Status: KEEP

Reason:
The active workflow uses TTY login, `.xinitrc`, and `openbox-session`.
Window management is keyboard-driven.

### D008 — Display managers

Status: REMOVE LATER

Items:
- LightDM
- lightdm-gtk-greeter
- greetd
- greetd-tuigreet

Reason:
All are disabled and inactive. The active session starts from TTY.

### D009 — Optional desktop daemons

Status: REMOVE LATER

Items:
- Picom
- Tint2

Reason:
They are not running and have no active startup reference.

### D010 — Dmenu

Status: KEEP AS PACKAGE DEPENDENCY

Reason:
Dmenu is referenced by the active `display-menu` script.
It is not treated as the primary application launcher.

### D011 — GTK configuration

Status: PACKAGE ONLY

Reason:
GTK libraries remain required by applications such as Thunar.
Personal GTK theme configuration is not part of the active migration scope.

### D012 — Minimal desktop applications

Status: KEEP

Items:
- Alacritty
- Brave
- OBS Studio
- Thunar
- basic image, audio, and video playback

### D013 — Spotify native application

Status: REMOVE LATER

Reason:
Spotify web is sufficient for the intended workflow.

## Backlog

### B001 — Brave portable tuning

Status: BACKLOG
Target milestone: M06

Portable candidates:

- ~/.config/brave-flags.conf
- Brave launch flags in Openbox
- Brave launch flags in Hyprland, only if Hyprland remains in scope

Excluded permanently:

- ~/.config/BraveSoftware
- accounts
- profiles
- cookies
- sessions
- passwords
- OAuth tokens
- Sync data
- extension data
- history
- Login Data
- Local State
- browser databases

Observed:

- Brave binary: /usr/local/bin/brave
- Two browser profiles exist
- Profile contents were not intentionally audited
- Openbox currently launches Brave with optimization flags

### B002 — Cleanup review

Status: BACKLOG
Target milestone: M09

Includes:

- obsolete backups
- documentation cleanup
- package manifest cleanup
- Brave cache
- Spotify cache after offline-download check
- Yay cache classification
- build caches
- AI generated cache

Do not delete:

- browser profiles
- cookies
- sessions
- passwords
- auth
- SSH
- GPG
- private keys
- OAuth
- WireGuard private data
- active rollback snapshots

## Pending Major Work

- Dunst
- Openbox rc.xml
- Openbox remaining files
- .xinitrc
- display-menu
- livewp-toggle
- script hardening
- package profiles
- installer
- dot command
- doctor
- rollback
- restore test
- fresh-install test
- final README
- final commit
- final push

## Current Git Status Expected

```text
## sync-origin-main...origin/sync-origin-main [ahead 1]
 M alacritty/alacritty.toml
 M bin/helpme
 D images/preview_video_thumbnail.png
 D notes/shortcuts.txt
?? MIGRATION_STATUS.md
?? SHORTCUTS.md
?? git/
?? nvim/
?? shell/
?? tmux/
```

### M07 privileged reference classification

Status: COMPLETE

Runtime scripts:
- `bin/clean-system`: KEEP AND HARDENED.
- `bin/maria`: KEEP AND HARDENED.
- `bin/pc-health`: KEEP AND HARDENED.
- `bin/tune-laptop.sh`: KEEP AND HARDENED.
- `bin/vpn`: KEEP AS IS with accepted known risks; runtime `on`, `status`, and `off` proof passed.
- `bootstrap.sh`: REJECT CURRENT RUNTIME USE; DEFER REWRITE TO M08.

Explicit shell commands:
- `.bashrc` system-update alias: KEEP as an explicit user-triggered privileged operation.
- `shell/bash.d/dev.bash` PostgreSQL aliases: KEEP as explicit user-triggered privileged operations.
- `shell/bash.d/laptop.bash` battery alias: REJECT STALE ALIAS; reconcile path and unnecessary sudo during M08 shell work.

Non-privileged references:
- `/sys` references in battery, display, and tuning status scripts are read-only reporting paths.
- `/usr` references in Openbox and shell configuration are executable or resource paths, not privileged writes.
- Package list entries are package data, not executable commands.

Documentation references:
- `CHANGELOG.md`, `README.md`, and `README.next.md` are historical or explanatory references.
- They are not operational sources of truth when they conflict with the tracker or runtime proof.

Classification result:
- Every remaining privileged reference is classified as KEEP, HARDENED, ACCEPTED RISK, REJECT, DEFER, DATA, or DOCUMENTATION.
- No script was executed during the classification scan.
- No package, service, credential, system path, route, DNS, IPv6, or WireGuard state was modified.

### M07 final validation

Status: PASS

Validation:
- `bin/clean-system`: KEEP AND HARDENED.
- `bin/maria`: KEEP AND HARDENED.
- `bin/pc-health`: KEEP AND HARDENED.
- `bin/tune-laptop.sh`: KEEP AND HARDENED.
- `bin/vpn`: KEEP AND HARDENED.
- VPN final state: OFF.
- Final power profile: `power-saver`.
- `bootstrap.sh` review: COMPLETE.
- `bootstrap.sh` rewrite: DEFERRED TO M08.
- Privileged-reference classification: COMPLETE.
- Structure backup preserved.
- M07 transition and rollback backups preserved.
- Packages removed: NO.
- Credentials modified: NO.
- Commit attempted: NO.
- Push attempted: NO.

Milestone transition:
- M07: DONE.
- M08: ACTIVE.
- Confirmed progress: 80%.

## M08 Completion Record

- Native package profiles validated: 202/202.
- AUR package profiles validated: 10/10.
- Core profile frozen at 13 packages.
- `dot doctor`, `dot status`, `dot install`, `dot link`, and
  `dot rollback` implemented and validated.
- Installation and linking default to dry-run.
- Actual package installation requires explicit `--apply`.
- No package removal or service activation is performed automatically.
- `bootstrap.sh` is a thin safe wrapper around `bin/dot`.
- `pkglist_pacman.txt` is compatibility-only.
- Apply behavior passed isolated fake-command and temporary-HOME tests.


## M09 Completion Record

- Repository hygiene discovery: PASS.
- Backup classification completed for 22 candidates.
- Final classification: 17 `KEEP_ROLLBACK`, 5 `REMOVE_TEMPORARY_LATER`,
  and 0 `REVIEW_BEFORE_REMOVAL`.
- End-to-end rollback validation completed in an isolated temporary workspace:
  17/17 PASS.
- Five byte-identical redundant backups were removed after quarantine,
  hash comparison, and automatic-restore preparation.
- Cleanup quarantine remains available at
  `/tmp/M09_REDUNDANT_BACKUP_QUARANTINE_20260726-192248`.
- Final repository validation: PASS.
- `dot doctor`: PASS.
- Canonical hashes and modes remained unchanged.
- Git status matched the approved post-cleanup baseline.
- Git index, branch, and HEAD remained unchanged.
- Packages installed or removed: NO.
- Services modified: NO.
- Private overlay or credentials modified: NO.
- Commit attempted: NO.
- Push attempted: NO.

Milestone transition:
- M08: DONE.
- M09: DONE.
- M10: ACTIVE.
- Confirmed progress: 95%.

## M10 Completion Record

- Final README documentation: PASS.
- Public/private boundary review: PASS.
- Potential committed secret count: 0.
- `dot doctor`: PASS.
- Shell syntax validation: PASS.
- Openbox XML validation: PASS.
- `git diff --check`: PASS.
- Git index remains unchanged.
- Commit attempted: NO.
- Push attempted: NO.
- M10: DONE.
- Confirmed progress: 100%.

## Next Valid Step

Review the exact public commit scope and exclude local rollback backups.

Do not stage, commit, or push without explicit user approval.
