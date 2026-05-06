#!/bin/bash
# PORTSCAN PRO — Nmap на стероидах

TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 target.com" && exit 1
HOST=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — PORTSCAN PRO               ║"
echo "╚══════════════════════════════════════════════╝"

# Модуль 1: Быстрый скан топ-10
echo "[1/6] Быстрый скан..."
nmap -T5 --top-ports 10 "$HOST" 2>/dev/null | grep "open"

# Модуль 2: Полный скан портов
echo "[2/6] Полный скан..."
nmap -T4 -p- "$HOST" 2>/dev/null | grep "open" | head -20

# Модуль 3: Скан сервисов
echo "[3/6] Версии сервисов..."
nmap -sV --top-ports 20 "$HOST" 2>/dev/null | grep "open"

# Модуль 4: Скрипты NSE
echo "[4/6] NSE скрипты..."
nmap -sC --top-ports 10 "$HOST" 2>/dev/null | head -30

# Модуль 5: UDP скан
echo "[5/6] UDP скан..."
nmap -sU --top-ports 10 "$HOST" 2>/dev/null | grep "open"

# Модуль 6: OS Detection
echo "[6/6] Определение ОС..."
nmap -O "$HOST" 2>/dev/null | grep -E "Running:|OS:"
