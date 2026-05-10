#!/data/data/com.termux/files/usr/bin/bash
# modules/setup-proot.sh — Instala proot-distro + Arch Linux

setup_proot() {
    echo "[proot] Atualizando Termux..."
    yes | pkg update -y > /dev/null 2>&1
    yes | pkg upgrade -y > /dev/null 2>&1

    echo "[proot] Instalando proot-distro..."
    pkg install -y proot-distro x11-repo tur-repo > /dev/null 2>&1

    if proot-distro list 2>/dev/null | grep -q "archlinux"; then
        echo "[proot] Arch Linux já instalado. Atualizando..."
        proot-distro update archlinux > /dev/null 2>&1 || true
    else
        echo "[proot] Instalando Arch Linux (pode levar alguns minutos)..."
        proot-distro install archlinux
    fi

    # Correção de DNS para o proot
    proot-distro login archlinux -- bash -c "
        echo 'nameserver 8.8.8.8' > /etc/resolv.conf
        echo 'nameserver 1.1.1.1' >> /etc/resolv.conf
        chmod 644 /etc/resolv.conf
    " 2>/dev/null || true

    echo "[proot] Arch Linux pronto!"
}

# Comando auxiliar para executar comandos dentro do proot
run_in_arch() {
    proot-distro login archlinux -- bash -c "$*"
}
