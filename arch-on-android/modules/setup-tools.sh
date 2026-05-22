#!/data/data/com.termux/files/usr/bin/bash
# modules/setup-tools.sh — Apps e ferramentas

setup_tools() {
    echo "[tools] Instalando apps essenciais..."
    run_in_arch "
        pacman -S --noconfirm --needed vlc mpv qbittorrent evince file-roller \
            git ripgrep jq curl wget unzip zip python python-pip \
            nodejs-lts-iron go rustup make gcc \
            rclone syncthing htop brightnessctl acpi xdg-utils \
            udisks2 gvfs gvfs-mtp \
            fish fd fzf zoxide eza bat neofetch \
            openssh ufw
    " || echo "[tools] AVISO: Alguns pacotes podem estar indisponíveis"

    echo "[tools] Instalando ferramentas de tema..."
    run_in_arch "
        pacman -S --noconfirm --needed kvantum qt5ct
    " || echo "[tools] AVISO: Ferramentas de tema indisponíveis"

    echo "[tools] Instalando Nordzy-icon-theme..."
    run_in_arch "
        cd /tmp &&
        curl -sL https://api.github.com/repos/MolassesLover/Nordzy-icon/releases/latest |
        grep tarball_url | cut -d'\"' -f4 | xargs curl -sL | tar xz &&
        cd Nordzy-icon-*/ &&
        bash install.sh
    " || echo "[tools] AVISO: Nordzy-icons pulado (erro ao instalar)"

    echo "[tools] Instalando pikaur (AUR helper)..."
    run_in_arch "
        pacman -S --noconfirm --needed base-devel git &&
        git clone https://aur.archlinux.org/pikaur.git /tmp/pikaur &&
        cd /tmp/pikaur &&
        useradd -m builder 2>/dev/null || true &&
        chown -R builder:builder /tmp/pikaur &&
        su builder -c 'cd /tmp/pikaur && makepkg -si --noconfirm' &&
        userdel -r builder 2>/dev/null || true &&
        rm -rf /tmp/pikaur
    " || echo "[tools] pikaur pulado (erro ao compilar)"

    echo "[tools] Instalando Chromium (pode usar ~700MB RAM)..."
    run_in_arch "pacman -S --noconfirm --needed chromium" || \
        echo "[tools] Chromium pulado (muita RAM para proot?)"

    echo "[tools] Apps instalados!"
}
