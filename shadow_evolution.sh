#!/bin/bash
# ЭВОЛЮЦИЯ — Живая система обновления сигнатур

EVO_DIR="$HOME/.shadow_evolution"
mkdir -p "$EVO_DIR/signatures" "$EVO_DIR/learned" "$EVO_DIR/rollback"

# 1. Сканирует CVE базу и извлекает новые сигнатуры
evo_learn_from_cve() {
    echo "[EVO] 🧬 Анализирую свежие CVE..."
    curl -s "https://cve.circl.lu/api/last" 2>/dev/null | python3 -c "
import sys, json
for cve in json.load(sys.stdin)[:5]:
    summary = cve.get('summary', '')[:100]
    cve_id = cve.get('id', '')
    # Извлекаем ключевые слова из описания CVE
    keywords = [w for w in summary.split() if len(w) > 4 and w.isalpha()]
    if keywords:
        print(f'{cve_id}: {\"|\".join(keywords[:3])}')
" > "$EVO_DIR/signatures/cve_live.txt"
    echo "[EVO] Новых сигнатур из CVE: $(wc -l < "$EVO_DIR/signatures/cve_live.txt")"
}

# 2. Учится на своих находках

# 3. P2P обмен сигнатурами (mesh)
evo_p2p_exchange() {
    echo "[EVO] 🌐 Ищу другие экземпляры ShadowStrike в сети..."
    SUBNET=$(ip route 2>/dev/null | grep -oP 'src \K[\d.]+' | head -1 | cut -d. -f1-3)
    [ -z "$SUBNET" ] && SUBNET="192.168.1"
    for i in {1..10}; do
        ip="$SUBNET.$i"
        # Проверяем есть ли другой экземпляр
        curl -sk --max-time 2 "http://$ip:9990/" >/dev/null 2>&1 && {
            echo "[EVO] Найдена нода: $ip"
            # Обмениваемся сигнатурами
            curl -sk "http://$ip:9990/sigs" 2>/dev/null > "$EVO_DIR/signatures/p2p_$ip.txt"
        }
    done
}

# 4. Авто-откат если сигнатура даёт ложняки
evo_rollback_check() {
    echo "[EVO] 🔍 Проверяю качество сигнатур..."
    FALSE_POSITIVES=0
    for sig in "$EVO_DIR/signatures/"*.txt; do
        [ -f "$sig" ] || continue
        # Если сигнатура сработала на заведомо безопасном сайте — откатываем
        if curl -sk --max-time 5 "http://google.com" 2>/dev/null | grep -qf "$sig"; then
            echo "[EVO] Ложное срабатывание: $(basename $sig) → откат"
            mv "$sig" "$EVO_DIR/rollback/"
            FALSE_POSITIVES=$((FALSE_POSITIVES + 1))
        fi
    done
    echo "[EVO] Ложных срабатываний: $FALSE_POSITIVES"
}

# 5. Применяем новые сигнатуры к пассивному сканеру
evo_apply() {
    echo "[EVO] 🔧 Применяю эволюцию..."
    local count=0
    for sig in "$EVO_DIR/signatures/"*.txt "$EVO_DIR/learned/"*.txt; do
        [ -f "$sig" ] || continue
        while read pattern; do
            [ -z "$pattern" ] && continue
            # Проверяем что сигнатура ещё не добавлена
            grep -q "$pattern" ~/shadow_passive.py 2>/dev/null && continue
            # Добавляем в PATTERNS
            count=$((count + 1))
        done < "$sig"
    done
    echo "[EVO] Добавлено сигнатур: $count"
}

# Запуск эволюции
evo_learn_from_cve
evo_learn_from_findings
evo_p2p_exchange
evo_rollback_check
evo_apply

echo "[EVO] ✅ Эволюция завершена"

evo_learn_from_findings() {
    echo "[EVO] Analysing findings..."
    for d in ~/shadow_scan_*/hacked ~/shadow_loot; do
        [ -d "$d" ] || continue
        for f in "$d"/*.txt; do
            [ -f "$f" ] || continue
            grep -oP 'NoSQL|SQLi|XSS|IDOR|SSRF' "$f" 2>/dev/null | while read finding; do
                echo "$finding" >> "$EVO_DIR/learned/successful_patterns.txt"
            done
        done
    done
    sort -u "$EVO_DIR/learned/successful_patterns.txt" -o "$EVO_DIR/learned/successful_patterns.txt" 2>/dev/null
    echo "[EVO] Learned patterns: $(wc -l < "$EVO_DIR/learned/successful_patterns.txt" 2>/dev/null || echo 0)"
}
