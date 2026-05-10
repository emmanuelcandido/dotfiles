#!/data/data/com.termux/files/usr/bin/bash
# modules/setup-configs.sh — Copia dotfiles do repo para dentro do Arch proot

setup_configs() {
    echo "[configs] Aplicando dotfiles (i3, polybar, dunst, rofi)..."
    echo "[configs] Baixando configs do repositório dentro do Arch..."

    run_in_arch "
        REPO_URL='https://github.com/emmanuelcandido/dotfiles.git'
        TMP_REPO='/tmp/dotfiles-configs'
        rm -rf \"\$TMP_REPO\" 2>/dev/null

        git clone --depth 1 \"\$REPO_URL\" \"\$TMP_REPO\" 2>/dev/null || {
            echo 'ERRO: Falha ao baixar repositório'
            exit 1
        }

        mkdir -p \"\$HOME/.config/i3\" \"\$HOME/.config/polybar\" \"\$HOME/.config/dunst\" \"\$HOME/.config/rofi\"
        cp \"\$TMP_REPO/arch-on-android/configs/i3/config\" \"\$HOME/.config/i3/config\" 2>/dev/null
        cp \"\$TMP_REPO/arch-on-android/configs/polybar/config.ini\" \"\$HOME/.config/polybar/config.ini\" 2>/dev/null
        cp \"\$TMP_REPO/arch-on-android/configs/dunst/dunstrc\" \"\$HOME/.config/dunst/dunstrc\" 2>/dev/null
        cp \"\$TMP_REPO/arch-on-android/configs/rofi/config.rasi\" \"\$HOME/.config/rofi/config.rasi\" 2>/dev/null

        rm -rf \"\$TMP_REPO\"
        echo 'Configs aplicadas!'
    " 2>/dev/null || echo "[configs] AVISO: Falha ao aplicar configs (pode fazer manual com apply-configs)"

    echo "[configs] Dotfiles aplicados!"
}
