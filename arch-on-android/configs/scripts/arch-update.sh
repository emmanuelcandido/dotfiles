#!/usr/bin/bash
# arch-update — Baixa e aplica dotfiles mais recentes (i3, polybar, etc.)
# Uso: arch-update
# Nota: ja criado como alias no .bashrc pelo setup-aliases.sh

TMP_DIR=/tmp/dotfiles-update
REPO_URL="https://github.com/emmanuelcandido/dotfiles.git"
CONFIG_DIR="$HOME/.config"

echo "[update] Baixando configs do repositorio..."
rm -rf "$TMP_DIR" 2>/dev/null

if ! git clone --depth 1 "$REPO_URL" "$TMP_DIR" 2>/dev/null; then
    echo "[update] ERRO: git clone falhou. Sem internet?"
    exit 1
fi

echo "[update] Aplicando configs..."
mkdir -p "$CONFIG_DIR/i3" \
         "$CONFIG_DIR/polybar/scripts" \
         "$CONFIG_DIR/dunst" \
         "$CONFIG_DIR/rofi" \
         "$CONFIG_DIR/ulauncher/user-themes/nord" \
         "$CONFIG_DIR/alacritty" \
         "$CONFIG_DIR/scripts" \
         "$CONFIG_DIR/wallpapers"

cp "$TMP_DIR/arch-on-android/configs/bash_aliases"                    "$HOME/.bash_aliases" 2>/dev/null
cp "$TMP_DIR/arch-on-android/configs/i3/config"                      "$CONFIG_DIR/i3/config" 2>/dev/null
cp "$TMP_DIR/arch-on-android/configs/polybar/config.ini"             "$CONFIG_DIR/polybar/config.ini" 2>/dev/null
cp "$TMP_DIR/arch-on-android/configs/polybar/scripts/updates.sh"     "$CONFIG_DIR/polybar/scripts/updates.sh" 2>/dev/null
cp "$TMP_DIR/arch-on-android/configs/polybar/scripts/spotify.sh"     "$CONFIG_DIR/polybar/scripts/spotify.sh" 2>/dev/null
cp "$TMP_DIR/arch-on-android/configs/polybar/scripts/ticker-crypto.sh" "$CONFIG_DIR/polybar/scripts/ticker-crypto.sh" 2>/dev/null
cp "$TMP_DIR/arch-on-android/configs/dunst/dunstrc"                  "$CONFIG_DIR/dunst/dunstrc" 2>/dev/null
cp "$TMP_DIR/arch-on-android/configs/rofi/config.rasi"               "$CONFIG_DIR/rofi/config.rasi" 2>/dev/null
cp "$TMP_DIR/arch-on-android/configs/alacritty/alacritty.yml"        "$CONFIG_DIR/alacritty/alacritty.yml" 2>/dev/null
cp "$TMP_DIR/arch-on-android/configs/scripts/power.sh"               "$CONFIG_DIR/scripts/power.sh" 2>/dev/null
cp "$TMP_DIR/arch-on-android/configs/scripts/arch-update.sh"         "$CONFIG_DIR/scripts/arch-update.sh" 2>/dev/null
cp "$TMP_DIR/arch-on-android/configs/scripts/notif-center.sh"       "$CONFIG_DIR/scripts/notif-center.sh" 2>/dev/null
cp "$TMP_DIR/arch-on-android/configs/wallpapers/0010.png"            "$CONFIG_DIR/wallpapers/0010.png" 2>/dev/null
cp "$TMP_DIR/arch-on-android/configs/ulauncher/nord/"*               "$CONFIG_DIR/ulauncher/user-themes/nord/" 2>/dev/null

chmod +x "$CONFIG_DIR/polybar/scripts/updates.sh" 2>/dev/null
chmod +x "$CONFIG_DIR/polybar/scripts/spotify.sh" 2>/dev/null
chmod +x "$CONFIG_DIR/polybar/scripts/ticker-crypto.sh" 2>/dev/null
chmod +x "$CONFIG_DIR/scripts/power.sh" 2>/dev/null
chmod +x "$CONFIG_DIR/scripts/arch-update.sh" 2>/dev/null
chmod +x "$CONFIG_DIR/scripts/notif-center.sh" 2>/dev/null

rm -rf "$TMP_DIR"

# Garante que .bashrc source o .bash_aliases
grep -q "bash_aliases" "$HOME/.bashrc" 2>/dev/null || {
    echo "" >> "$HOME/.bashrc"
    echo "# ArchDroid aliases" >> "$HOME/.bashrc"
    echo "[ -f \"$HOME/.bash_aliases\" ] && . \"$HOME/.bash_aliases\"" >> "$HOME/.bashrc"
}

# Symlink arch-update pra /usr/local/bin (ou pro PATH)
if [ -w /usr/local/bin ] 2>/dev/null; then
    ln -sf "$CONFIG_DIR/scripts/arch-update.sh" /usr/local/bin/arch-update 2>/dev/null
fi

echo "[update] OK — configs atualizadas. Reiniciando i3..."
i3-msg restart 2>/dev/null || true
