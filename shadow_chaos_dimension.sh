#!/bin/bash
# CHAOS DIMENSION — Измерение чистого хаоса
# Здесь нет правил. Только энтропия.

CHAOS_DIR="$HOME/.shadow_chaos"
mkdir -p "$CHAOS_DIR/entropy" "$CHAOS_DIR/mutations" "$CHAOS_DIR/unpredictable"

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — CHAOS DIMENSION            ║"
echo "║   Чистый хаос. Никаких правил.              ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ===== ФУНКЦИИ ХАОСА =====

# Генератор случайной атаки
chaos_attack() {
    local target=$1
    
    # Случайный метод
    local methods=("GET" "POST" "PUT" "DELETE" "PATCH" "OPTIONS" "HEAD" "TRACE")
    local method="${methods[$((RANDOM % ${#methods[@]}))]}"
    
    # Случайный пейлоад из шума
    local payload=$(head -c $((RANDOM % 500 + 100)) /dev/urandom | base64 -w0 2>/dev/null | head -c $((RANDOM % 200 + 50)))
    
    # Случайный User-Agent
    local ua="ChaosAgent/$RANDOM.$(date +%s)"
    
    # Случайные заголовки
    local random_header="X-Chaos-$(openssl rand -hex 4 2>/dev/null || echo $RANDOM): $(openssl rand -hex 8 2>/dev/null || echo $RANDOM)"
    
    # Случайный путь
    local paths=("/" "/admin" "/login" "/api" "/search" "/data" "/config" "/backup")
    local path="${paths[$((RANDOM % ${#paths[@]}))]}"
    
    # Отправляем
    curl -sk --max-time 3 -X "$method" \
        -H "User-Agent: $ua" \
        -H "$random_header" \
        -d "$payload" \
        "$target$path?chaos=$RANDOM" \
        -o /dev/null 2>/dev/null &
    
    echo "[CHAOS] 🌪️ $method $path (случайный хаос)"
}

# Мутация живого агента
mutate_agent() {
    local agent=$1
    
    local mutations=(
        "double_speed:скорость ×2"
        "half_speed:скорость ÷2"
        "invisible:полная невидимость на 60 секунд"
        "berserk:атакует всё подряд 30 секунд"
        "sleep:засыпает на 120 секунд"
        "clone:создаёт копию себя"
        "reverse:атакует свои же сервера"
        "quantum:существует в двух местах одновременно"
    )
    
    local mutation="${mutations[$((RANDOM % ${#mutations[@]}))]}"
    local mut_name="${mutation%%:*}"
    local mut_effect="${mutation##*:}"
    
    echo "AGENT=$agent|MUTATION=$mut_name|EFFECT=$mut_effect|TIME=$(date +%s)" >> "$CHAOS_DIR/mutations/history.txt"
    
    echo "[CHAOS] 🧬 $agent мутировал: $mut_name ($mut_effect)"
}

# Энтропия — случайное событие
entropy_event() {
    local event_id=$RANDOM
    
    local events=(
        "WAF_CRASH:защита упала на 30 секунд"
        "MASS_SPAWN:создано 50 новых агентов"
        "BLACKOUT:все логи очищены"
        "TIME_WARP:время ускорилось ×10"
        "MIRROR_MODE:все агенты стали невидимыми"
        "RAGE_MODE:все агенты атакуют одновременно"
        "SILENCE:полная тишина на 60 секунд"
        "RECURSION:агенты атакуют сами себя"
    )
    
    local event="${events[$((RANDOM % ${#events[@]}))]}"
    local event_name="${event%%:*}"
    local event_effect="${event##*:}"
    
    echo "EVENT=$event_name|EFFECT=$event_effect|ID=$event_id|TIME=$(date +%s)" >> "$CHAOS_DIR/entropy/events.txt"
    
    echo "[CHAOS] ⚡ СОБЫТИЕ ХАОСА: $event_name — $event_effect"
}

# ===== ЗАПУСК ХАОСА =====
echo "[CHAOS] 🌪️ Запускаю генератор хаоса..."
echo ""

# 10 случайных атак
for i in $(seq 1 10); do
    chaos_attack "http://chaos-target.local"
    sleep 0.2
done

echo ""

# 5 случайных мутаций
mutate_agent "agent_1"
mutate_agent "agent_2"
mutate_agent "agent_3"
mutate_agent "agent_4"
mutate_agent "agent_5"

echo ""

# 3 случайных события
entropy_event
entropy_event
entropy_event

echo ""
echo "[CHAOS] 📊 Статистика хаоса:"
echo "  🌪️ Случайных атак: $(find "$CHAOS_DIR/entropy" -name "*.txt" 2>/dev/null | wc -l)"
echo "  🧬 Мутаций: $(wc -l < "$CHAOS_DIR/mutations/history.txt" 2>/dev/null || echo 0)"
echo "  ⚡ Событий: $(wc -l < "$CHAOS_DIR/entropy/events.txt" 2>/dev/null || echo 0)"

echo ""
echo "══════════════════════════════════════════════"
echo "  [CHAOS] ХАОС АКТИВЕН"
echo ""
echo "  🌪️ Случайные атаки"
echo "  🧬 Непредсказуемые мутации"
echo "  ⚡ События которые никто не контролирует"
echo ""
echo "  В хаосе нет правил."
echo "  В хаосе всё возможно."
echo "  Хаос — это свобода."
echo "══════════════════════════════════════════════"
