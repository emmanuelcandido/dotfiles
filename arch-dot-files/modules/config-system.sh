#!/usr/bin/env bash
# config-system.sh — Configurações de sistema (hostname, firewall, serviços)
# Uso: source modules/config-system.sh && config_system

config_system() {
    echo "[system] Configurando sistema..."

    # Hostname
    local current_hostname
    current_hostname=$(hostname)
    if [ "$current_hostname" = "archlinux" ] || [ "$current_hostname" = "localhost" ]; then
        read -rp "[system] Digite o hostname desejado [archbox]: " new_hostname
        new_hostname="${new_hostname:-archbox}"
        echo "${new_hostname}" | sudo tee /etc/hostname >/dev/null
        sudo sed -i "s/127.0.1.1.*/127.0.1.1\t${new_hostname}/" /etc/hosts 2>/dev/null
        echo "[system] Hostname definido como ${new_hostname}"
    else
        echo "[system] Hostname atual: ${current_hostname}"
    fi

    # Firewall (UFW)
    if command -v ufw &>/dev/null; then
        if ! sudo ufw status | grep -q "Status: active"; then
            echo "[system] Configurando UFW..."
            sudo ufw default deny incoming
            sudo ufw default allow outgoing
            sudo ufw allow ssh
            sudo ufw --force enable
            echo "[system] UFW ativado"
        else
            echo "[system] UFW já está ativo"
        fi
    fi

    # Serviços essenciais
    local services=("NetworkManager" "bluetooth" "pipewire" "wireplumber")
    for svc in "${services[@]}"; do
        if systemctl --user list-units --all 2>/dev/null | grep -q "${svc}"; then
            systemctl --user enable --now "${svc}" 2>/dev/null || true
        elif systemctl list-units --all 2>/dev/null | grep -q "${svc}"; then
            sudo systemctl enable --now "${svc}" 2>/dev/null || true
        fi
    done

    # Acpi (para botão de sleep, etc)
    if command -v acpid &>/dev/null; then
        sudo systemctl enable --now acpid 2>/dev/null || true
    fi

    echo "[system] Configurações aplicadas!"
}
