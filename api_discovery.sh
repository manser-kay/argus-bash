#!/bin/bash
TARGET=$1
echo "[API] Searching for hidden endpoints..."
curl -sk --max-time 10 "$TARGET" 2>/dev/null | grep -oP '(?:src|href)="\K[^"]+\.js' | while read js; do
    curl -sk --max-time 5 "$TARGET/$js" 2>/dev/null | grep -oP '(?:get|post|put|delete|patch)\s*\(\s*["\x27]\K[^"\x27]+' | head -5
done
