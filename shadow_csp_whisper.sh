#!/bin/bash
TARGET=${1:-"http://testphp.vulnweb.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🔒 CSP WHISPER — Обход CSP                ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Проверяем CSP заголовки
CSP=$(curl -sk --max-time 5 -I "$TARGET" 2>/dev/null | grep -i "Content-Security-Policy" | head -1)

echo "[CSP] 🔍 Анализирую CSP..."
if [ -n "$CSP" ]; then
    echo "  📋 Политика: $CSP"

    # Проверяем слабые места в CSP
    echo "$CSP" | grep -q "unsafe-inline" && echo "  💀 'unsafe-inline' разрешён — XSS работает!"
    echo "$CSP" | grep -q "unsafe-eval" && echo "  💀 'unsafe-eval' разрешён — eval() работает!"
    echo "$CSP" | grep -q "data:" && echo "  💀 data: разрешён — инъекция через data: URI!"
    echo "$CSP" | grep -q "\*" && echo "  💀 Звёздочка (*) найдена — слишком широкая политика!"
else
    echo "  💀 CSP ОТСУТСТВУЕТ! Полная свобода для XSS."
fi
echo "[CSP] ✅ Анализ завершён"
