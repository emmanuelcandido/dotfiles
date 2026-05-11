#!/data/data/com.termux/files/usr/bin/bash
# modules/setup-aliases.sh — Cria start-arch, stop-arch, uninstall-arch no ~

setup_aliases() {
    local BIN_DIR="${HOME}/.local/bin"
    mkdir -p "${BIN_DIR}"

    # ── start-arch ──
    cat > "${BIN_DIR}/start-arch" << 'STARTEOF'
#!/data/data/com.termux/files/usr/bin/bash
# start-arch — Inicia Arch Linux + i3 via proot-distro + Termux:X11

export DISPLAY=:0
export PULSE_SERVER=127.0.0.1

# GPU config
export MESA_NO_ERROR=1
export MESA_GL_VERSION_OVERRIDE=4.6
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
export MESA_VK_WSI_PRESENT_MODE=immediate
export ZINK_DESCRIPTORS=lazy

cleanup() {
    echo "Parando sessão..."
    pkill -9 -f "termux.x11" 2>/dev/null
    pkill -9 -f "pulseaudio" 2>/dev/null
    exit 0
}
trap cleanup SIGINT SIGTERM

# Inicia PulseAudio (unset PULSE_SERVER temporariamente senão ele recusa iniciar)
pulseaudio --check 2>/dev/null || {
    echo "[audio] Iniciando PulseAudio..."
    env -u PULSE_SERVER pulseaudio --start --exit-idle-time=-1
    sleep 1
    pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null
}

# Instala Termux:X11 se não existir
command -v termux-x11 >/dev/null 2>&1 || {
    echo "[x11] Instalando Termux:X11..."
    pkg install -y termux-x11 2>/dev/null || true
}

echo "[x11] Iniciando Termux:X11..."
termux-x11 :0 -ac -x 1920 -y 1080 &
sleep 3

echo "[arch] Iniciando Arch Linux + i3..."
echo "      Abra o app Termux:X11 para ver o desktop."
echo "      Pressione Ctrl+C para parar."

# Entra no proot com forwarding de áudio + GPU + X11
proot-distro login archlinux \
    --termux-home \
    --shared-tmp \
    -- bash -c "
        export DISPLAY=:0
        export PULSE_SERVER=127.0.0.1
        export MESA_NO_ERROR=1
        export MESA_GL_VERSION_OVERRIDE=4.6
        export GALLIUM_DRIVER=zink
        export MESA_LOADER_DRIVER_OVERRIDE=zink
        export TU_DEBUG=noconform
        export MESA_VK_WSI_PRESENT_MODE=immediate
        export ZINK_DESCRIPTORS=lazy

        # Baixa configs mais recentes do repo
        if [ -d /tmp/dotfiles-configs ]; then rm -rf /tmp/dotfiles-configs; fi
        git clone --depth 1 https://github.com/emmanuelcandido/dotfiles.git /tmp/dotfiles-configs 2>/dev/null
        if [ -f /tmp/dotfiles-configs/arch-on-android/configs/i3/config ]; then
            mkdir -p "$HOME/.config/i3" "$HOME/.config/polybar/scripts" \
                     "$HOME/.config/dunst" "$HOME/.config/rofi" \
                     "$HOME/.config/alacritty" "$HOME/.config/scripts" \
                     "$HOME/.config/wallpapers" "$HOME/.config/picom"
            cp /tmp/dotfiles-configs/arch-on-android/configs/i3/config                      "$HOME/.config/i3/config"
            cp /tmp/dotfiles-configs/arch-on-android/configs/polybar/config.ini             "$HOME/.config/polybar/config.ini"
            cp /tmp/dotfiles-configs/arch-on-android/configs/polybar/scripts/updates.sh     "$HOME/.config/polybar/scripts/updates.sh"
            cp /tmp/dotfiles-configs/arch-on-android/configs/polybar/scripts/spotify.sh     "$HOME/.config/polybar/scripts/spotify.sh"
            cp /tmp/dotfiles-configs/arch-on-android/configs/polybar/scripts/ticker-crypto.sh "$HOME/.config/polybar/scripts/ticker-crypto.sh"
            cp /tmp/dotfiles-configs/arch-on-android/configs/dunst/dunstrc                  "$HOME/.config/dunst/dunstrc"
            cp /tmp/dotfiles-configs/arch-on-android/configs/rofi/config.rasi               "$HOME/.config/rofi/config.rasi"
            cp /tmp/dotfiles-configs/arch-on-android/configs/alacritty/alacritty.yml        "$HOME/.config/alacritty/alacritty.yml"
            cp /tmp/dotfiles-configs/arch-on-android/configs/picom/picom.conf               "$HOME/.config/picom/picom.conf"
            cp /tmp/dotfiles-configs/arch-on-android/configs/scripts/power.sh               "$HOME/.config/scripts/power.sh"
            cp /tmp/dotfiles-configs/arch-on-android/configs/wallpapers/0010.png            "$HOME/.config/wallpapers/0010.png"
            chmod +x "$HOME/.config/polybar/scripts/updates.sh" 2>/dev/null
            chmod +x "$HOME/.config/polybar/scripts/spotify.sh" 2>/dev/null
            chmod +x "$HOME/.config/polybar/scripts/ticker-crypto.sh" 2>/dev/null
            chmod +x "$HOME/.config/scripts/power.sh" 2>/dev/null
        fi
        rm -rf /tmp/dotfiles-configs

        # Seta wallpaper (nord solid)
        command -v xsetroot >/dev/null 2>&1 || pacman -S --noconfirm xorg-xsetroot >/dev/null 2>&1
        xsetroot -solid '#2E3440' 2>/dev/null || true

        # Inicia picom (xrender para proot)
        picom --config /etc/xdg/picom/picom.conf -b 2>/dev/null || true

        # Inicia i3
        exec i3 2>/dev/null || exec i3-wm
    "
STARTEOF
    chmod +x "${BIN_DIR}/start-arch"

    # ── stop-arch ──
    cat > "${BIN_DIR}/stop-arch" << 'STOPEOF'
#!/data/data/com.termux/files/usr/bin/bash
# stop-arch — Para sessão Arch + limpa processos
echo "Parando ArchDroid..."
pkill -9 -f "proot-distro login archlinux" 2>/dev/null
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "pulseaudio" 2>/dev/null
pkill -9 -f "picom" 2>/dev/null
echo "ArchDroid parado."
STOPEOF
    chmod +x "${BIN_DIR}/stop-arch"

    # ── apply-configs ──
    cat > "${BIN_DIR}/apply-configs" << 'CONFIGSEOF'
#!/data/data/com.termux/files/usr/bin/bash
# apply-configs — Baixa e aplica dotfiles do repo no Arch proot
# Uso: apply-configs
# Nota: O start-arch já faz isso automaticamente.

REPO_URL="https://github.com/emmanuelcandido/dotfiles.git"
TMP_REPO="${HOME}/.cache/apply-configs/dotfiles"

echo "Baixando configs do repositório..."
rm -rf "$TMP_REPO" 2>/dev/null
if ! git clone --depth 1 "$REPO_URL" "$TMP_REPO"; then
    echo "ERRO: git clone falhou."
    echo "Comando manual: git clone --depth 1 $REPO_URL $TMP_REPO"
    exit 1
fi

echo "Copiando configs..."
mkdir -p "$HOME/.config/i3" "$HOME/.config/polybar/scripts" "$HOME/.config/dunst" "$HOME/.config/rofi" "$HOME/.config/alacritty" "$HOME/.config/scripts" "$HOME/.config/wallpapers" "$HOME/.config/picom"
cp "$TMP_REPO/arch-on-android/configs/i3/config"                      "$HOME/.config/i3/config" 2>/dev/null
cp "$TMP_REPO/arch-on-android/configs/polybar/config.ini"             "$HOME/.config/polybar/config.ini" 2>/dev/null
cp "$TMP_REPO/arch-on-android/configs/polybar/scripts/updates.sh"     "$HOME/.config/polybar/scripts/updates.sh" 2>/dev/null
cp "$TMP_REPO/arch-on-android/configs/polybar/scripts/spotify.sh"     "$HOME/.config/polybar/scripts/spotify.sh" 2>/dev/null
cp "$TMP_REPO/arch-on-android/configs/polybar/scripts/ticker-crypto.sh" "$HOME/.config/polybar/scripts/ticker-crypto.sh" 2>/dev/null
cp "$TMP_REPO/arch-on-android/configs/dunst/dunstrc"                  "$HOME/.config/dunst/dunstrc" 2>/dev/null
cp "$TMP_REPO/arch-on-android/configs/rofi/config.rasi"               "$HOME/.config/rofi/config.rasi" 2>/dev/null
cp "$TMP_REPO/arch-on-android/configs/alacritty/alacritty.yml"        "$HOME/.config/alacritty/alacritty.yml" 2>/dev/null
cp "$TMP_REPO/arch-on-android/configs/picom/picom.conf"               "$HOME/.config/picom/picom.conf" 2>/dev/null
cp "$TMP_REPO/arch-on-android/configs/scripts/power.sh"               "$HOME/.config/scripts/power.sh" 2>/dev/null
cp "$TMP_REPO/arch-on-android/configs/wallpapers/0010.png"            "$HOME/.config/wallpapers/0010.png" 2>/dev/null

chmod +x "$HOME/.config/polybar/scripts/updates.sh" 2>/dev/null
chmod +x "$HOME/.config/polybar/scripts/spotify.sh" 2>/dev/null
chmod +x "$HOME/.config/polybar/scripts/ticker-crypto.sh" 2>/dev/null
chmod +x "$HOME/.config/scripts/power.sh" 2>/dev/null

rm -rf "$TMP_REPO"
echo "Configs aplicadas! Reinicie o i3: Mod+Shift+R"
CONFIGSEOF
    chmod +x "${BIN_DIR}/apply-configs"

    # ── uninstall-arch ──
    cat > "${BIN_DIR}/uninstall-arch" << 'UNINSTALLEOF'
#!/data/data/com.termux/files/usr/bin/bash
# uninstall-arch — Remove Arch Linux + scripts completamente
echo "AVISO: Isso vai remover todo o Arch Linux e configurações!"
echo "       Dados em ~/archroid-backup/ serão preservados se existirem."
read -rp "Tem certeza? (yes/N): " confirm
[ "$confirm" != "yes" ] && echo "Cancelado." && exit 1

echo "Removendo Arch Linux..."
"${HOME}/stop-arch" 2>/dev/null || true
proot-distro remove archlinux 2>/dev/null || true

echo "Removendo scripts..."
rm -f "${HOME}/start-arch" "${HOME}/stop-arch" "${HOME}/uninstall-arch"

echo "Arch Linux removido. Reinstale com: bash setup-archroid.sh"
UNINSTALLEOF
    chmod +x "${BIN_DIR}/uninstall-arch"

    # Adiciona ao PATH se não existir
    if ! grep -q "local/bin" ~/.bashrc 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi
    if ! grep -q "local/bin" ~/.zshrc 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
    fi

    # Symlinks direto no ~ também para acesso fácil
    ln -sf "${BIN_DIR}/start-arch" "${HOME}/start-arch"
    ln -sf "${BIN_DIR}/stop-arch" "${HOME}/stop-arch"
    ln -sf "${BIN_DIR}/uninstall-arch" "${HOME}/uninstall-arch"
    ln -sf "${BIN_DIR}/apply-configs" "${HOME}/apply-configs"

    # ── start-arch-cli ──
    cat > "${BIN_DIR}/start-arch-cli" << 'CLIEOF'
#!/data/data/com.termux/files/usr/bin/bash
# start-arch-cli — Apenas login no Arch (sem X11)
export PULSE_SERVER=127.0.0.1
export MESA_NO_ERROR=1
export MESA_GL_VERSION_OVERRIDE=4.6
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
export MESA_VK_WSI_PRESENT_MODE=immediate
export ZINK_DESCRIPTORS=lazy

exec proot-distro login archlinux --termux-home --shared-tmp
CLIEOF
    chmod +x "${BIN_DIR}/start-arch-cli"

    # ── start-kde ──
    cat > "${BIN_DIR}/start-kde" << 'KDEEOF'
#!/data/data/com.termux/files/usr/bin/bash
# start-kde — Inicia Arch Linux + KDE Plasma via Termux:X11

export DISPLAY=:0
export PULSE_SERVER=127.0.0.1

# GPU config
export MESA_NO_ERROR=1
export MESA_GL_VERSION_OVERRIDE=4.6
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
export MESA_VK_WSI_PRESENT_MODE=immediate
export ZINK_DESCRIPTORS=lazy

cleanup() {
    echo "Parando sessão..."
    pkill -9 -f "termux.x11" 2>/dev/null
    pkill -9 -f "pulseaudio" 2>/dev/null
    exit 0
}
trap cleanup SIGINT SIGTERM

# Inicia PulseAudio
pulseaudio --check 2>/dev/null || {
    echo "[audio] Iniciando PulseAudio..."
    env -u PULSE_SERVER pulseaudio --start --exit-idle-time=-1
    sleep 1
    pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null
}

# Instala Termux:X11 se não existir
command -v termux-x11 >/dev/null 2>&1 || {
    echo "[x11] Instalando Termux:X11..."
    pkg install -y termux-x11 2>/dev/null || true
}

echo "[x11] Iniciando Termux:X11..."
termux-x11 :0 -ac -x 1920 -y 1080 &
sleep 3

echo "[kde] Iniciando Arch Linux + KDE Plasma..."
echo "      Abra o app Termux:X11 para ver o desktop."
echo "      Pressione Ctrl+C para parar."

proot-distro login archlinux \
    --termux-home \
    --shared-tmp \
    -- bash -c "
        export DISPLAY=:0
        export PULSE_SERVER=127.0.0.1
        export MESA_NO_ERROR=1
        export MESA_GL_VERSION_OVERRIDE=4.6
        export GALLIUM_DRIVER=zink
        export MESA_LOADER_DRIVER_OVERRIDE=zink
        export TU_DEBUG=noconform
        export MESA_VK_WSI_PRESENT_MODE=immediate
        export ZINK_DESCRIPTORS=lazy
        export DESKTOP_SESSION=plasma
        export XDG_SESSION_DESKTOP=KDE
        export XDG_CURRENT_DESKTOP=KDE

        exec startplasma-x11 2>/dev/null
    "
KDEEOF
    chmod +x "${BIN_DIR}/start-kde"

    # Symlinks
    ln -sf "${BIN_DIR}/start-kde" "${HOME}/start-kde"
    ln -sf "${BIN_DIR}/start-arch-cli" "${HOME}/start-arch-cli"

    echo "[aliases] Comandos criados: start-arch, start-arch-cli, start-kde, stop-arch, uninstall-arch, apply-configs"
}
