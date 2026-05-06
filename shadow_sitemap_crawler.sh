#!/bin/bash
TARGET=${1:-"http://testphp.vulnweb.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🗺️ SITEMAP CRAWLER — Атака через sitemap  ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Читаем sitemap.xml — полная карта сайта
echo "[SITEMAP] 🗺️ Читаю sitemap.xml..."
curl -sk --max-time 5 "$TARGET/sitemap.xml" -o /tmp/sitemap_crawl.xml 2>/dev/null

# Вытаскиваем все URL
echo "[SITEMAP] 🔍 Интересные страницы:"
grep -oP 'https?://[^<]+' /tmp/sitemap_crawl.xml 2>/dev/null | grep -iE "admin|login|user|account|dashboard|config|backup|test|dev|api" | head -20 | while read url; do
    echo "  💀 $url"
done

echo "[SITEMAP] ✅ Анализ завершён"
