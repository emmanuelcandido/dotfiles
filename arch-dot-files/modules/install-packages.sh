#!/usr/bin/env bash
# install-packages.sh — Instala pacotes via pacman + pikaur (AUR)
# Essential: sempre instalado. Full: essential + curadoria.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"
ESSENTIAL_LIST="${PROJECT_DIR}/packages/essential.txt"

install_packages() {
    echo "[packages] Atualizando sistema..."
    sudo pacman -Syu --noconfirm

    if [ ! -f "${ESSENTIAL_LIST}" ]; then
        echo "[packages] ERRO: ${ESSENTIAL_LIST} não encontrado"
        return 1
    fi

    echo "[packages] Instalando pacotes essenciais..."
    # Filtra comentários e linhas vazias
    local essential_pkgs=()
    while IFS= read -r line; do
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        essential_pkgs+=("$line")
    done < "${ESSENTIAL_LIST}"

    # Instala via pacman primeiro
    sudo pacman -S --needed --noconfirm "${essential_pkgs[@]}" 2>/dev/null || {
        echo "[packages] Alguns pacotes podem ser AUR. Instalando via pikaur..."
        pikaur -S --needed --noconfirm "${essential_pkgs[@]}" 2>/dev/null || {
            echo "[packages] AVISO: Alguns pacotes podem não ter sido encontrados. Verifique manualmente."
        }
    }

    # Claude Code
    if ! command -v claude &>/dev/null; then
        echo "[packages] Instalando Claude Code..."
        npm install -g @anthropic-ai/claude-code 2>/dev/null || {
            echo "[packages] Claude Code: instale manualmente: npm install -g @anthropic-ai/claude-code"
        }
    fi

    # Selecionáveis — pergunta pelos apps grandes
    echo ""
    echo "[packages] Deseja instalar apps adicionais selecionáveis?"
    echo "    (responda com os números separados por espaço, ou 0 para pular)"
    echo ""
    echo "    1) GIMP (edição de imagens)"
    echo "    2) GIMP + Inkscape (edição vetorial)"
    echo "    3) QEMU + virt-manager (VMs)"
    echo "    4) LibreOffice (suite office)"
    echo "    5) Steam + games"
    echo "    6) Docker + docker-compose"
    echo "    7) Calibre (gerenciamento de eBooks)"
    echo "    8) OBS Studio (gravação/stream)"
    echo "    9) Kdenlive (edição de vídeo)"
    echo "    10) TODOS os acima"
    echo "    0) Nenhum, só essential"
    echo ""

    read -rp "    Escolha (ex: 1 3 5): " selections
    for sel in $selections; do
        case $sel in
            1) sudo pacman -S --needed --noconfirm gimp ;;
            2) sudo pacman -S --needed --noconfirm gimp inkscape ;;
            3) sudo pacman -S --needed --noconfirm qemu-desktop virt-manager ;;
            4) sudo pacman -S --needed --noconfirm libreoffice-still ;;
            5) sudo pacman -S --needed --noconfirm steam ;;
            6) sudo pacman -S --needed --noconfirm docker docker-compose ;;
            7) sudo pacman -S --needed --noconfirm calibre ;;
            8) sudo pacman -S --needed --noconfirm obs-studio ;;
            9) sudo pacman -S --needed --noconfirm kdenlive ;;
            10)
                sudo pacman -S --needed --noconfirm gimp inkscape qemu-desktop virt-manager libreoffice-still steam docker docker-compose calibre obs-studio kdenlive
                break ;;
        esac
    done

    echo "[packages] Instalação concluída!"
    echo "    Essential: $(wc -l < "${ESSENTIAL_LIST}") pacotes"
    echo "    Claude Code: $(command -v claude &>/dev/null && echo 'instalado' || echo 'não instalado')"
}
