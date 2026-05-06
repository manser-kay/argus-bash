#!/bin/bash
TARGET=${1:-"testphp.vulnweb.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🔌 WEB SOCKET HIJACK — Перехват WS        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Проверяем есть ли WebSocket на цели
echo "[WS] 🔍 Ищу WebSocket..."
curl -sk --max-time 5 "$TARGET" -o /tmp/ws_site.html 2>/dev/null
grep -oP "wss?://[^\"'\s]+" /tmp/ws_site.html 2>/dev/null | while read ws; do
    echo "  💀 НАЙДЕН WebSocket: $ws"
done

# Проверяем стандартные порты WebSocket
for port in 80 443 8080 8443; do
    timeout 1 bash -c "echo >/dev/tcp/$TARGET/$port" 2>/dev/null && echo "  🔌 Порт $port открыт — WebSocket возможен"
done
echo "[WS] ✅ Анализ завершён"
