#!/data/data/com.termux/files/usr/bin/bash
# modules/setup-i3.sh — i3 + picom (xrender) + configurações dentro do Arch proot

setup_i3() {
    echo "[i3] Instalando i3 + picom + ferramentas de desktop..."
    echo "[i3] Sincronizando pacman..."
    run_in_arch "pacman -Syu --noconfirm" || echo "[i3] AVISO: pacman -Syu falhou"

    echo "[i3] Instalando WM, bar e notificações..."
    run_in_arch "pacman -S --noconfirm i3-wm i3status i3lock polybar picom dunst rofi alacritty" || \
        echo "[i3] AVISO: Alguns pacotes WM falharam"

    echo "[i3] Instalando ferramentas de desktop..."
    run_in_arch "pacman -S --noconfirm feh xorg-xrandr xorg-xrdb xorg-setxkbmap xclip maim \
        flameshot network-manager-applet blueman pavucontrol pamixer playerctl \
        copyq polkit polkit-gnome" || echo "[i3] AVISO: Algumas ferramentas falharam"

    echo "[i3] Instalando fontes..."
    run_in_arch "pacman -S --noconfirm ttf-nerd-fonts-symbols ttf-font-awesome noto-fonts \
        noto-fonts-emoji ttf-dejavu" || echo "[i3] AVISO: Algumas fontes falharam"

    echo "[i3] Configurando picom (xrender)..."
    run_in_arch "mkdir -p /etc/xdg/picom && cat > /etc/xdg/picom/picom.conf << 'PICOM'
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
PICOM" || echo "[i3] AVISO: Config picom falhou"

    echo "[i3] i3 + picom (xrender) instalados!"
}
