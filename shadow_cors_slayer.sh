#!/bin/bash
# ╔══════════════════════════════════════════════╗
# ║   🟡 CORS SLAYER — Убийца CORS-защиты       ║
# ╚══════════════════════════════════════════════╝
TARGET=${1:-"https://target.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🔓 CORS SLAYER — Убийца CORS-защиты       ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

ORIGINS=("https://evil.com" "null" "https://attacker.com" "http://localhost" "https://$TARGET.evil.com")
for origin in "${ORIGINS[@]}"; do
    response=$(curl -sk --max-time 5 -H "Origin: $origin" -I "$TARGET" 2>/dev/null)
    acao=$(echo "$response" | grep -i "Access-Control-Allow-Origin" | head -1)
    acac=$(echo "$response" | grep -i "Access-Control-Allow-Credentials" | head -1)
    [ -n "$acao" ] && echo "  💀 $origin → $acao" && [ -n "$acac" ] && echo "    🔴 КРЕДЫ ДОСТУПНЫ! $acac"
done
echo "[CORS] ✅ Проверка завершена"
