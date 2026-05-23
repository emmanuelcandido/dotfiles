#!/data/data/com.termux/files/usr/bin/bash
# modules/setup-terminal.sh — Terminal: zsh + Starship Nord + URxvt + ferramentas

setup_terminal() {
    local SCRIPT_DIR
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)"

    echo "[terminal] Instalando zsh + Starship + ferramentas TUI..."

    # ── Pacotes ──
    # zsh, rxvt-unicode (URxvt), starship, thefuck, yazi, btop, glow, JetBrains Mono Nerd Font
    # Nota: fzf, zoxide, eza, bat já são instalados pelo setup-tools.sh
    run_in_arch "
        pacman -S --noconfirm --needed \
            zsh rxvt-unicode starship \
            thefuck yazi btop glow \
            ttf-jetbrains-mono-nerd
    " || echo "[terminal] AVISO: Alguns pacotes falharam (verifique repo extra)"

    # ── Zinit (Zsh plugin manager) ──
    echo "[terminal] Instalando Zinit..."
    run_in_arch "
        ZINIT_HOME=\"\${XDG_DATA_HOME:-\${HOME}/.local/share}/zinit/zinit.git\"
        mkdir -p \"\$(dirname \"\$ZINIT_HOME\")\"
        git clone --depth 1 https://github.com/zdharma-continuum/zinit.git \"\$ZINIT_HOME\" 2>/dev/null || {
            echo 'AVISO: Zinit já existe ou git clone falhou'
        }
    " || echo "[terminal] AVISO: Zinit install pulado"

    # ── Configs ──
    echo "[terminal] Copiando dotfiles (.zshrc, starship.toml)..."
    run_in_arch "
        REPO_URL='https://github.com/emmanuelcandido/dotfiles.git'
        TMP_REPO='/tmp/terminal-configs'
        rm -rf \"\$TMP_REPO\" 2>/dev/null

        git clone --depth 1 \"\$REPO_URL\" \"\$TMP_REPO\" 2>/dev/null || {
            echo 'ERRO: Falha ao baixar repositório'
            exit 1
        }

        SRC=\"\$TMP_REPO/arch-on-android/configs\"

        # .zshrc
        cp \"\$SRC/zsh/zshrc\" \"\$HOME/.zshrc\"

        # starship.toml
        mkdir -p \"\$HOME/.config\"
        cp \"\$SRC/starship/starship.toml\" \"\$HOME/.config/starship.toml\"

        # Xresources (URxvt)
        cp \"\$SRC/urxvt/Xresources\" \"\$HOME/.Xresources\"

        rm -rf \"\$TMP_REPO\"
        echo 'Configs de terminal aplicadas!'
    " 2>/dev/null || echo "[terminal] AVISO: Falha ao copiar configs (copie manualmente)"

    # ── Shell padrão ──
    echo "[terminal] Definindo zsh como shell padrão..."
    run_in_arch "chsh -s /usr/bin/zsh" 2>/dev/null || \
        echo "[terminal] AVISO: chsh falhou. Para trocar manualmente: chsh -s /usr/bin/zsh (dentro do proot)"

    echo "[terminal] Terminal configurado! Faça logout e login para usar zsh."
    echo "[terminal] Para testar agora dentro do proot: exec zsh"
}
