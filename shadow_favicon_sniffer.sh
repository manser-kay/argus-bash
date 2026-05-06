#!/bin/bash
TARGET=${1:-"http://testphp.vulnweb.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🟣 FAVICON SNIFFER — Кража через favicon  ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Скачиваем favicon
curl -sk --max-time 5 "$TARGET/favicon.ico" -o /tmp/favicon_test.ico 2>/dev/null

# Анализируем favicon на наличие скрытых данных
SIZE=$(wc -c < /tmp/favicon_test.ico 2>/dev/null | tr -d ' ')
echo "  📐 Размер favicon: $SIZE байт"

# Некоторые серверы возвращают HTML вместо 404 в favicon
grep -qi "<html\|<?php\|error\|admin" /tmp/favicon_test.ico 2>/dev/null && echo "  💀 FAVICON СОДЕРЖИТ КОД!"

# Проверяем favicon через Shodan
HASH=$(sha256sum /tmp/favicon_test.ico 2>/dev/null | cut -d' ' -f1)
[ -n "$HASH" ] && echo "  🔍 Shodan: https://www.shodan.io/search?query=http.favicon.hash:$HASH"
echo "[FAVICON] ✅ Анализ завершён"
