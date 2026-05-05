#!/bin/bash
TARGET_DOMAIN=$1
[ -z "$TARGET_DOMAIN" ] && { echo "Usage: $0 example.com"; exit 1; }

echo "╔══════════════════════════════════════════════╗"
echo "║   🔍 GOOGLE DORKS OBLITERATOR               ║"
echo "╚══════════════════════════════════════════════╝"

DORKS=(
    "site:$TARGET_DOMAIN filetype:pdf"
    "site:$TARGET_DOMAIN filetype:xlsx OR filetype:xls"
    "site:$TARGET_DOMAIN filetype:sql"
    "site:$TARGET_DOMAIN filetype:env"
    "site:$TARGET_DOMAIN filetype:log"
    "site:$TARGET_DOMAIN inurl:phpinfo"
    "site:$TARGET_DOMAIN inurl:admin"
    "site:$TARGET_DOMAIN inurl:backup"
    "site:$TARGET_DOMAIN intitle:index.of"
    "site:$TARGET_DOMAIN intext:password"
    "site:$TARGET_DOMAIN intext:DB_PASSWORD"
    "site:$TARGET_DOMAIN intext:api_key"
    "site:github.com $TARGET_DOMAIN password"
    "site:pastebin.com $TARGET_DOMAIN"
)

echo "[DORKS] 🔍 Готовые дорки для $TARGET_DOMAIN:"
echo ""
for dork in "${DORKS[@]}"; do
    encoded=$(echo "$dork" | sed 's/ /%20/g;s/:/%3A/g;s/"/%22/g')
    echo "  https://www.google.com/search?q=$encoded"
done

echo ""
echo "[DORKS] 🔍 Открой ссылки в браузере и смотри что найдётся"
