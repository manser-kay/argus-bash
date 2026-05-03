#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 target.com" && exit 1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
IP=$(dig +short "$DOMAIN" 2>/dev/null | head -1)
[ -n "$IP" ] && echo "IP: $IP" && curl -s "https://internetdb.shodan.io/$IP" 2>/dev/null
