# Openbox Migration

## Primary Goal

Migrate the Zenbook primary desktop session from Hyprland to raw Openbox while preserving the workflows and hardware functions that are actually useful.

Openbox is the target. Hyprland is only a temporary fallback and reference source during migration.

## Required Final State

1. Raw Openbox is the primary desktop.
2. No wallpaper, panel, compositor, dock, or decorative layer unless explicitly decided later.
3. F8 emoji functionality remains available.
4. Other required Fn/Fx hardware keys remain functional.
5. Existing important `SUPER + ...` application shortcuts are migrated to Openbox.
6. Login, sudo, and other PAM/password authentication should support Zenbook camera-based face verification.
7. Microphone and speakers work correctly.
8. Connectivity works correctly, especially Wi-Fi and Bluetooth.
9. Thunar works fully, including required right-click/context-menu integrations.
10. Hyprland is removed only after every required Openbox target above is validated PASS.

## Current Proven State

- Openbox 3.6.1 installed.
- Xorg and xorg-xinit installed.
- `startx` now enters an Xorg/Openbox session.
- `~/.xinitrc` points to `openbox/xinitrc`.
- Openbox raw session successfully starts.
- Live Openbox config was reset to the standard package baseline from `/etc/xdg/openbox/`.
- Touchpad tap-to-click works through `/etc/X11/xorg.conf.d/30-touchpad.conf`.
- Linux VT switching is healthy: `chvt` works.
- Ctrl+Alt+Fx failure was traced to Fn-lock/F-key mode; changing Fn mode makes VT switching work.
- Hyprland is still available as fallback.
- Openbox is now usable as the active working session.
- Core Openbox launchers are installed and acceptance-tested: Alacritty, Brave, Chromium, Thunar, OBS, Spotify Launcher, Steam, Telegram, and WhatsApp Web. Android helper is the only selected launcher not yet acceptance-tested.
- Window controls are implemented: SUPER+Arrow = half-screen placement; SUPER+SHIFT+Arrow = quarter-screen placement.
- Workspace model is intentionally reduced to desktops 1-4. SUPER+1..4 switches desktop; SUPER+SHIFT+1..4 sends the active window.
- Openbox desktop right-click root menu has been removed.
- Volume-up is clamped to 100% with wpctl; brightness remains bounded by brightnessctl.
- ASUS Fn mode is user-controlled with Fn+Esc; direct hotkey mode is the desired state.
- The non-official Linux ASUS NumberPad driver was masked and removed from runtime after it caused touchpad instability. NumberPad restoration is deferred until the core migration is complete.
- ASUS EC reset was completed.
- Touchpad raw-coordinate jitter is still intermittent even with the NumberPad layer absent. A libinput hwdb fuzz override of 16 is active on ABS_X/Y and ABS_MT_POSITION_X/Y. The pointer is usable but this remains a tracked quality issue.
- Important application commands currently known from Hyprland include Alacritty, Brave, Chromium, Thunar, OBS, Spotify Launcher, Steam, Telegram, Android helper, WhatsApp Web app, and Dolphin reference. Only migrate the ones the user actually wants.

## Known Deferred Items

### Touchpad raw jitter

The physical ASUP1415:00 093A:300C touchpad intermittently emits changing raw coordinates while a finger is stationary.

Current evidence:
- the issue exists below Openbox;
- the non-official NumberPad driver has been removed from runtime;
- ASUS EC reset has already been performed;
- libinput hwdb fuzz 16 is active;
- the touchpad remains usable, but jitter can recur.

Decision:
- do not let this derail the Openbox migration;
- treat it as a separate hardware/kernel/firmware quality investigation after the core desktop phases;
- do not reinstall the non-official NumberPad driver during the core migration.

### NumberPad

ASUS NumberPad functionality is intentionally deferred. Restore it only after the Openbox core is stable, and only with an approach that does not regress pointer stability.

## Execution Rules

These rules are mandatory for the migration session.

### 1. Follow the workflow, not random symptoms

Always identify the active phase before changing anything.

If a problem is outside the active phase and does not block it, record it and continue. Do not derail the workflow.

### 2. Distinguish one-path work from real decision branches

If the required next action is obvious and supported by current data, execute it directly.

Do not invent a decision tree where none exists.

Use an A/B branch only when two materially different paths are both plausible and the correct one depends on missing evidence.

Example:

- Good branch: input device is either libinput or a custom ASUS driver and the fix depends on which one owns the device.
- Bad branch: checking every individual app shortcut one-by-one when all launchers can be migrated and tested as one batch.

### 3. Batch work when the operations belong to one domain

If several changes share the same owner, risk level, rollback method, and validation method, do them together.

Examples:

- migrate all application launcher shortcuts together;
- validate audio input/output together;
- validate Wi-Fi/Bluetooth connectivity as one connectivity phase;
- validate Thunar right-click integrations together.

Do not force one-command-per-turn when batching is safer and faster.

### 4. Stop only for critical missing data

Ask for evidence only when the missing data could change the action, damage the system, overwrite user data, or create a wrong persistent configuration.

Do not ask for extra audits merely to feel certain.

### 5. Prefer known-good baseline first

For Openbox itself, start from standard package defaults, then add only the required user behavior.

Do not restore old Openbox custom config wholesale unless a specific feature from it is intentionally selected.

### 6. Hyprland is a reference, not the migration base

