#!/data/data/com.termux/files/usr/bin/bash
# modules/setup-proot.sh — Instala proot-distro + Arch Linux

setup_proot() {
    echo "[proot] Atualizando Termux (pode levar alguns minutos)..."
    pkg update -y || echo "[proot] AVISO: pkg update falhou, continuando..."
    pkg upgrade -y || true

    echo "[proot] Instalando proot-distro..."
    pkg install -y proot-distro x11-repo tur-repo || {
        echo "[proot] ERRO: Falha ao instalar proot-distro"
        exit 1
    }

    if proot-distro list 2>/dev/null | grep -q "archlinux"; then
        echo "[proot] Arch Linux já instalado. Atualizando..."
        proot-distro update archlinux || true
    else
        echo "[proot] Instalando Arch Linux (pode levar alguns minutos)..."
        proot-distro install archlinux || {
            echo "[proot] ERRO: Falha ao instalar Arch Linux"
            exit 1
        }
    fi

    echo "[proot] Configurando DNS..."
    proot-distro login archlinux -- bash -c "
        echo 'nameserver 8.8.8.8' > /etc/resolv.conf
        echo 'nameserver 1.1.1.1' >> /etc/resolv.conf
        chmod 644 /etc/resolv.conf
    " || echo "[proot] AVISO: DNS config falhou (pode ser resolvido depois)"

    echo "[proot] Arch Linux pronto!"
}

# Comando auxiliar para executar comandos dentro do proot
run_in_arch() {
    proot-distro login archlinux -- bash -c "$*"
}
