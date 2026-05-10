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
            openssh ufw > /dev/null 2>&1
    " 2>/dev/null || echo "[tools] AVISO: alguns pacotes podem estar indisponíveis"

    # Chromium (último, bulk)
    run_in_arch "pacman -S --noconfirm chromium > /dev/null 2>&1" || \
        echo "[tools] Chromium não instalado (muita RAM para proot?)"

    echo "[tools] Apps instalados!"
}
