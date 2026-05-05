#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && { echo "Usage: $0 https://target.com/page"; exit 1; }
mkdir -p ~/.shadow_params

echo "╔══════════════════════════════════════════════╗"
echo "║   🔍 PARAMETER DISCOVERY (Arjun-style)      ║"
echo "╚══════════════════════════════════════════════╝"
echo "[PARAM] Цель: $TARGET"
echo ""

# Список параметров для перебора
PARAMS=(
    "id" "page" "file" "path" "url" "redirect" "next" "return"
    "user" "username" "email" "password" "pass" "passwd" "key"
    "token" "api_key" "apikey" "secret" "auth" "session" "sid"
    "query" "search" "q" "s" "find" "sort" "order" "dir"
    "type" "format" "lang" "locale" "theme" "style" "view"
    "action" "do" "cmd" "exec" "command" "run" "func" "method"
    "debug" "test" "dev" "admin" "root" "config" "setup"
    "callback" "jsonp" "jsoncallback" "xml" "rss" "feed"
    "limit" "offset" "page" "per_page" "count" "max" "min"
    "from" "to" "start" "end" "date" "time" "timestamp"
)

BASELINE=$(curl -sk --max-time 3 "$TARGET" -o /dev/null -w "%{size_download}" 2>/dev/null)
echo "[PARAM] Базовый размер: $BASELINE байт"
echo ""

FOUND=0
for param in "${PARAMS[@]}"; do
    size=$(curl -sk --max-time 3 "$TARGET?$param=test123" -o /dev/null -w "%{size_download}" 2>/dev/null)
    diff=$((size - BASELINE))
    [ ${diff#-} -gt 50 ] && {
        echo "  ✅ $param — реагирует! (разница: ${diff} байт)"
        echo "$param|diff=${diff}bytes" >> ~/.shadow_params/$(echo $TARGET | tr '/:' '_')_params.txt
        FOUND=$((FOUND + 1))
    }
done

echo ""
echo "[PARAM] ✅ Найдено: $FOUND параметров"
echo "[PARAM] 📁 ~/.shadow_params/"
