#!/data/data/com.termux/files/usr/bin/bash
# modules/setup-audio.sh — PulseAudio + microfone

setup_audio() {
    echo "[audio] Instalando PulseAudio..."

    pkg install -y pulseaudio > /dev/null 2>&1

    # Cria config para aceitar conexão TCP local
    mkdir -p ~/.config/pulse
    cat > ~/.config/pulse/default.pa << 'EOF'
load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
load-module module-device-manager
.include /etc/pulse/default.pa
EOF

    # Config dentro do proot para usar PulseAudio do host
    run_in_arch "cat > /etc/pulse/client.conf << 'PULSE'
default-server = 127.0.0.1
autospawn = no
PULSE" 2>/dev/null || true

    echo "[audio] PulseAudio configurado para TCP localhost"
}
