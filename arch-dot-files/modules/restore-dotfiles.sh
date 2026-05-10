#!/usr/bin/env bash
# restore-dotfiles.sh — Restaura dotfiles do pCloud (apenas não-versionáveis)
# Uso: source modules/restore-dotfiles.sh && restore_dotfiles
# Regra: Git tem prioridade. pCloud só restaura o que não está versionado.

PCLOUD_MACHINE="${HOME}/pcloud/machines/linux"

restore_dotfiles() {
    if ! mountpoint -q "${HOME}/pcloud" 2>/dev/null; then
        echo "[restore] pCloud não está montado. Pulando restore."
        return 1
    fi

    if [ ! -d "${PCLOUD_MACHINE}" ]; then
        echo "[restore] Nenhum backup encontrado em ${PCLOUD_MACHINE}"
        return 1
    fi

    echo "[restore] Restaurando do pCloud (apenas não-versionáveis)..."

    # Browser profiles (nunca vão pro git)
    if [ -d "${PCLOUD_MACHINE}/browser" ]; then
        echo "[restore] Restaurando perfis de navegador..."
        cp -rn "${PCLOUD_MACHINE}/browser/"* "${HOME}/.config/" 2>/dev/null || true
    fi

    # Wallpapers
    if [ -d "${PCLOUD_MACHINE}/wallpapers" ]; then
        mkdir -p "${HOME}/wallpapers"
        cp -rn "${PCLOUD_MACHINE}/wallpapers/"* "${HOME}/wallpapers/" 2>/dev/null || true
        echo "[restore] Wallpapers restaurados"
    fi

    # SSH keys (se houver)
    if [ -d "${PCLOUD_MACHINE}/ssh" ]; then
        mkdir -p "${HOME}/.ssh"
        cp -rn "${PCLOUD_MACHINE}/ssh/"* "${HOME}/.ssh/" 2>/dev/null || true
        chmod 600 "${HOME}/.ssh/"* 2>/dev/null || true
        echo "[restore] Chaves SSH restauradas"
    fi

    echo "[restore] Restore concluído. Nada foi sobrescrito (cp -rn)."
}

backup_dotfiles() {
    if ! mountpoint -q "${HOME}/pcloud" 2>/dev/null; then
        echo "[backup] pCloud não está montado."
        return 1
    fi

    mkdir -p "${PCLOUD_MACHINE}/browser" "${PCLOUD_MACHINE}/wallpapers" "${PCLOUD_MACHINE}/ssh"

    echo "[backup] Fazendo backup de dados não-versionáveis para pCloud..."

    # Browser profiles
    for profile in "${HOME}/.config/chromium" "${HOME}/.config/brave" "${HOME}/.config/microsoft-edge"; do
        [ -d "$profile" ] && cp -r "$profile" "${PCLOUD_MACHINE}/browser/" 2>/dev/null && echo "[backup] Backup de $(basename $profile)"
    done

    # Wallpapers
    [ -d "${HOME}/wallpapers" ] && cp -r "${HOME}/wallpapers/"* "${PCLOUD_MACHINE}/wallpapers/" 2>/dev/null

    # SSH
    [ -d "${HOME}/.ssh" ] && cp -r "${HOME}/.ssh/"* "${PCLOUD_MACHINE}/ssh/" 2>/dev/null

    echo "[backup] Backup concluído em ${PCLOUD_MACHINE}"
}
