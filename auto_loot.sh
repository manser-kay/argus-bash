#!/bin/bash
# Auto-loot: сбор паролей/ключей/токенов после успешной атаки
LOOT_DIR="$HOME/argus_loot/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$LOOT_DIR"

echo "[LOOT] Starting auto-collection..."

# Сбор из найденных файлов
for f in ~/argus_scan_*/hacked/*; do
    [ -f "$f" ] && cp "$f" "$LOOT_DIR/" 2>/dev/null
done

# Поиск паролей в логах
grep -rE "password|passwd|pwd|secret|token|api_key|key" ~/argus_scan_*/ 2>/dev/null > "$LOOT_DIR/credentials.txt"

# Поиск email
grep -rE "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" ~/argus_scan_*/ 2>/dev/null > "$LOOT_DIR/emails.txt"

# Поиск IP:порт
grep -rE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]{2,5}" ~/argus_scan_*/ 2>/dev/null > "$LOOT_DIR/ip_ports.txt"

# Поиск хешей
grep -rE "[a-f0-9]{32}|[a-f0-9]{40}|[a-f0-9]{64}" ~/argus_scan_*/ 2>/dev/null | grep -vi "nmap\|nuclei" > "$LOOT_DIR/hashes.txt"

echo "[LOOT] Done! Files: $(ls "$LOOT_DIR" | wc -l) saved to $LOOT_DIR"
