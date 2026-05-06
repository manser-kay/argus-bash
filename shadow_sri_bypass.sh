#!/bin/bash
TARGET=${1:-"http://testphp.vulnweb.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🔓 SRI BYPASS — Обход Subresource Integrity║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Проверяем наличие SRI на сайте
curl -sk --max-time 5 "$TARGET" -o /tmp/sri_site.html 2>/dev/null

echo "[SRI] 🔍 Анализирую SRI..."
grep -oP 'integrity="\K[^"]+' /tmp/sri_site.html 2>/dev/null | while read hash; do
    echo "  🔐 SRI найден: $hash"
done

# Проверяем есть ли скрипты БЕЗ SRI
grep -oP '<script[^>]+src="\K[^"]+' /tmp/sri_site.html 2>/dev/null | while read js; do
    grep -q "integrity" /tmp/sri_site.html 2>/dev/null || echo "  💀 СКРИПТ БЕЗ SRI: $js"
done
echo "[SRI] ✅ Анализ завершён"
