#!/data/data/com.termux/files/usr/bin/bash
# modules/setup-tools.sh — Apps e ferramentas

setup_tools() {
    echo "[tools] Instalando apps essenciais..."
    run_in_arch "
        pacman -S --noconfirm vlc mpv qbittorrent evince file-roller \
            git ripgrep jq curl wget unzip zip python python-pip \
            nodejs-lts-iron go rustup make gcc \
            rclone syncthing htop brightnessctl acpi xdg-utils \
            udisks2 gvfs gvfs-mtp \
            fish fd fzf zoxide eza bat neofetch \
            openssh ufw
    " || echo "[tools] AVISO: Alguns pacotes podem estar indisponíveis"

    echo "[tools] Instalando Chromium (pode usar ~700MB RAM)..."
    run_in_arch "pacman -S --noconfirm chromium" || \
        echo "[tools] Chromium pulado (muita RAM para proot?)"

    echo "[tools] Apps instalados!"
}
