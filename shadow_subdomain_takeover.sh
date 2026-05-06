#!/bin/bash
# ╔══════════════════════════════════════════════╗
# ║   🟡 SUBDOMAIN TAKEOVER — Автозахват        ║
# ╚══════════════════════════════════════════════╝
TARGET=${1:-"example.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🌐 SUBDOMAIN TAKEOVER — Автозахват        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

SUBDOMAINS=("dev" "test" "staging" "old" "backup" "admin" "api2" "beta" "demo" "portal")
for sub in "${SUBDOMAINS[@]}"; do
    host "$sub.$TARGET" 2>/dev/null | grep -q "has address" && {
        ip=$(host "$sub.$TARGET" 2>/dev/null | grep "has address" | awk '{print $4}' | head -1)
        echo "  💀 $sub.$TARGET → $ip"
        curl -sk --max-time 3 "http://$sub.$TARGET" -o /dev/null -w "    HTTP %{http_code}\n" 2>/dev/null
    }
done
echo "[TAKEOVER] ✅ Проверка завершена"
