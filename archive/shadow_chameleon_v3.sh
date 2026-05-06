#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://bank.com" && exit 1
echo "[CHAMELEON v3] Starting behavioral mimicry..."
human_pause() { sleep $((1 + RANDOM % 5)); }
for i in 1 2 3; do
    curl -sk --max-time 10 -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/131.0.0.0" -H "Accept-Language: ru-RU,ru;q=0.9" -H "Referer: https://www.google.com/" "$TARGET" -o /tmp/cham_page.html 2>/dev/null
    human_pause
    LINKS=$(grep -oP 'href="\K[^"]*"' /tmp/cham_page.html 2>/dev/null | head -5)
    for link in $LINKS; do
        curl -sk --max-time 10 "$TARGET$link" -o /dev/null 2>/dev/null
        human_pause
    done
    sleep $((30 + RANDOM % 60))
done
echo "[CHAMELEON v3] Done"
