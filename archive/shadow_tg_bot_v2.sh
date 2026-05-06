#!/bin/bash
# Удалённое управление через Telegram бота

BOT_TOKEN="${TELEGRAM_BOT_TOKEN}"
CHAT_ID="${TELEGRAM_CHAT_ID}"
LAST_MSG=0

echo "[TG-BOT v2] Started"

while true; do
    # Проверяем новые сообщения
    UPDATES=$(curl -sk "https://api.telegram.org/bot$BOT_TOKEN/getUpdates?offset=$((LAST_MSG+1))" 2>/dev/null)
    
    MSG=$(echo "$UPDATES" | python3 -c "
import sys, json
try:
    msgs = json.load(sys.stdin)['result']
    if msgs:
        m = msgs[-1]
        print(f\"{m['update_id']}|{m['message']['chat']['id']}|{m['message'].get('text','')}\")
except: pass
" 2>/dev/null)
    
    if [ -n "$MSG" ]; then
        NEW_ID=$(echo "$MSG" | cut -d'|' -f1)
        FROM=$(echo "$MSG" | cut -d'|' -f2)
        CMD=$(echo "$MSG" | cut -d'|' -f3-)
        
        LAST_MSG=$NEW_ID
        
        case "$CMD" in
            /scan*)
                TARGET=$(echo "$CMD" | cut -d' ' -f2)
                curl -sk "https://api.telegram.org/bot$BOT_TOKEN/sendMessage?chat_id=$FROM&text=Scanning $TARGET..." 2>/dev/null
                ~/shadow.sh "$TARGET" &
                ;;
            /status)
                curl -sk "https://api.telegram.org/bot$BOT_TOKEN/sendMessage?chat_id=$FROM&text=$(pgrep -f shadow.sh >/dev/null && echo 'Running' || echo 'Idle')" 2>/dev/null
                ;;
        esac
    fi
    
    sleep 2
done
