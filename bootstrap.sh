#!/bin/bash
install_packages() {
    echo "[*] Installing pacman packages..."
    sudo pacman -S --needed - < pkglist_pacman_repo.txt
}
create_symlinks() {
    echo "[*] Creating symlinks for config..."

    # Openbox
    ln -sf "$HOME/.dotfiles/.config/openbox" "$HOME/.config/openbox"

    # Thunar
    ln -sf "$HOME/.dotfiles/.config/Thunar" "$HOME/.config/Thunar"

    # GTK 3
# disabled (no gtk-3.0 tracked):     ln -sf "$HOME/.dotfiles/.config/gtk-3.0" "$HOME/.config/gtk-3.0"
}
enable_docker() {
    echo "[*] Enabling Docker service..."
    sudo systemctl enable --now docker.service
    sudo systemctl enable --now containerd.service
}
bootstrap() {
    echo "[*] Running full bootstrap..."
    install_packages
    create_symlinks
    # disabled: docker excluded from dotfiles bootstrap
    echo "[*] Bootstrap completed."
}

bootstrap
