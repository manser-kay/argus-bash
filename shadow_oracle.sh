#!/bin/bash
# Цифровой оракул — предсказание уязвимостей по стилю разработчика
TARGET=$1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
[ -z "$TARGET" ] && echo "Usage: $0 target.com" && exit 1

echo "[ORACLE] Анализирую стиль разработчика $DOMAIN..."

# Собираем цифровые отпечатки
HEADERS=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null)
BODY=$(curl -sk --max-time 10 "$TARGET" 2>/dev/null)

# Паттерны небезопасного кода
SCORE=0

# 1. Старые заголовки
echo "$HEADERS" | grep -qi "Apache/2\.[0-2]" && SCORE=$((SCORE + 30)) && echo "  🔴 Старый Apache — вероятны RCE"
echo "$HEADERS" | grep -qi "PHP/5\." && SCORE=$((SCORE + 40)) && echo "  🔴 PHP 5 — EOL, множественные уязвимости"
echo "$HEADERS" | grep -qi "IIS/6\|IIS/7" && SCORE=$((SCORE + 25)) && echo "  🟡 Старый IIS — вероятны уязвимости"

# 2. Отсутствие заголовков безопасности
echo "$HEADERS" | grep -qi "X-Frame-Options" || SCORE=$((SCORE + 10))
echo "$HEADERS" | grep -qi "Content-Security-Policy" || SCORE=$((SCORE + 10))
echo "$HEADERS" | grep -qi "X-Content-Type-Options" || SCORE=$((SCORE + 5))

# 3. Признаки уязвимых компонентов
echo "$BODY" | grep -qi "jquery.*1\.[0-9]" && SCORE=$((SCORE + 20)) && echo "  🟡 Старый jQuery — XSS риски"
echo "$BODY" | grep -qi "wordpress.*[4-5]\.[0-9]" && SCORE=$((SCORE + 30)) && echo "  🔴 Старый WordPress"

# 4. Предсказание
echo "[ORACLE] Score: $SCORE/100"
if [ "$SCORE" -ge 60 ]; then
    echo "[ORACLE] 🔮 ПРЕДСКАЗАНИЕ: Высокая вероятность критических уязвимостей"
    echo "[ORACLE] Рекомендация: глубокое сканирование с фокусом на RCE и LFI"
elif [ "$SCORE" -ge 30 ]; then
    echo "[ORACLE] 🔮 ПРЕДСКАЗАНИЕ: Средняя вероятность — проверь заголовки и CMS"
else
    echo "[ORACLE] 🔮 ПРЕДСКАЗАНИЕ: Низкая вероятность — точечные проверки"
fi
