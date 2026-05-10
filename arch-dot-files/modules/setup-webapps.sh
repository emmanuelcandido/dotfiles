#!/usr/bin/env bash
# setup-webapps.sh — Cria webapp launchers como apps de sistema
# Uso: source modules/setup-webapps.sh && setup_webapps

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"
ICONS_DIR="${PROJECT_DIR}/icons"
APP_DIR="${HOME}/.local/share/applications"
DATA_DIR="${HOME}/.config/webapps"

setup_webapps() {
    mkdir -p "${APP_DIR}" "${DATA_DIR}"

    # Detecta o binário do Chromium
    local browser=""
    for b in chromium chromium-browser google-chrome-stable google-chrome; do
        command -v "$b" &>/dev/null && browser="$b" && break
    done

    if [ -z "$browser" ]; then
        echo "[webapps] Chromium não encontrado. Instale chromium ou google-chrome primeiro."
        return 1
    fi
    echo "[webapps] Usando ${browser}"

    # Lista de webapps: nome|url|perfil_isolado
    local webapps=(
        "Claude|https://claude.ai|"
        "Notion|https://notion.so|"
        "Calendar|https://calendar.google.com|"
        "Gmail|https://mail.google.com|"
        "WhatsApp|https://web.whatsapp.com|isolated"
        "YouTube|https://youtube.com|"
        "ChatGPT|https://chat.openai.com|isolated"
        "DeepL|https://deepl.com|"
        "Spotify|https://open.spotify.com|"
    )

    for entry in "${webapps[@]}"; do
        IFS='|' read -r name url isolated <<< "$entry"
        local exec_cmd="${browser} --app=${url} --no-first-run"
        local icon="chromium"
        local desktop_file="${APP_DIR}/webapp-${name,,}.desktop"

        # Perfil isolado para apps que precisam de conta separada
        if [ -n "$isolated" ]; then
            mkdir -p "${DATA_DIR}/${name,,}"
            exec_cmd+=" --user-data-dir=${DATA_DIR}/${name,,}"
        fi

        # Ícone customizado se existir
        local custom_icon="${ICONS_DIR}/${name,,}.png"
        [ -f "$custom_icon" ] && icon="$custom_icon"

        # Cria .desktop file (idempotente: não duplica)
        if [ ! -f "$desktop_file" ]; then
            cat > "$desktop_file" << EOF
[Desktop Entry]
Type=Application
Name=${name} (Web)
Exec=${exec_cmd}
Icon=${icon}
Terminal=false
Categories=Network;WebBrowser;
EOF
            chmod +x "$desktop_file"
            echo "[webapps] ✓ ${name}"
        else
            echo "[webapps] → ${name} já existe"
        fi
    done

    # Copia ícones para ~/.local/share/icons
    if [ -d "${ICONS_DIR}" ]; then
        mkdir -p "${HOME}/.local/share/icons"
        cp -rn "${ICONS_DIR}/"* "${HOME}/.local/share/icons/" 2>/dev/null || true
        echo "[webapps] Ícones copiados"
    fi

    # Update desktop database
    update-desktop-database "${APP_DIR}" 2>/dev/null || true
    echo "[webapps] Pronto! Webapps disponíveis no launcher."
}
