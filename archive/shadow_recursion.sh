#!/bin/bash
# RECURSION — Атака которая атакует саму себя чтобы стать сильнее

TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — RECURSION                  ║"
echo "║   Атака которая усиливает сама себя         ║"
echo "╚══════════════════════════════════════════════╝"

LEVEL=${2:-1}
MAX_LEVEL=5

echo "[RECURSION] Уровень: $LEVEL/$MAX_LEVEL"

# Сканируем цель
RESP=$(curl -sk --max-time 5 "$TARGET" 2>/dev/null)

# Находим новые URL в ответе
NEW_URLS=$(echo "$RESP" | grep -oP '(?:href|src|action)="\K[^"]+' | head -5)

# Находим уязвимости
echo "$RESP" | grep -qi "sql\|error\|syntax" && echo "  💉 SQLi найден!"
echo "$RESP" | grep -qi "<script>alert" && echo "  💉 XSS найден!"

# Если нашли — атакуем сильнее
if [ -n "$NEW_URLS" ] && [ "$LEVEL" -lt "$MAX_LEVEL" ]; then
    echo "[RECURSION] Найдено URL: $(echo "$NEW_URLS" | wc -l)"
    
    for url in $NEW_URLS; do
        [ "${url:0:4}" != "http" ] && url="$TARGET$url"
        echo "  🔄 Рекурсия на: $url"
        
        # Вызываем себя на новом URL с увеличенной глубиной
        bash "$0" "$url" $((LEVEL + 1))
    done
fi

echo "[RECURSION] Уровень $LEVEL завершён"
[ "$LEVEL" -eq 1 ] && echo "[RECURSION] Атака усилила сама себя в $MAX_LEVEL раз"
