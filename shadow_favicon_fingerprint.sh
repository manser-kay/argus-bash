#!/bin/bash
TARGET=$1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')

echo "[FAVICON] Снимаю отпечаток..."

HASH=$(curl -sk --max-time 5 "$TARGET/favicon.ico" 2>/dev/null | md5sum | cut -d' ' -f1)

# База известных хешей
case "$HASH" in
    "f420fc2a3c7b8e0b4a9d6c1e5f3a7b2d") echo "  🎯 WordPress" ;;
    "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6") echo "  🎯 Joomla" ;;
    "d41d8cd98f00b204e9800998ecf8427e") echo "  🎯 Пустой favicon (возможно кастомный)" ;;
    *) echo "  🔍 Неизвестный хеш: $HASH" ;;
esac

echo "  📡 Shodan: https://www.shodan.io/search?query=http.favicon.hash:$(python3 -c "import mmh3,base64; print(mmh3.hash(base64.b64encode(base64.b64decode('$(curl -sk --max-time 5 $TARGET/favicon.ico | base64 -w0)'))))" 2>/dev/null || echo $HASH)"
