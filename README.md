# dotfiles — Multi-OS Restore & Config

Restore seus dotfiles, instalar pacotes e configurar TWM em 3 sistemas com UM comando.

```bash
# Arch Linux (i3 + polybar + picom)
bash <(curl -s https://raw.githubusercontent.com/emmanuelcandido/dotfiles/main/arch-dot-files/restore-arch.sh)

# Android/Termux (proot-distro + Arch + i3)
bash <(curl -s https://raw.githubusercontent.com/emmanuelcandido/dotfiles/main/arch-on-android/setup-archroid.sh)

# Windows (winget + Komorebi)
powershell -c "iex (curl -s https://raw.githubusercontent.com/emmanuelcandido/dotfiles/main/windows-dot-files/restore-windows.ps1)"
```

| Sistema | TWM | Bar | Pacotes |
|---------|-----|-----|---------|
| **Arch Linux** | i3 (QWER keybindings) | Polybar | pacman + pikaur (AUR) |
| **Android** | i3 via proot-distro | Polybar | pacman (proot) |
| **Windows** | Komorebi + GlazeWM | Zebar | winget |

Flags: `--full` / `--no-pcloud` (Arch), `-Full` / `-NoPcloud` (Windows).

Filosofia: Git > pCloud. Nord colorscheme universal. QWER portável entre OS.
