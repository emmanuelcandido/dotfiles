#!/data/data/com.termux/files/usr/bin/bash
# modules/setup-i3.sh — i3 + picom (xrender) + configurações dentro do Arch proot

setup_i3() {
    echo "[i3] Instalando i3 + picom + ferramentas de desktop..."

    run_in_arch "
        pacman -Syu --noconfirm > /dev/null 2>&1

        # WM + bar + notificações
        pacman -S --noconfirm i3-wm i3status i3lock polybar picom dunst rofi alacritty > /dev/null 2>&1

        # Ferramentas de desktop
        pacman -S --noconfirm feh xorg-xrandr xorg-xrdb xorg-setxkbmap xclip maim \
            flameshot network-manager-applet blueman pavucontrol pamixer playerctl \
            copyq polkit polkit-gnome > /dev/null 2>&1

        # Fontes
        pacman -S --noconfirm ttf-nerd-fonts-symbols ttf-font-awesome noto-fonts \
            noto-fonts-emoji ttf-dejavu > /dev/null 2>&1

        # picom precisa de xrender no proot (glx não funciona)
        mkdir -p /etc/xdg/picom
    " 2>/dev/null || echo "[i3] AVISO: Alguns pacotes podem não ter instalado. Verifique."

    # Cria picom config com xrender (proot não tem GLX)
    run_in_arch "cat > /etc/xdg/picom/picom.conf << 'PICOM'
backend = \"xrender\";
corner-radius = 8;
shadow = true;
shadow-radius = 12;
shadow-opacity = 0.4;
fading = true;
fade-in-step = 0.03;
fade-out-step = 0.03;
no-fading-openclose = true;
inactive-opacity = 0.92;
active-opacity = 1.0;
opacity-rule = [
  \"100:class_g = 'polybar'\",
  \"100:class_g = 'rofi'\",
  \"100:class_g = 'dunst'\"
];
PICOM" 2>/dev/null || true

    echo "[i3] i3 + picom (xrender) instalados!"
}
