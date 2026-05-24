#!/usr/bin/bash
# earlyoom-proot.sh — Watchdog de memória para proot Android
# Mata processos grandes antes do OOM killer do Android matar o proot inteiro
# Uso: earlyoom-proot.sh [threshold_mb]
# Default: 400MB — dispara quando MemAvailable fica abaixo disso
#
# Instalação automática via setup-aliases.sh (start-arch já inicia)
# Teste manual: bash ~/.config/scripts/earlyoom-proot.sh

THRESHOLD="${1:-400}"
INTERVAL=5

# Processos que nunca devem ser mortos (X11, WM, som, MCP, shell)
WHITELIST_RE="Xorg|Xvfb|Xephyr|i3$|polybar|dunst|pulseaudio|pulse$|pipewire"
WHITELIST_RE="${WHITELIST_RE}|python.*mcp|python.*arch"
WHITELIST_RE="${WHITELIST_RE}|ssh|sshd"
WHITELIST_RE="${WHITELIST_RE}|bash$|zsh$|fish$"
WHITELIST_RE="${WHITELIST_RE}|dbus|dbus-daemon"
WHITELIST_RE="${WHITELIST_RE}|earlyoom|sleep$"

echo "[earlyoom] Watchdog iniciado (threshold: ${THRESHOLD}MB, intervalo: ${INTERVAL}s)"

while true; do
    FREE=$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo 2>/dev/null)

    if [ -n "$FREE" ] && [ "$FREE" -lt "$THRESHOLD" ]; then
        # Varre processos ordenados por RSS (maior primeiro)
        ps aux --sort=-%rss 2>/dev/null | tail -n +2 | head -20 | while read line; do
            RSS=$(echo "$line" | awk '{print $6}' 2>/dev/null)   # RSS em KB
            PID=$(echo "$line" | awk '{print $2}' 2>/dev/null)
            NAME=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}' 2>/dev/null)

            [ -z "$RSS" ] || [ -z "$PID" ] && continue
            [ "$RSS" -lt 102400 ] && continue                   # <100MB, ignora
            echo "$NAME" | grep -qE "$WHITELIST_RE" && continue # whitelist, ignora

            echo "[earlyoom] Mata PID $PID ($(echo "$NAME" | head -c 60)) — RSS: $((RSS/1024))MB, MemAvailable: ${FREE}MB"
            kill -9 "$PID" 2>/dev/null
            break  # mata um por ciclo
        done
    fi

    # Emergência: memória crítica (<200MB), ação mais agressiva
    if [ -n "$FREE" ] && [ "$FREE" -lt 200 ]; then
        ps aux --sort=-%rss 2>/dev/null | tail -n +2 | head -5 | while read line; do
            RSS=$(echo "$line" | awk '{print $6}' 2>/dev/null)
            PID=$(echo "$line" | awk '{print $2}' 2>/dev/null)
            NAME=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}' 2>/dev/null)
            [ -z "$RSS" ] || [ -z "$PID" ] && continue
            [ "$RSS" -lt 51200 ] && continue                    # >50MB
            echo "$NAME" | grep -qE "$WHITELIST_RE" && continue
            echo "[earlyoom] CRÍTICO: Mata $PID ($(echo "$NAME" | head -c 60)) — RSS: $((RSS/1024))MB"
            kill -9 "$PID" 2>/dev/null
        done
    fi

    sleep "$INTERVAL"
done
