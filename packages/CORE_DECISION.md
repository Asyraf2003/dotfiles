# M08 Core Profile Reduction Decision

This is a temporary draft decision. It does not install or remove packages.

## Core rule

Core contains only packages directly required by:

- the active modular Bash configuration;
- managed Git, Neovim, and tmux configuration;
- the `helpme`, `wifi`, `clean-system`, display, and laptop scripts;
- repository discovery and validation commands.

## Relocations

- `bluez` and `bluez-utils` move to Openbox because Bluetooth is a
  desktop/hardware capability, not a universal core requirement.
- `bind` moves to VPN because `bin/vpn` uses `dig`.
- general utilities, alternate editors, alternate shells, and convenience
  tools move to optional.
- no service activation is authorized by profile membership.

## Core packages

- bash-completion
- bat
- fastfetch
- fd
- fzf
- git
- less
- neovim
- networkmanager
- pacman-contrib
- ripgrep
- tmux
- zoxide
