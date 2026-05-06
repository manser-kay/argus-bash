#!/bin/bash
# CHAMELEON X — Мимикрия под конкретный сайт
# Анализирует цель и подбирает идеальный профиль

TARGET=$1
[ -z "$TARGET" ] && { echo "Usage: $0 https://target.com"; exit 1; }
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
CHAMX_DIR="$HOME/.shadow_chameleon_x/$DOMAIN"
mkdir -p "$CHAMX_DIR"

echo "╔══════════════════════════════════════════════╗"
echo "║   🦎 CHAMELEON X — Идеальная мимикрия       ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Фаза 1: Анализ цели
echo "[CHAMX] 🔍 Анализирую цель..."
curl -sk --max-time 5 "$TARGET" -o "$CHAMX_DIR/index.html" 2>/dev/null
curl -sk --max-time 5 -I "$TARGET" -o "$CHAMX_DIR/headers.txt" 2>/dev/null

# Определяем технологии
SERVER=$(grep -i "Server:" "$CHAMX_DIR/headers.txt" 2>/dev/null | head -1 | sed 's/.*Server: //i')
TECH=$(grep -oiE 'wordpress|jquery|bootstrap|react|vue|angular|laravel|nginx|apache|cloudflare|aws|google|azure|iis|php|python|node' "$CHAMX_DIR/index.html" 2>/dev/null | sort -u | tr '\n' ' ')

echo "  🖥️ Сервер: ${SERVER:-неизвестен}"
echo "  🛠️ Технологии: ${TECH:-неизвестны}"

# Фаза 2: Подбор идеального профиля
echo ""
echo "[CHAMX] 🦎 Подбираю идеальный профиль маскировки..."

# Профили как в Chameleon Ultimate + новые
declare -A PROFILES
PROFILES["google"]='ua=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/131.0.0.0|accept=text/html|header=X-Client-Data: CI22yQEIo7bJAQjBtskBCKmdygEI+Z3KAQjLncoB'
PROFILES["cloudflare"]='ua=Mozilla/5.0 (compatible; Cloudflare-Traffic-Manager/1.0)|accept=*/*|header=CF-Connecting-IP: 10.0.0.1'
PROFILES["aws"]='ua=Amazon CloudFront|accept=application/json|header=X-Amz-Cf-Id: RANDOM'
PROFILES["azure"]='ua=Azure-Edge/1.0|accept=*/*|header=X-Azure-Ref: RANDOM'
PROFILES["nginx"]='ua=nginx/1.25.0 (health check)|accept=*/*|header=X-Real-IP: 127.0.0.1'
PROFILES["apache"]='ua=Apache/2.4 (internal check)|accept=*/*|header=X-Internal: true'
PROFILES["iis"]='ua=Microsoft-IIS/10.0 HealthCheck|accept=*/*|header=X-IIS-Health: ok'
PROFILES["wordpress"]='ua=WordPress/6.4; https://TARGET|accept=application/json|header=X-WP-Nonce: RANDOM'
PROFILES["php"]='ua=PHP/8.2 (built-in server)|accept=*/*|header=X-PHP-FPM: healthy'

# Выбираем профиль на основе технологий
SELECTED_PROFILE=""
for tech in $TECH; do
    for profile in "${!PROFILES[@]}"; do
        if echo "$tech" | grep -qi "$profile"; then
            SELECTED_PROFILE="${PROFILES[$profile]}"
            echo "  🎯 Выбран профиль: $profile (по технологии $tech)"
            break 2
        fi
    done
done

# Если не нашли — используем гибридный подход
[ -z "$SELECTED_PROFILE" ] && {
    echo "  🎯 Точного совпадения нет — создаю гибридный профиль..."

    # Берём User-Agent похожий на цель
    if echo "$SERVER" | grep -qi "nginx"; then
        UA="Mozilla/5.0 (compatible; nginx-health/1.0)"
    elif echo "$SERVER" | grep -qi "apache"; then
        UA="Mozilla/5.0 (compatible; apache-probe/1.0)"
    elif echo "$SERVER" | grep -qi "iis"; then
        UA="Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1)"
    else
        UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0"
    fi
    SELECTED_PROFILE="ua=$UA|accept=*/*|header=X-Health-Check: true|header=X-Forwarded-For: 127.0.0.1"
}

echo ""
echo "[CHAMX] 🦎 Профиль маскировки готов:"
echo "  ${SELECTED_PROFILE:0:100}..."

# Сохраняем профиль
echo "PROFILE=$SELECTED_PROFILE|TARGET=$TARGET|CREATED=$(date +%s)" > "$CHAMX_DIR/active_profile.txt"

echo ""
echo "[CHAMX] 🦎 Хамелеон X готов к внедрению"
echo "[CHAMX] 📁 $CHAMX_DIR/"
