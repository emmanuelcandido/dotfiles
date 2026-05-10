#!/data/data/com.termux/files/usr/bin/bash
# setup-archroid.sh — Arch Linux via proot-distro + i3 no Android
# Uso: bash setup-archroid.sh
# Baseado no setup-hacklab.sh original (Tech Jarves), reescrito para proot-distro + Arch + i3

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; PURPLE='\033[0;35m'; NC='\033[0m'
PROGRESS_FILE="${HOME}/.archroid-progress"

# ── Checkpoint helpers ──
phase_done() {
    grep -qx "phase_$1" "$PROGRESS_FILE" 2>/dev/null
}
mark_done() {
    echo "phase_$1" >> "$PROGRESS_FILE"
}
clear_progress() {
    rm -f "$PROGRESS_FILE"
}
TOTAL_PHASES=6
run_phase() {
    local num="$1" label="$2"; shift 2
    if phase_done "$num"; then
        echo -e "${GREEN}[${num}/${TOTAL_PHASES}] ${label}... ✓ (já concluído)${NC}"
        return 0
    fi
    echo -e "${YELLOW}[${num}/${TOTAL_PHASES}] ${label}...${NC}"
    if "$@"; then
        mark_done "$num"
        echo -e "${GREEN}  ✓${NC}"
    else
        echo -e "${RED}  ✗ FALHOU — corrija o erro e execute novamente${NC}"
        echo -e "${YELLOW}  O script vai retomar do passo ${num} na próxima vez.${NC}"
        exit 1
    fi
}

# ── Pipe detection (curl bash <(curl ...)) ──
if [ ! -d "${SCRIPT_DIR}/modules" ]; then
    echo -e "${YELLOW}Detectado execução via curl pipe. Clonando repositório...${NC}"
    TMP_DIR="$(mktemp -d)"
    git clone --depth 1 https://github.com/emmanuelcandido/dotfiles.git "$TMP_DIR" || {
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

# ── Run phases ──
run_phase 1 "Instalando proot-distro + Arch Linux" setup_proot
run_phase 2 "Instalando drivers GPU (Turnip/Zink)"   setup_turnip
run_phase 3 "Configurando áudio (PulseAudio)"        setup_audio
run_phase 4 "Instalando i3 + picom + ferramentas"    setup_i3
run_phase 5 "Instalando apps e ferramentas"          setup_tools

# ── Phase 6: Configs ──
run_phase 6 "Aplicando configs (i3, polybar, dunst, rofi)" setup_configs

# ── Aliases (sempre roda, sem checkpoint) ──
echo ""
echo -e "${YELLOW}Criando aliases de sistema...${NC}"
setup_aliases

# ── Limpa progresso — concluído ──
clear_progress

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ArchDroid instalado!${NC}"
echo -e "${GREEN}  Comandos:${NC}"
echo -e "${GREEN}    start-arch     → Inicia Arch + i3${NC}"
echo -e "${GREEN}    stop-arch      → Para sessão Arch${NC}"
echo -e "${GREEN}    uninstall-arch → Remove Arch completamente${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
