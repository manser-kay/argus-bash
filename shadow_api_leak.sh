#!/bin/bash
TARGET=${1:-"example.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🔑 API LEAK DETECTOR — Утекшие ключи      ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

echo "[API] 🔍 Ищу утекшие API ключи на $TARGET..."

# Качаем JS файлы
curl -sk --max-time 5 "$TARGET" -o /tmp/api_scan.html 2>/dev/null
grep -oP 'src="\K[^"]+\.js[^"]*' /tmp/api_scan.html 2>/dev/null | while read js; do
    curl -sk --max-time 3 "$js" -o /tmp/api_js_file.js 2>/dev/null

    # Ищем API ключи
    grep -oP '(?:api_key|apikey|API_KEY|token|secret|password)["\s:=]+["\x27]?\K[a-zA-Z0-9._-]{16,}' /tmp/api_js_file.js 2>/dev/null | while read key; do
        echo "  💀 НАЙДЕН КЛЮЧ: $key"
    done
done

echo "[API] ✅ Поиск завершён"
