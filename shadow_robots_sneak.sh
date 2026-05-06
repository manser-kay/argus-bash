#!/bin/bash
TARGET=${1:-"http://testphp.vulnweb.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🤖 ROBOTS SNEAK — Вход через robots.txt   ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Читаем robots.txt — админы часто прячут там админки
echo "[ROBOTS] 🤖 Читаю robots.txt..."
curl -sk --max-time 5 "$TARGET/robots.txt" -o /tmp/robots_sneak.txt 2>/dev/null

# Вытаскиваем запрещённые пути (самое интересное!)
echo "[ROBOTS] 🔍 Запрещённые пути (Disallow):"
grep -i "Disallow:" /tmp/robots_sneak.txt 2>/dev/null | while read line; do
    path=$(echo "$line" | awk '{print $2}')
    echo "  🚫 $path"

    # Проверяем доступен ли запрещённый путь
    code=$(curl -sk --max-time 3 -o /dev/null -w "%{http_code}" "$TARGET$path" 2>/dev/null)
    [ "$code" = "200" ] && echo "    💀 ДОСТУПЕН! HTTP $code"
    [ "$code" = "403" ] && echo "    🔒 Защищён (HTTP 403)"
done

echo "[ROBOTS] ✅ Анализ завершён"
