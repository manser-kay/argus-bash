#!/bin/bash
TARGET=$1
WORDLIST=${2:-"/data/data/com.termux/files/usr/share/wordlists/subdomains-top1mil.txt"}
[ -z "$TARGET" ] && { echo "Usage: $0 example.com [wordlist]"; exit 1; }
mkdir -p ~/.shadow_subdomains

echo "╔══════════════════════════════════════════════╗"
echo "║   🌐 SUBDOMAIN BRUTEFORCE                   ║"
echo "╚══════════════════════════════════════════════╝"
echo "[SUB] Цель: $TARGET"
echo ""

# Если нет wordlist — качаем
[ ! -f "$WORDLIST" ] && {
    echo "[SUB] Качаю wordlist..."
    curl -sL "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt" -o ~/.shadow_subdomains/wordlist.txt 2>/dev/null
    WORDLIST=~/.shadow_subdomains/wordlist.txt
}

echo "[SUB] 🔍 Перебираю поддомены..."
FOUND=0

while read sub; do
    [ -z "$sub" ] && continue
    result=$(host "$sub.$TARGET" 2>/dev/null)
    if echo "$result" | grep -q "has address\|has IPv6"; then
        ip=$(echo "$result" | grep "has address" | awk '{print $4}' | head -1)
        echo "  ✅ $sub.$TARGET → $ip"
        echo "$sub.$TARGET|$ip" >> ~/.shadow_subdomains/${TARGET}_found.txt
        FOUND=$((FOUND + 1))
    fi
done < "$WORDLIST"

echo ""
echo "[SUB] ✅ Найдено: $FOUND поддоменов"
echo "[SUB] 📁 ~/.shadow_subdomains/${TARGET}_found.txt"
