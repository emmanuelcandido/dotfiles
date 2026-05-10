#!/data/data/com.termux/files/usr/bin/bash
# setup-archroid.sh — Arch Linux via proot-distro + i3 no Android
# Uso: bash setup-archroid.sh
# Baseado no setup-hacklab.sh original (Tech Jarves), reescrito para proot-distro + Arch + i3

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; PURPLE='\033[0;35m'; NC='\033[0m'

# Detect curl pipe execution — BASH_SOURCE points to /proc/self/fd when piped
if [ ! -d "${SCRIPT_DIR}/modules" ]; then
    echo -e "${YELLOW}Detectado execução via curl pipe. Clonando repositório...${NC}"
    TMP_DIR="$(mktemp -d)"
    git clone --depth 1 https://github.com/emmanuelcandido/dotfiles.git "$TMP_DIR" 2>/dev/null || {
        echo -e "${RED}Erro ao clonar repositório. Verifique conexão.${NC}"
        exit 1
    }
    cd "$TMP_DIR/arch-on-android"
    exec bash setup-archroid.sh
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  ArchDroid — Arch Linux + i3 no Android${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Source modules
for module in "${SCRIPT_DIR}/modules/"*.sh; do
    source "$module"
done

# Phase 1: Setup proot-distro + Arch
echo -e "${YELLOW}[1/5] Instalando proot-distro + Arch Linux...${NC}"
setup_proot

# Phase 2: GPU drivers
echo ""
echo -e "${YELLOW}[2/5] Instalando drivers GPU (Turnip/Zink)...${NC}"
setup_turnip

# Phase 3: Audio
echo ""
echo -e "${YELLOW}[3/5] Configurando áudio (PulseAudio)...${NC}"
setup_audio

# Phase 4: i3 + picom
echo ""
echo -e "${YELLOW}[4/5] Instalando i3 + picom + ferramentas...${NC}"
setup_i3

# Phase 5: Tools
echo ""
echo -e "${YELLOW}[5/5] Instalando apps e ferramentas...${NC}"
setup_tools

# Create launcher aliases
echo ""
echo -e "${YELLOW}Criando aliases de sistema...${NC}"
setup_aliases

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ArchDroid instalado!${NC}"
echo -e "${GREEN}  Comandos:${NC}"
echo -e "${GREEN}    start-arch     → Inicia Arch + i3${NC}"
echo -e "${GREEN}    stop-arch      → Para sessão Arch${NC}"
echo -e "${GREEN}    uninstall-arch → Remove Arch completamente${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
