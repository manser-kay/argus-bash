#!/bin/bash
# XXX v2 — ЗА ГРАНЬЮ РЕАЛЬНОСТИ
# Атаки которые не должны существовать

TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
SERVER_IP=$(dig +short "$DOMAIN" 2>/dev/null | head -1)

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — XXX v2                     ║"
echo "║   То чего не может быть                     ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# XXX-1: КВАНТОВАЯ ЗАПУТАННОСТЬ
echo "[XXX-1] 🌀 Квантовая запутанность..."
# Два запроса которые ведут себя как один
curl -sk --max-time 5 "$TARGET?id=1" -o /tmp/xxx_q1.html 2>/dev/null &
PID1=$!
curl -sk --max-time 5 "$TARGET?id=1' OR '1'='1" -o /tmp/xxx_q2.html 2>/dev/null &
PID2=$!

# Если оба ответили одинаково — квантовая запутанность
wait $PID1 $PID2
if diff /tmp/xxx_q1.html /tmp/xxx_q2.html >/dev/null 2>&1; then
    echo "  🌀 Оба запроса дали одинаковый ответ"
    echo "  🌀 Сервер не различает легитимный запрос и SQLi"
    echo "  🌀 КВАНТОВАЯ ЗАПУТАННОСТЬ ПОДТВЕРЖДЕНА"
fi

# XXX-2: ТЕМПОРАЛЬНАЯ ПЕТЛЯ
echo "[XXX-2] ⏳ Темпоральная петля..."
# Отправляем ответ в прошлое
for i in {1..3}; do
    curl -sk --max-time 5 \
        -H "Date: $(date -d "-$i days" +"%a, %d %b %Y %H:%M:%S GMT" 2>/dev/null || date +"%a, %d %b %Y %H:%M:%S GMT")" \
        -H "If-Modified-Since: $(date -d "+$i days" +"%a, %d %b %Y %H:%M:%S GMT" 2>/dev/null || date +"%a, %d %b %Y %H:%M:%S GMT")" \
        "$TARGET" -o /dev/null -w "  ⏳ Запрос из будущего в прошлое: HTTP %{http_code}\n" 2>/dev/null
done

# XXX-3: ШРЁДИНГЕР-АТАКА
echo "[XXX-3] 🐱 Шрёдингер-атака..."
# Атака одновременно существует и не существует
DEAD=0
ALIVE=0

for i in {1..20}; do
    curl -sk --max-time 3 "$TARGET?q=$(openssl rand -hex 4 2>/dev/null || echo 'test')" -o /dev/null -w "%{http_code}\n" 2>/dev/null | {
        read code
        if [ "$code" = "403" ] || [ "$code" = "500" ]; then
            DEAD=$((DEAD + 1))
        else
            ALIVE=$((ALIVE + 1))
        fi
    }
done

echo "  🐱 Мёртвых запросов: $DEAD"
echo "  🐱 Живых запросов: $ALIVE"
echo "  🐱 Атака одновременно жива и мертва"

# XXX-4: НАБЛЮДАТЕЛЬ
echo "[XXX-4] 👁️ Наблюдатель..."
# Атака которая меняет поведение сервера самим фактом наблюдения

# Первый проход — без наблюдения
BEFORE=$(curl -sk --max-time 5 "$TARGET" 2>/dev/null | wc -c)

# Наблюдаем
for i in {1..10}; do
    curl -sk --max-time 3 "$TARGET" -o /dev/null 2>/dev/null
done

# Второй проход — после наблюдения
AFTER=$(curl -sk --max-time 5 "$TARGET" 2>/dev/null | wc -c)

if [ "$BEFORE" != "$AFTER" ]; then
    echo "  👁️ Сервер изменился от наблюдения"
    echo "  👁️ До: $BEFORE байт → После: $AFTER байт"
    echo "  👁️ ЭФФЕКТ НАБЛЮДАТЕЛЯ ПОДТВЕРЖДЁН"
else
    echo "  👁️ Сервер не реагирует на наблюдение"
fi

# XXX-5: НЕБЫТИЕ
echo "[XXX-5] 🌌 Небытие..."

# Запрос который удаляет сам факт своего существования
curl -sk --max-time 5 \
    -H "X-Exist: false" \
    -H "X-Reality: none" \
    -H "X-Time: never" \
    "$TARGET" -o /tmp/xxx_void.html 2>/dev/null

# Проверяем что запрос был... или не был?
if [ -f /tmp/xxx_void.html ]; then
    SIZE=$(wc -c < /tmp/xxx_void.html)
    if [ "$SIZE" -eq 0 ]; then
        echo "  🌌 Запрос был. Но ответа нет."
        echo "  🌌 Или запроса не было. И ответа нет."
        echo "  🌌 НЕБЫТИЕ ДОСТИГНУТО"
    else
        echo "  🌌 Запрос существует. Но не должен."
        echo "  🌌 Реальность дала сбой."
    fi
    rm -f /tmp/xxx_void.html
fi

echo ""
echo "══════════════════════════════════════════════"
echo "  XXX v2 ЗАВЕРШЁН"
echo ""
echo "  🌀 Квантовая запутанность"
echo "  ⏳ Темпоральная петля"
echo "  🐱 Шрёдингер-атака"
echo "  👁️ Наблюдатель"
echo "  🌌 Небытие"
echo ""
echo "  Это не атаки. Это вопросы к реальности."
echo "══════════════════════════════════════════════"
