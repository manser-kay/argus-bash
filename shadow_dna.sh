#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 target.com" && exit 1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')

echo "[DNA v2] Анализирую цифровой ДНК $DOMAIN..."

# Собираем уникальные отпечатки
IP=$(dig +short "$DOMAIN" 2>/dev/null | head -1)
HEADERS=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null)
SERVER=$(echo "$HEADERS" | grep -i "Server:" | head -1)
COOKIES=$(curl -sk --max-time 10 "$TARGET" -c - -o /dev/null 2>/dev/null | awk '{print $6}' | sort -u)

echo "[DNA] IP: $IP"
echo "[DNA] Server: $SERVER"
echo "[DNA] Cookies: $COOKIES"

# Ищем родственников
echo "[DNA] Родственные сервера на том же IP:"
[ -n "$IP" ] && curl -s "https://api.hackertarget.com/reverseiplookup/?q=$IP" 2>/dev/null | head -5

# Ищем по уникальному заголовку
echo "[DNA] Сервера с таким же Server:"
echo "$SERVER" | grep -oP 'Server: \K.+' | xargs -I{} curl -s "https://www.shodan.io/search?q=Server:{}" 2>/dev/null | grep -oP 'hostnames:[^"]+' | head -3

echo "[DNA v2] Анализ завершён"
