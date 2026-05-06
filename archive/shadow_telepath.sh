#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

echo "[TELEPATH v2] Читаю конфигурацию WAF..."

# Определяем тип WAF по поведению
HEADERS=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null)
BODY=$(curl -sk --max-time 10 "$TARGET" 2>/dev/null)

# Cloudflare
if echo "$HEADERS" | grep -qi "cf-ray"; then
    echo "  🧠 Cloudflare"
    RAY=$(echo "$HEADERS" | grep -oP 'CF-Ray: \K[^\s]+')
    echo "  Ray: $RAY (дата-центр: ${RAY##*-})"
fi

# AWS CloudFront
if echo "$HEADERS" | grep -qi "x-amz-cf-id"; then
    echo "  🧠 AWS CloudFront"
    echo "  ID: $(echo "$HEADERS" | grep -oP 'X-Amz-Cf-Id: \K[^\s]+')"
fi

# ModSecurity
if echo "$BODY" | grep -qi "ModSecurity\|mod_security"; then
    echo "  🧠 ModSecurity"
    echo "  Версия: $(echo "$BODY" | grep -oP 'ModSecurity v[\d.]+' | head -1)"
fi

# Определяем правила блокировки
echo "[TELEPATH] Тестирую правила..."
for payload in "' OR '1'='1" "<script>" "../../etc/passwd" "{{7*7}}"; do
    code=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET?q=$payload" 2>/dev/null)
    if [ "$code" = "403" ] || [ "$code" = "406" ]; then
        echo "  🚫 Блокирует: $payload (HTTP $code)"
    fi
done

echo "[TELEPATH v2] Чтение завершено"
