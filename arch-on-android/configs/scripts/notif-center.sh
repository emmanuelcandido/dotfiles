#!/usr/bin/bash
# notif-center.sh — Rofi notification center for dunst
notif_data=$(dunstctl history 2>/dev/null)

if [ -z "$notif_data" ] || [ "$notif_data" = "[]" ]; then
    rofi -e "Nenhuma notificação" 2>/dev/null
    exit 0
fi

lines=$(echo "$notif_data" | python3 -c "
import sys, json
data = json.load(sys.stdin)
notifs = data if isinstance(data, list) else data.get('notifications', data.get('data', []))
for n in reversed(notifs):
    summary = (n.get('summary', '') or '').strip()
    body = (n.get('body', '') or '').strip().replace('\n', ' ')
    app = (n.get('appname', '') or '').strip()
    if summary:
        line = f'{summary}' + (f': {body[:80]}' if body else '')
        print(f'[{app}] {line}' if app else line)
" 2>/dev/null)

if [ -z "$lines" ]; then
    rofi -e "Nenhuma notificação" 2>/dev/null
    exit 0
fi

selected=$(echo "$lines" | rofi -dmenu -p "Notificações" -i -no-custom 2>/dev/null)

if [ -n "$selected" ]; then
    dunstctl history-pop 2>/dev/null
fi
exit 0
