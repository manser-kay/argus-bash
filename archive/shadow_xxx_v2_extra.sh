#!/bin/bash
# XXX v2 EXTRA — Дополнительные атаки за гранью

TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — XXX v2 EXTRA               ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# XXX-6: КОТ ШРЁДИНГЕРА В МЕШКЕ
echo "[XXX-6] 🐱📦 Кот Шрёдингера в мешке..."
# Атака которая одновременно взламывает и не взламывает
curl -sk --max-time 5 \
    -H "X-Quantum-State: superposition" \
    -H "X-Pwned: both" \
    -H "X-Not-Pwned: also" \
    "$TARGET" -o /dev/null -w "  🐱 Суперпозиция: HTTP %{http_code} (одновременно 200 и 403)\n" 2>/dev/null

# XXX-7: ОБРАТНАЯ ПРИЧИННОСТЬ
echo "[XXX-7] 🔄 Обратная причинность..."
# Атака где результат предшествует запросу
RESULT_BEFORE=$(curl -sk --max-time 5 "$TARGET" -o /dev/null -w "%{http_code}" 2>/dev/null)
sleep 1
# Отправляем запрос ПОСЛЕ получения результата
curl -sk --max-time 5 "$TARGET?cause=effect" -o /dev/null 2>/dev/null
echo "  🔄 Результат HTTP $RESULT_BEFORE был до запроса"
echo "  🔄 Причина следует за следствием"

# XXX-8: БЕСКОНЕЧНАЯ РЕКУРСИЯ
echo "[XXX-8] ♾️ Бесконечная рекурсия..."
# Запрос который содержит сам себя
SELF_REF="http://$TARGET/?q=http://$TARGET/?q=http://$TARGET/?q=..."
curl -sk --max-time 5 "$SELF_REF" -o /dev/null -w "  ♾️ Рекурсия: HTTP %{http_code}\n" 2>/dev/null

# XXX-9: ПУСТОЙ ЗАПРОС
echo "[XXX-9] ⓪ Пустой запрос..."
# Запрос без метода, без URL, без заголовков
curl -sk --max-time 5 -X "" "$TARGET" -o /dev/null -w "  ⓪ Ничто: HTTP %{http_code}\n" 2>/dev/null

echo ""
echo "══════════════════════════════════════════════"
echo "  XXX v2 EXTRA ЗАВЕРШЁН"
echo "══════════════════════════════════════════════"
