#!/bin/bash
TARGET=${1:-"http://testphp.vulnweb.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🍪 COOKIE JAR HEIST — Кража через куки    ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Проверяем куки на незащищённые флаги
HEADERS=$(curl -sk --max-time 5 -I "$TARGET" 2>/dev/null)
echo "$HEADERS" | grep -i "Set-Cookie" | while read cookie; do
    echo "  🍪 $cookie"

    # Проверяем HttpOnly
    echo "$cookie" | grep -qi "HttpOnly" || echo "    ⚠️ HttpOnly ОТСУТСТВУЕТ — куки доступны для JavaScript!"

    # Проверяем Secure
    echo "$cookie" | grep -qi "Secure" || echo "    ⚠️ Secure ОТСУТСТВУЕТ — куки передаются по HTTP!"

    # Проверяем SameSite
    echo "$cookie" | grep -qi "SameSite" || echo "    ⚠️ SameSite ОТСУТСТВУЕТ — уязвимость к CSRF!"
done
echo "[COOKIE] ✅ Анализ завершён"
