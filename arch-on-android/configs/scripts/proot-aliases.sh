#!/usr/bin/bash
# proot-aliases.sh — Aliases da VPS e utilitários para o Arch proot
# Fonte: https://github.com/emmanuelcandido/dotfiles
# Instalação: echo "source ~/.config/scripts/proot-aliases.sh" >> ~/.zshrc

# ── VPS ──
alias vps-shell='ssh root@lifeosdev.duckdns.org'
alias vps-tmux='ssh -t root@lifeosdev.duckdns.org "tmux attach || tmux new"'
alias vps-claude='ssh root@lifeosdev.duckdns.org "cd /opt/infra && source .env.global 2>/dev/null; exec bash"'
alias vps-deploy='ssh root@lifeosdev.duckdns.org "cd /opt/infra && git pull && sudo bash deploy.sh"'
alias vps-logs='ssh root@lifeosdev.duckdns.org "journalctl -f -n 50"'

# ── Utilitários ──
alias arch-update='~/.config/scripts/arch-update.sh'
alias apply-configs='~/.local/bin/apply-configs'
alias stop-arch='~/.local/bin/stop-arch'
