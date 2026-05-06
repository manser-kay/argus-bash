#!/bin/bash
TARGET=${1:-"testphp.vulnweb.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🌐 DNS REBINDING — Атака через DNS        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Проверяем разрешение DNS с коротким TTL
echo "[DNS] 🔍 Проверяю DNS записи..."
dig +short "$TARGET" 2>/dev/null | while read ip; do
    echo "  🌐 $TARGET → $ip"
done

# Проверяем TTL
TTL=$(dig +ttlid "$TARGET" 2>/dev/null | grep -oP 'TTL: \K[0-9]+' | head -1)
[ -n "$TTL" ] && echo "  ⏱️ TTL: ${TTL}с" && [ "$TTL" -lt 60 ] && echo "  💀 КОРОТКИЙ TTL! DNS Rebinding возможен."

# Пробуем разрешить internal IP
for internal in "127.0.0.1" "10.0.0.1" "192.168.1.1"; do
    curl -sk --max-time 3 -H "Host: $TARGET" "http://$internal" -o /dev/null -w "  🔍 $internal: HTTP %{http_code}\n" 2>/dev/null
done
echo "[DNS] ✅ Анализ завершён"
