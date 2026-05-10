#!/usr/bin/env bash
# mount-pcloud.sh — Monta pCloud via rclone + systemd service
# Uso: source modules/mount-pcloud.sh && mount_pcloud

MOUNT_POINT="${HOME}/pcloud"
RCLONE_REMOTE="pcloud"

mount_pcloud() {
    echo "[pCloud] Verificando rclone..."
    if ! command -v rclone &>/dev/null; then
        echo "[pCloud] rclone não encontrado. Instale com: sudo pacman -S rclone"
        return 1
    fi

    if ! rclone listremotes 2>/dev/null | grep -q "${RCLONE_REMOTE}:"; then
        echo "[pCloud] Remote '${RCLONE_REMOTE}' não configurado."
        echo "[pCloud] Execute: rclone config"
        echo "[pCloud] Ou configure automaticamente com:"
        echo "    rclone config create ${RCLONE_REMOTE} pcloud"
        return 1
    fi

    if mountpoint -q "${MOUNT_POINT}" 2>/dev/null; then
        echo "[pCloud] Já montado em ${MOUNT_POINT}"
        return 0
    fi

    mkdir -p "${MOUNT_POINT}"
    echo "[pCloud] Montando ${RCLONE_REMOTE} em ${MOUNT_POINT}..."
    rclone mount "${RCLONE_REMOTE}:" "${MOUNT_POINT}" \
        --daemon \
        --vfs-cache-mode full \
        --vfs-cache-max-age 72h \
        --vfs-cache-max-size 10G \
        --dir-cache-time 10m \
        --poll-interval 1m

    sleep 2
    if mountpoint -q "${MOUNT_POINT}" 2>/dev/null; then
        echo "[pCloud] Montado com sucesso em ${MOUNT_POINT}"
    else
        echo "[pCloud] Falha ao montar. Verifique: rclone mount ${RCLONE_REMOTE}: ${MOUNT_POINT}"
        return 1
    fi
}

install_pcloud_service() {
    echo "[pCloud] Instalando serviço systemd para montagem automática..."
    cat > /tmp/pcloud-mount.service << 'EOF'
[Unit]
Description=pCloud mount (rclone)
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStartPre=/usr/bin/rclone mkdir pcloud: -v
ExecStart=/usr/bin/rclone mount pcloud: %h/pcloud --vfs-cache-mode full --vfs-cache-max-age 72h --vfs-cache-max-size 10G --dir-cache-time 10m --poll-interval 1m
ExecStop=/usr/bin/fusermount3 -u %h/pcloud
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF
    sudo mv /tmp/pcloud-mount.service /etc/systemd/user/pcloud-mount.service
    systemctl --user daemon-reload
    systemctl --user enable --now pcloud-mount.service
    echo "[pCloud] Serviço instalado. Gerencie com: systemctl --user {start,stop,status} pcloud-mount.service"
}