Use the current Hyprland setup to discover:

- useful application shortcuts;
- useful hardware behavior;
- scripts the user still relies on.

Do not copy Hyprland-specific behavior blindly into X11/Openbox.

### 7. Preserve user data

Never delete user data, app profiles, project files, SSH data, browser profiles, or Hyprland fallback data during the migration.

Hyprland cleanup is the final phase only.

### 8. Validate by phase exit criteria

Do not repeatedly verify trivial details.

For each phase, define a small PASS checklist. Run the checklist once after the phase implementation is complete.

If one item fails, repair only that item unless the failure invalidates the whole phase.

## Workflow

### Phase 0 — Baseline and rollback safety

Goal:
- Openbox raw boots reliably.
- Hyprland remains available as fallback.
- user data remains untouched.

Current status: PASS.

Exit criteria:
- `startx` enters Openbox.
- Openbox can be exited back to TTY.
- keyboard and pointer are usable.
- no destructive migration step has occurred.

### Phase 1 — Input and Fn/Fx behavior

Goal:
- touchpad behaves normally;
- Ctrl+Alt+Fx VT switching works;
- F8 emoji behavior works;
- required Fn/Fx keys retain intended functions.

Work as one input-domain phase.

Do not tune unrelated apps here.

Current status:
- core input/Fn/Fx acceptance PASS;
- touchpad remains usable;
- intermittent raw touchpad jitter is tracked separately as a non-blocking deferred quality issue;
- NumberPad is deferred.

Exit criteria:
- tap-to-click PASS;
- VT switching PASS;
- F8 emoji PASS;
- required Fn/Fx keys PASS.

### Phase 2 — Openbox application shortcuts

Goal:
- migrate the useful `SUPER + ...` app launchers from Hyprland into Openbox.

First collect the actual desired mapping, then patch the Openbox config in one batch.

Do not test every shortcut in separate turns. Test all migrated shortcuts in one pass and repair only failures.

Current status:
- selected launcher/window/workspace shortcuts PASS;
- Android helper (SUPER+SHIFT+A) remains untested;
- Phase 2 stays open only for that acceptance item.

Exit criteria:
- all selected launchers PASS;
- power shortcuts intentionally retained;
- no Hyprland-only command is left in an Openbox binding.

### Phase 3 — Audio and microphone

Goal:
- speakers/output work;
- microphone/input works;
- expected volume/mute hardware keys work.

Use PipeWire/WirePlumber as the existing audio stack unless evidence shows otherwise.

Exit criteria:
- speaker playback PASS;
- microphone capture PASS;
- mute/volume keys PASS.

### Phase 4 — Connectivity

Goal:
- Wi-Fi works normally;
- Bluetooth works normally;
- required connection tools remain usable.

Do not redesign networking if NetworkManager/BlueZ already satisfy the goal.

Exit criteria:
- Wi-Fi connect/reconnect PASS;
- Bluetooth power/scan/connect PASS.

### Phase 5 — Thunar workflow

Goal:
- Thunar is the practical file manager for Openbox;
- required right-click actions, archive behavior, open-with behavior, mounts, and user workflows work.

Configure only the integrations the user actually uses.

Exit criteria:
- normal browsing PASS;
- right-click/context actions PASS;
- removable/media behavior PASS if required.

### Phase 6 — Face authentication

Goal:
- Zenbook camera-based face verification integrates with PAM for login/sudo/password prompts where technically supported and acceptable.

This is a security-sensitive phase. Validate the camera, chosen face-auth implementation, PAM ordering, fallback password path, and lockout behavior before enabling broadly.

Never remove password fallback during initial rollout.

Exit criteria:
- face verification works for the chosen PAM targets;
- password fallback still works;
- failure does not lock the user out.

### Phase 7 — Dotfiles finalization

Goal:
- repository reflects the actual validated Openbox setup;
- no temporary backup files or abandoned experiments are committed;
- setup is reproducible.

At this phase, reconcile live config into the repository and commit/push the final state.

### Phase 8 — Hyprland removal

This phase is forbidden until Phases 1-7 are PASS.

Goal:
- remove Hyprland and Hyprland-only dependencies/config that are no longer required.

Before deletion, confirm no required script, shortcut, portal, or hardware workflow still depends on Hyprland.

## Session Operating Format

At the start of each work unit, state only:

- ACTIVE PHASE
- FACT
- BLOCKER, only if real
- DECISION
- EXECUTION
- EXIT CRITERIA

Do not generate extra audits, branches, or hypothetical failure trees unless they change the next action.

If the data already proves the next step, proceed.

If one phase can be completed safely in one batch, complete the batch and validate once.

## Next Session Start

Read this file first.

Current continuation point:
1. Openbox is already the active usable desktop.
2. Verify Android helper with SUPER+SHIFT+A.
3. In the same reporting batch, execute Phase 3 audio/microphone acceptance.
4. If Android and Phase 3 PASS, close Phase 2 and Phase 3 and continue to Phase 4 connectivity.
5. Keep intermittent touchpad raw jitter as a deferred hardware/kernel/firmware investigation; it must not derail Phases 3-7 unless usability degrades materially.
6. Keep NumberPad disabled until the core migration is complete.

Do not restart discovery from zero.
Do not remove Hyprland.
Do not investigate unrelated local Git changes unless they block the active migration phase.
