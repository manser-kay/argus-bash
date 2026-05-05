#!/bin/bash
TARGET_DOMAIN=$1
[ -z "$TARGET_DOMAIN" ] && { echo "Usage: $0 example.com"; exit 1; }
WAY_DIR="$HOME/.shadow_wayback/$TARGET_DOMAIN"
mkdir -p "$WAY_DIR"

echo "╔══════════════════════════════════════════════╗"
echo "║   📚 WAYBACK MACHINE EXTRACTOR              ║"
echo "╚══════════════════════════════════════════════╝"
echo "[WAYBACK] Извлекаю историю $TARGET_DOMAIN..."

# Получаем список всех сохранённых URL
curl -sk "http://web.archive.org/cdx/search/cdx?url=*.${TARGET_DOMAIN}/*&output=text&fl=original&collapse=urlkey&limit=500" 2>/dev/null | sort -u > "$WAY_DIR/all_urls.txt"

echo "  📊 Найдено URL: $(wc -l < $WAY_DIR/all_urls.txt 2>/dev/null || echo 0)"

# Ищем интересное
echo ""
echo "  🔍 Ищу уязвимые старые endpoint'ы..."

grep -E '\.php\?|\.asp\?|\.aspx\?|\.jsp\?|/api/|/admin|\.env|\.git|backup|dev|test|staging|old' "$WAY_DIR/all_urls.txt" 2>/dev/null | head -50 > "$WAY_DIR/interesting.txt"

echo "  📊 Интересных endpoint'ов: $(wc -l < $WAY_DIR/interesting.txt 2>/dev/null || echo 0)"
echo ""
echo "  Первые 20:"
head -20 "$WAY_DIR/interesting.txt" 2>/dev/null | while read url; do echo "    $url"; done

echo ""
echo "[WAYBACK] 📁 $WAY_DIR/"
