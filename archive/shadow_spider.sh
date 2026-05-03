#!/bin/bash
# Spider v3.0 — авто-картограф сети с туннелированием
SPIDER_DIR="$HOME/.shadow_spider"
mkdir -p "$SPIDER_DIR"

echo "[SPIDER v3] Строю карту сети и ищу пути обхода..."

# 1. Обнаружение всех интерфейсов и подсетей
ip a 2>/dev/null | grep -oP 'inet \K[\d.]+/\d+' | while read cidr; do
    ip="${cidr%/*}"; mask="${cidr#*/}"
    subnet=$(echo "$ip" | cut -d. -f1-3)
    echo "[SPIDER] Интерфейс: $cidr → $subnet.0/24"
    
    # 2. Сканируем подсеть
    for i in {1..254}; do
        target="$subnet.$i"
        (ping -c1 -W1 "$target" >/dev/null 2>&1 && echo "🟢 $target" >> "$SPIDER_DIR/hosts.txt") &
    done
    wait
done

# 3. Поиск двойных туннелей (пути обхода изоляции)
echo "[SPIDER v3] Ищу двойные туннели..."
for host in $(cat "$SPIDER_DIR/hosts.txt" 2>/dev/null | grep -oP '[\d.]+'); do
    # Проверяем SSH туннель
    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 -N -L 9999:localhost:22 "$host" 2>/dev/null &
    sleep 1
    timeout 2 bash -c "echo >/dev/tcp/127.0.0.1/9999" 2>/dev/null && echo "🔗 Туннель: $host:22 → localhost:9999" >> "$SPIDER_DIR/tunnels.txt"
    kill %1 2>/dev/null
done

echo "[SPIDER v3] ✅ Карта: $(wc -l < "$SPIDER_DIR/hosts.txt") хостов, $(wc -l < "$SPIDER_DIR/tunnels.txt") туннелей"
