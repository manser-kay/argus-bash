#!/bin/bash
TARGET=${1:-"http://testphp.vulnweb.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🟡 ETAG THIEF — Кража через ETag          ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Техника: ETag может раскрывать внутреннюю структуру сервера
# Отслеживаем изменение ETag при разных запросах
ETAGS=()
for i in $(seq 1 10); do
    etag=$(curl -sk --max-time 3 -I "$TARGET" 2>/dev/null | grep -i "ETag:" | head -1)
    [ -n "$etag" ] && echo "  📊 Запрос #$i: $etag" && ETAGS+=("$etag")
    sleep 0.5
done

# Анализируем уникальные ETag'и
UNIQUE_ETAGS=$(printf '%s\n' "${ETAGS[@]}" | sort -u | wc -l)
echo "  📊 Уникальных ETag'ов: $UNIQUE_ETAGS"
[ "$UNIQUE_ETAGS" -gt 3 ] && echo "  💀 ETag МЕНЯЕТСЯ! Сервер раскрывает внутреннюю структуру."
echo "[ETAG THIEF] ✅ Анализ завершён"
