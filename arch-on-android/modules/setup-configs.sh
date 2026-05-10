#!/data/data/com.termux/files/usr/bin/bash
# modules/setup-configs.sh — Copia dotfiles do repo para dentro do Arch proot

setup_configs() {
    echo "[configs] Aplicando dotfiles (i3, polybar, dunst, rofi, wallpaper)..."
    echo "[configs] Baixando configs do repositório dentro do Arch..."

    run_in_arch "
        REPO_URL='https://github.com/emmanuelcandido/dotfiles.git'
        TMP_REPO='/tmp/dotfiles-configs'
        rm -rf \"\$TMP_REPO\" 2>/dev/null

        git clone --depth 1 \"\$REPO_URL\" \"\$TMP_REPO\" 2>/dev/null || {
            echo 'ERRO: Falha ao baixar repositório'
            exit 1
        }

        mkdir -p \"\$HOME/.config/i3\" \
                 \"\$HOME/.config/polybar/scripts\" \
                 \"\$HOME/.config/dunst\" \
                 \"\$HOME/.config/rofi\" \
                 \"\$HOME/.config/wallpapers\"

        cp \"\$TMP_REPO/arch-on-android/configs/i3/config\"           \"\$HOME/.config/i3/config\"
        cp \"\$TMP_REPO/arch-on-android/configs/polybar/config.ini\"  \"\$HOME/.config/polybar/config.ini\"
        cp \"\$TMP_REPO/arch-on-android/configs/polybar/scripts/updates.sh\" \"\$HOME/.config/polybar/scripts/updates.sh\"
        cp \"\$TMP_REPO/arch-on-android/configs/dunst/dunstrc\"       \"\$HOME/.config/dunst/dunstrc\"
        cp \"\$TMP_REPO/arch-on-android/configs/rofi/config.rasi\"    \"\$HOME/.config/rofi/config.rasi\"
        cp \"\$TMP_REPO/arch-on-android/configs/wallpapers/0010.png\" \"\$HOME/.config/wallpapers/0010.png\"

        chmod +x \"\$HOME/.config/polybar/scripts/updates.sh\" 2>/dev/null

        rm -rf \"\$TMP_REPO\"
        echo 'Configs aplicadas! Reinicie o i3: Mod+Shift+R'
    " 2>/dev/null || echo "[configs] AVISO: Falha ao aplicar configs (apply-configs manual)"

    echo "[configs] Dotfiles aplicados!"
}
