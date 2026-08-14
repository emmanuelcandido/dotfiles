#!/usr/bin/bash
# proot-aliases.sh — Aliases da VPS e utilitários para o Arch proot
# Fonte: https://github.com/emmanuelcandido/dotfiles
# Instalação: echo "source ~/.config/scripts/proot-aliases.sh" >> ~/.zshrc
#
# Nota: Os alias VPS chamam scripts que existem na VPS (lifeosdev.duckdns.org).
#       Script de referência: /opt/infra/infra/scripts/aliases.sh

# ── VPS ──
alias vps-shell='mosh root@lifeosdev.duckdns.org'
alias vps-tmux='mosh root@lifeosdev.duckdns.org -- bash /root/lifeos/infra/scripts/tmux-menu.sh'
alias vps-tmux-kill='mosh root@lifeosdev.duckdns.org -- bash /root/lifeos/infra/scripts/tmux-menu.sh kill'
alias vps-claude='mosh root@lifeosdev.duckdns.org -- bash -c "cd /root/lifeos && IS_SANDBOX=1 claude --dangerously-skip-permissions"'
alias vps-claude-safe='mosh root@lifeosdev.duckdns.org -- bash -c "cd /root/lifeos && claude"'
alias vps-claude-resume='mosh root@lifeosdev.duckdns.org -- bash -c "cd /root/lifeos && IS_SANDBOX=1 claude --dangerously-skip-permissions --resume"'
alias vps-claude-safe-resume='mosh root@lifeosdev.duckdns.org -- bash -c "cd /root/lifeos && claude --resume"'
alias vps-deploy='mosh root@lifeosdev.duckdns.org -- bash -c "cd /opt/infra && git pull && sudo bash deploy.sh"'
alias vps-logs='mosh root@lifeosdev.duckdns.org -- journalctl -f -n 50'
alias ccgram-restart='mosh root@lifeosdev.duckdns.org -- systemctl restart ccgram.service && echo ccgram reiniciado'

# ── Utilitários ──
alias arch-update='~/.config/scripts/arch-update.sh'
alias apply-configs='~/.local/bin/apply-configs'
alias stop-arch='~/.local/bin/stop-arch'
