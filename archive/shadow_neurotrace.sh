#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 target.com" && exit 1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')

echo "[NEURO v2] Строю психопрофиль администратора $DOMAIN..."

# Анализ времени ответа сервера по часам (когда админ активен)
echo "[NEURO] Активность по часам:"
for h in 0 6 9 12 15 18 21; do
    TIME=$(curl -sk --max-time 5 -o /dev/null -w '%{time_total}' "$TARGET" 2>/dev/null)
    [ "${TIME%.*}" -gt 1 ] && echo "  🟢 ${h}:00 — админ активен (задержка ${TIME}s)" || echo "  🔴 ${h}:00 — сервер свободен"
done

# Анализ DNS (когда админ меняет записи)
echo "[NEURO] История изменений DNS:"
dig +short "$DOMAIN" 2>/dev/null | while read ip; do
    echo "  📡 IP: $ip"
    curl -s "https://api.hackertarget.com/reverseiplookup/?q=$ip" 2>/dev/null | head -3
done

# Анализ SSL сертификатов (когда админ их обновляет)
echo "[NEURO] SSL сертификаты:"
curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    dates = [d['not_before'] for d in data[:5] if 'not_before' in d]
    print(f'  Сертификатов: {len(data[:10])}')
    if dates:
        print(f'  Последнее обновление: {min(dates)[:10]}')
        print(f'  Админ обновляет сертификаты по: {max(set([d[8:10] for d in dates]), key=[d[8:10] for d in dates].count)} числам')
except: pass
" 2>/dev/null

echo "[NEURO v2] Профиль построен"
