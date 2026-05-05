#!/bin/bash
TARGET_IP=$1
TARGET_DOMAIN=$2
[ -z "$TARGET_IP" ] || [ -z "$TARGET_DOMAIN" ] && {
    echo "Usage: $0 <IP> <domain.com>"
    echo "Example: $0 10.10.10.10 example.com"
    exit 1
}
mkdir -p ~/.shadow_vhosts

echo "╔══════════════════════════════════════════════╗"
echo "║   🏠 VIRTUAL HOST BRUTEFORCE                ║"
echo "╚══════════════════════════════════════════════╝"
echo "[VHOST] IP: $TARGET_IP | Домен: $TARGET_DOMAIN"
echo ""

# Wordlist для виртуальных хостов
VHOSTS=(
    "admin" "dev" "test" "staging" "api" "internal" "intranet"
    "mail" "webmail" "portal" "secure" "vpn" "remote" "gateway"
    "db" "mysql" "redis" "elastic" "kibana" "grafana" "jenkins"
    "gitlab" "bitbucket" "wiki" "docs" "status" "monitor" "metrics"
    "backup" "files" "cdn" "static" "assets" "m" "mobile"
    "$TARGET_DOMAIN" "www.$TARGET_DOMAIN"
)

BASELINE=$(curl -sk --max-time 3 "https://$TARGET_IP" -o /dev/null -w "%{size_download}" 2>/dev/null)
echo "[VHOST] Базовый размер ответа: $BASELINE байт"
echo ""

FOUND=0
for vhost in "${VHOSTS[@]}"; do
    size=$(curl -sk --max-time 3 -H "Host: $vhost" "https://$TARGET_IP" -o /dev/null -w "%{size_download}" 2>/dev/null)
    code=$(curl -sk --max-time 3 -H "Host: $vhost" "https://$TARGET_IP" -o /dev/null -w "%{http_code}" 2>/dev/null)

    if [ "$size" != "$BASELINE" ] && [ "$size" != "0" ]; then
        echo "  ✅ $vhost → HTTP $code (${size} байт)"
        echo "$vhost|HTTP$code|${size}bytes" >> ~/.shadow_vhosts/${TARGET_DOMAIN}_vhosts.txt
        FOUND=$((FOUND + 1))
    else
        echo "     $vhost → $size байт (совпадает с базовым)"
    fi
done

echo ""
echo "[VHOST] ✅ Найдено: $FOUND виртуальных хостов"
echo "[VHOST] 📁 ~/.shadow_vhosts/${TARGET_DOMAIN}_vhosts.txt"
