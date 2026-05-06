#!/bin/bash
# ╔══════════════════════════════════════════════╗
# ║   🔴 GRAPHQL RIPPER — Потрошитель GraphQL   ║
# ╚══════════════════════════════════════════════╝
TARGET=${1:-"https://target.com/graphql"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🔭 GRAPHQL RIPPER — Интроспекция          ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

INTROSPECTION_QUERY='{"query":"{ __schema { types { name fields { name type { name kind } } } } }"}'
curl -sk --max-time 5 -X POST -H "Content-Type: application/json" -d "$INTROSPECTION_QUERY" "$TARGET" -o /tmp/graphql_schema.json 2>/dev/null

if grep -q "__schema" /tmp/graphql_schema.json 2>/dev/null; then
    echo "  💀 ИНТРОСПЕКЦИЯ ВКЛЮЧЕНА!"
    grep -oP '"name":"\K[^"]+' /tmp/graphql_schema.json 2>/dev/null | head -30
else
    echo "  ✅ Интроспекция выключена. Пробую обход..."
    curl -sk --max-time 5 -X POST -H "Content-Type: application/json" -d '{"query":"{ __type(name: \"User\") { name fields { name } } }"}' "$TARGET" 2>/dev/null | grep -q "name" && echo "  💀 Обход через __type СРАБОТАЛ!"
fi
echo "[GRAPHQL] ✅ Анализ завершён"
