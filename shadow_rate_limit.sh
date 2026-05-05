#!/bin/bash
TARGET=$1
ENDPOINT=${2:-"/login"}
REQUESTS=${3:-50}
[ -z "$TARGET" ] && { echo "Usage: $0 https://target.com [/login] [requests]"; exit 1; }
mkdir -p ~/.shadow_ratelimit

echo "╔══════════════════════════════════════════════╗"
echo "║   ⏱️ RATE LIMIT TESTER                      ║"
echo "╚══════════════════════════════════════════════╝"
echo "[RATE] Цель: $TARGET$ENDPOINT"
echo "[RATE] Запросов: $REQUESTS"
echo ""

BLOCKED=0
ALLOWED=0
RATE_LIMITED=0

echo "[RATE] 🚀 Отправляю запросы..."
for i in $(seq 1 $REQUESTS); do
    code=$(curl -sk --max-time 3 -o /dev/null -w "%{http_code}" \
        -H "User-Agent: Mozilla/5.0" \
        -H "X-Forwarded-For: $((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255))" \
        "$TARGET$ENDPOINT?attempt=$i" 2>/dev/null)

    case $code in
        429)
            echo "  🚫 Запрос #$i: HTTP 429 — RATE LIMITED!"
            RATE_LIMITED=$((RATE_LIMITED + 1))
            echo "RATE_LIMIT_AT=$i|HTTP=$code" >> ~/.shadow_ratelimit/$(echo $TARGET | tr '/:' '_')_ratelimit.txt
            ;;
        403)
            echo "  🚫 Запрос #$i: HTTP 403 — ЗАБЛОКИРОВАН!"
            BLOCKED=$((BLOCKED + 1))
            ;;
        000)
            echo "  🔌 Запрос #$i: CONNECTION DROPPED!"
            BLOCKED=$((BLOCKED + 1))
            ;;
        *)
            ALLOWED=$((ALLOWED + 1))
            [ $((i % 10)) -eq 0 ] && echo "  ✅ $i/$REQUESTS запросов (HTTP $code)"
            ;;
    esac

    [ "$RATE_LIMITED" -gt 0 ] || [ "$BLOCKED" -gt 0 ] && {
        echo ""
        echo "[RATE] ⏱️ Защита сработала на запросе #$i"
        break
    }

    sleep 0.2
done

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   📊 РЕЗУЛЬТАТЫ                             ║"
echo "╠══════════════════════════════════════════════╣"
echo "║   ✅ Пропущено:     $ALLOWED"
echo "║   🚫 Rate-limited:  $RATE_LIMITED"
echo "║   🔒 Заблокировано: $BLOCKED"
echo "╠══════════════════════════════════════════════╣"
if [ "$RATE_LIMITED" -gt 0 ]; then
    echo "║   🎯 Rate-limit срабатывает на $RATE_LIMITED запросе"
elif [ "$BLOCKED" -gt 0 ]; then
    echo "║   🎯 WAF блокирует на $BLOCKED запросе"
else
    echo "║   ⚠️ Rate-limit ОТСУТСТВУЕТ!"
fi
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "[RATE] 📁 ~/.shadow_ratelimit/"
