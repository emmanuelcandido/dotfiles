#!/usr/bin/env bash
# restore-arch.sh — Restaura/configura Arch Linux do zero
# Uso: bash restore-arch.sh [--full] [--no-pcloud]
# --full: instala pacotes selecionáveis adicionais
# --no-pcloud: pula montagem e restore do pCloud

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

export FULL_MODE=false
export NO_PCLOUD=false

for arg in "$@"; do
    case "$arg" in
        --full) FULL_MODE=true ;;
        --no-pcloud) NO_PCLOUD=true ;;
    esac
done

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  restore-arch.sh — Arch Linux Setup${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Source modules
for module in "${SCRIPT_DIR}/modules/"*.sh; do
    source "$module"
done

# === Módulo 1: Sistema ===
echo -e "${YELLOW}[1/4] Configurando sistema...${NC}"
config_system

# === Módulo 2: Pacotes essenciais ===
echo ""
echo -e "${YELLOW}[2/4] Instalando pacotes...${NC}"
install_packages

# === Módulo 3: pCloud (opcional) ===
if [ "$NO_PCLOUD" = false ]; then
    echo ""
    echo -e "${YELLOW}[3/4] Montando pCloud e restaurando dados...${NC}"
    mount_pcloud && restore_dotfiles || echo -e "${YELLOW}    pCloud pulado (continue manualmente depois)${NC}"
else
    echo ""
    echo -e "${YELLOW}[3/4] pCloud pulado (--no-pcloud)${NC}"
fi

# === Módulo 4: Webapps ===
echo ""
echo -e "${YELLOW}[4/4] Configurando webapps...${NC}"
setup_webapps || echo -e "${YELLOW}    Webapps pulados (Chromium necessário)${NC}"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Restore concluído!${NC}"
echo -e "${GREEN}  Essential packages: ✓${NC}"
echo -e "${GREEN}  Claude Code: $(command -v claude &>/dev/null && echo '✓' || echo 'manual')${NC}"
echo -e "${GREEN}  Próximo passo: configurar i3 (dotfiles)${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
