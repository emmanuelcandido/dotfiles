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

# Inicia PulseAudio se não estiver rodando
pulseaudio --check 2>/dev/null || {
    echo "[audio] Iniciando PulseAudio..."
    pulseaudio --start --exit-idle-time=-1
    sleep 1
    pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null
}

# Inicia Termux:X11
echo "[x11] Iniciando Termux:X11..."
termux-x11 :0 -ac &
sleep 3

# Seta wallpaper (default nord)
WALLPAPER_SRC="${HOME}/.config/archroid-wallpaper.png"
if [ -f "$WALLPAPER_SRC" ]; then
    WALL_CMD="feh --bg-fill ${WALLPAPER_SRC}"
else
    WALL_CMD="xsetroot -solid '#2E3440'"
fi

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

        ${WALL_CMD}

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

    echo "[aliases] Comandos criados: start-arch, stop-arch, uninstall-arch"
}
