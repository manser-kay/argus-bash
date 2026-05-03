#!/bin/bash
TARGET=$1
echo "[COOKIE] Security audit..."
curl -sk -I --max-time 10 "$TARGET" 2>/dev/null | grep -i "Set-Cookie" | while read cookie; do
    echo "$cookie" | grep -q "Secure" || echo "❌ Missing Secure flag"
    echo "$cookie" | grep -q "HttpOnly" || echo "❌ Missing HttpOnly flag"
    echo "$cookie" | grep -q "SameSite" || echo "❌ Missing SameSite flag"
done
