#!/bin/bash
# PREDICTOR v2 — Предсказывает уязвимости до их появления
TARGET=$1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
[ -z "$TARGET" ] && echo "Usage: $0 target.com" && exit 1

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — PREDICTOR v2               ║"
echo "║   Я знаю где БУДУТ уязвимости               ║"
echo "╚══════════════════════════════════════════════╝"

# 1. Анализ технологий
echo "[PREDICT] Анализ стека..."
HTML=$(curl -sk --max-time 10 "$TARGET" 2>/dev/null)
HEADERS=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null)

TECHS=""
echo "$HTML" | grep -qi "wp-content" && TECHS="$TECHS WordPress"
echo "$HTML" | grep -qi "jquery" && TECHS="$TECHS jQuery"
echo "$HEADERS" | grep -qi "PHP" && TECHS="$TECHS PHP"
echo "$HEADERS" | grep -qi "Apache" && TECHS="$TECHS Apache"
echo "$HEADERS" | grep -qi "Tomcat" && TECHS="$TECHS Tomcat"

echo "  Стек:$TECHS"

# 2. Предсказание уязвимостей
echo "[PREDICT] 🔮 ПРЕДСКАЗАНИЯ:"

for tech in $TECHS; do
    case "$tech" in
        WordPress)
            echo "  • WordPress → проверь XML-RPC (скорее всего открыт)"
            echo "  • WordPress → проверь wp-json/wp/v2/users (утечка пользователей)"
            echo "  • WordPress → проверь плагины (90% дыр в плагинах)"
            ;;
        jQuery)
            echo "  • jQuery → проверь версию (старые версии XSS)"
            ;;
        PHP)
            echo "  • PHP → проверь phpinfo.php (скорее всего доступен)"
            echo "  • PHP → проверь CVE-2024-4577 (CGI RCE)"
            ;;
        Apache)
            echo "  • Apache → проверь .htaccess (может быть открыт)"
            echo "  • Apache → проверь server-status (может быть доступен)"
            ;;
        Tomcat)
            echo "  • Tomcat → проверь manager/html (дефолтные пароли)"
            echo "  • Tomcat → проверь CVE-2017-12617 (JSP upload)"
            ;;
    esac
done

# 3. Исторический анализ
echo "[PREDICT] Анализ истории..."
SNAP=$(curl -s "http://web.archive.org/cdx/search/cdx?url=$DOMAIN&output=text&fl=timestamp&collapse=digest&limit=1" 2>/dev/null | tail -1 | cut -c1-8)
if [ -n "$SNAP" ]; then
    DAYS=$(( ($(date +%s) - $(date -d "$SNAP" +%s 2>/dev/null || echo 0)) / 86400 ))
    echo "  Последнее изменение: $SNAP ($DAYS дней назад)"
    [ "$DAYS" -gt 365 ] && echo "  🔴 Сайт заброшен — ВСЕ известные CVE применимы"
    [ "$DAYS" -gt 180 ] && echo "  🟡 Сайт редко обновляется"
fi

echo "[PREDICT] Предсказания готовы — проверяй!"
