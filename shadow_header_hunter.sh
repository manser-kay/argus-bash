#!/bin/bash
TARGET=$1
HEADERS=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null)
BODY=$(curl -sk --max-time 10 "$TARGET" 2>/dev/null)

echo "[HEADER-HUNTER] Deep header analysis..."

# Проверка на подмену сервера
SERVER=$(echo "$HEADERS" | grep -i "Server:" | head -1)
if echo "$SERVER" | grep -qi "nginx" && echo "$BODY" | grep -qi "apache"; then
    echo "🔴 DECEPTION: Claims nginx but runs Apache"
elif echo "$SERVER" | grep -qi "Apache" && echo "$BODY" | grep -qi "IIS"; then
    echo "🔴 DECEPTION: Claims Apache but runs IIS"
fi

# Обнаружение внутренних IP в заголовках
echo "$HEADERS" | grep -oP '(?:10\.|172\.(?:1[6-9]|2[0-9]|3[01])\.|192\.168\.)\d+\.\d+' | while read ip; do
    echo "🔴 Internal IP leaked: $ip"
done

# Проверка куки на secure/httpOnly флаги
echo "$HEADERS" | grep -i "Set-Cookie" | while read cookie; do
    echo "$cookie" | grep -q "secure;" || echo "🟡 Cookie without Secure flag"
    echo "$cookie" | grep -q "httponly" || echo "🟡 Cookie without HttpOnly flag"
done

# Определение технологий по заголовкам
echo "$HEADERS" | grep -qi "X-Powered-By: PHP" && echo "PHP detected"
echo "$HEADERS" | grep -qi "X-AspNet-Version" && echo ".NET detected"
echo "$HEADERS" | grep -qi "X-Generator: Drupal" && echo "Drupal detected"

echo "[HEADER-HUNTER] Done"
