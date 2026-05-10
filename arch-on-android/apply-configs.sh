#!/data/data/com.termux/files/usr/bin/bash
# apply-configs.sh — Standalone: clona repo e copia configs
# Uso: bash apply-configs.sh
# Nao instala pacotes — so atualiza configs para iteracao rapida

REPO_URL="https://github.com/emmanuelcandido/dotfiles.git"
TMP_REPO="/tmp/dotfiles-configs"

echo "[apply] Baixando configs do repositorio..."
rm -rf "$TMP_REPO" 2>/dev/null
git clone --depth 1 "$REPO_URL" "$TMP_REPO" 2>/dev/null || {
    echo "[apply] ERRO: Falha ao baixar repositorio. Verifique conexao."
    exit 1
}

echo "[apply] Copiando configs..."
mkdir -p "$HOME/.config/i3" \
         "$HOME/.config/polybar/scripts" \
         "$HOME/.config/dunst" \
         "$HOME/.config/rofi" \
         "$HOME/.config/alacritty" \
         "$HOME/.config/scripts" \
         "$HOME/.config/wallpapers"

cp "$TMP_REPO/arch-on-android/configs/i3/config"                      "$HOME/.config/i3/config"
cp "$TMP_REPO/arch-on-android/configs/polybar/config.ini"             "$HOME/.config/polybar/config.ini"
cp "$TMP_REPO/arch-on-android/configs/polybar/scripts/updates.sh"     "$HOME/.config/polybar/scripts/updates.sh"
cp "$TMP_REPO/arch-on-android/configs/polybar/scripts/spotify.sh"     "$HOME/.config/polybar/scripts/spotify.sh"
cp "$TMP_REPO/arch-on-android/configs/polybar/scripts/ticker-crypto.sh" "$HOME/.config/polybar/scripts/ticker-crypto.sh"
cp "$TMP_REPO/arch-on-android/configs/dunst/dunstrc"                  "$HOME/.config/dunst/dunstrc"
cp "$TMP_REPO/arch-on-android/configs/rofi/config.rasi"               "$HOME/.config/rofi/config.rasi"
cp "$TMP_REPO/arch-on-android/configs/alacritty/alacritty.yml"        "$HOME/.config/alacritty/alacritty.yml"
cp "$TMP_REPO/arch-on-android/configs/scripts/power.sh"               "$HOME/.config/scripts/power.sh"
cp "$TMP_REPO/arch-on-android/configs/wallpapers/0010.png"            "$HOME/.config/wallpapers/0010.png"

chmod +x "$HOME/.config/polybar/scripts/updates.sh" 2>/dev/null
chmod +x "$HOME/.config/polybar/scripts/spotify.sh" 2>/dev/null
chmod +x "$HOME/.config/polybar/scripts/ticker-crypto.sh" 2>/dev/null
chmod +x "$HOME/.config/scripts/power.sh" 2>/dev/null

rm -rf "$TMP_REPO"

echo "[apply] Configs aplicadas!"
echo "[apply] Reinicie o i3: Mod+Shift+R  (ou 'i3-msg restart')"
