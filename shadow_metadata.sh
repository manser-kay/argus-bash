#!/bin/bash
# METADATA EXTRACTOR — Извлекает GPS, камеру, автора из файлов
TARGET_DIR=${1:-"$HOME/storage/shared"}
META_DIR="$HOME/.shadow_metadata"
mkdir -p "$META_DIR"/{gps,cameras,documents,emails,passwords}

echo "╔══════════════════════════════════════════════╗"
echo "║   📋 METADATA EXTRACTOR — Извлечение данных ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

echo "[META] 📋 Сканирую $TARGET_DIR..."
echo ""

# Извлекаем GPS из фото
echo "[META] 📸 Извлекаю GPS из фото..."
find "$TARGET_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.heic" \) 2>/dev/null | while read photo; do
    exiftool "$photo" 2>/dev/null | grep -E "GPS|Latitude|Longitude|DateTime" | while read line; do
        echo "  📍 $photo: $line"
        echo "$photo|$line" >> "$META_DIR/gps/photo_locations.txt"
    done
    # Модель камеры
    exiftool "$photo" 2>/dev/null | grep -E "Camera|Model|Make" | while read line; do
        echo "$photo|$line" >> "$META_DIR/cameras/camera_info.txt"
    done
done

echo ""

# Извлекаем авторов из документов
echo "[META] 📄 Извлекаю авторов документов..."
find "$TARGET_DIR" -type f \( -iname "*.pdf" -o -iname "*.docx" -o -iname "*.xlsx" -o -iname "*.pptx" \) 2>/dev/null | while read doc; do
    exiftool "$doc" 2>/dev/null | grep -iE "Author|Creator|Last Modified By|Company" | while read line; do
        echo "  📄 $doc: $line"
        echo "$doc|$line" >> "$META_DIR/documents/authors.txt"
    done
done

echo ""

# Извлекаем email из файлов
echo "[META] 📧 Извлекаю email..."
find "$TARGET_DIR" -type f 2>/dev/null | head -100 | while read file; do
    strings "$file" 2>/dev/null | grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' >> "$META_DIR/emails/all_emails.txt"
done
sort -u "$META_DIR/emails/all_emails.txt" -o "$META_DIR/emails/all_emails.txt" 2>/dev/null
echo "  📊 Найдено email: $(wc -l < $META_DIR/emails/all_emails.txt 2>/dev/null || echo 0)"

echo ""

# Извлекаем пароли из текстовых файлов
echo "[META] 🔑 Ищу пароли..."
find "$TARGET_DIR" -type f \( -iname "*.txt" -o -iname "*.log" -o -iname "*.conf" -o -iname "*.ini" -o -iname "*.cfg" \) 2>/dev/null | head -50 | while read file; do
    grep -oP '(?:password|passwd|pwd|secret)\s*[=:]\s*\K[^\s]+' "$file" 2>/dev/null >> "$META_DIR/passwords/found.txt"
done
sort -u "$META_DIR/passwords/found.txt" -o "$META_DIR/passwords/found.txt" 2>/dev/null
echo "  📊 Найдено паролей: $(wc -l < $META_DIR/passwords/found.txt 2>/dev/null || echo 0)"

echo ""
echo "[META] 📁 $META_DIR/"
