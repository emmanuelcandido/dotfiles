#!/data/data/com.termux/files/usr/bin/bash
# modules/setup-audio.sh — PulseAudio + microfone

setup_audio() {
    echo "[audio] Instalando PulseAudio..."
    pkg install -y pulseaudio || echo "[audio] AVISO: Falha ao instalar PulseAudio"

    echo "[audio] Configurando PulseAudio para TCP localhost..."
    mkdir -p ~/.config/pulse
    cat > ~/.config/pulse/default.pa << 'EOF'
load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
load-module module-device-manager
.include /etc/pulse/default.pa
EOF

    echo "[audio] Configurando cliente PulseAudio dentro do Arch..."
    run_in_arch "cat > /etc/pulse/client.conf << 'PULSE'
default-server = 127.0.0.1
autospawn = no
PULSE" || echo "[audio] AVISO: Config do Pulse dentro do proot falhou"

    echo "[audio] PulseAudio configurado para TCP localhost"
}
