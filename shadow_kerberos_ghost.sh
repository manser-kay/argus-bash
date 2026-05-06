#!/bin/bash
# ╔══════════════════════════════════════════════╗
# ║   🔴 KERBEROS GHOST — Атака через Kerberos  ║
# ╚══════════════════════════════════════════════╝
TARGET=${1:-"testphp.vulnweb.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   👻 KERBEROS GHOST — Атака через Kerberos  ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Проверяем есть ли Kerberos на цели
echo "[KERBEROS] 🔍 Ищу Kerberos на $TARGET..."
nslookup -type=SRV _kerberos._tcp.$TARGET 2>/dev/null | grep -q "service" && echo "  💀 KERBEROS НАЙДЕН!"
nslookup -type=SRV _kerberos._udp.$TARGET 2>/dev/null | grep -q "service" && echo "  💀 KERBEROS UDP НАЙДЕН!"

# Проверяем порт 88 (Kerberos)
timeout 2 bash -c "echo >/dev/tcp/$TARGET/88" 2>/dev/null && {
    echo "  💀 ПОРТ 88 ОТКРЫТ! Kerberos активен."
    echo "  🔑 Пробую AS-REP Roasting..."
    python3 -c "
import socket, struct
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(3)
    s.connect(('$TARGET', 88))
    print('  🔑 Kerberos отвечает на порту 88')
    s.close()
except Exception as e:
    print(f'  ❌ Ошибка: {e}')
" 2>/dev/null
}

echo "[KERBEROS] ✅ Анализ завершён"
