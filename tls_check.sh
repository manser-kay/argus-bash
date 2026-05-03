#!/bin/bash
TARGET=$1
echo "[TLS] Checking ciphers for $(echo $TARGET | sed 's|https\?://||;s|/.*||')..."
nmap --script ssl-enum-ciphers -p 443 "$(echo $TARGET | sed 's|https\?://||;s|/.*||')" 2>/dev/null | grep -E "weak|broken|anonymous|null"
