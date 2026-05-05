#!/bin/bash
# BLUETOOTH HUNTER — Сканирует реальные Bluetooth устройства вокруг
BT_DIR="$HOME/.shadow_bluetooth"
mkdir -p "$BT_DIR"

echo "╔══════════════════════════════════════════════╗"
echo "║   📶 BLUETOOTH HUNTER — Сканер устройств    ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Проверяем наличие hcitool
if ! command -v hcitool >/dev/null 2>&1; then
    echo "[BT] Устанавливаю bluez..."
    pkg install bluez -y 2>/dev/null || apt-get install -y bluez 2>/dev/null
fi

echo "[BT] 📶 Сканирую Bluetooth..."
echo ""

# Сканируем устройства
echo "  MAC Address        | Name                    | RSSI"
echo "  -------------------+-------------------------+------"

hcitool scan 2>/dev/null | tail -n +2 | while read line; do
    mac=$(echo "$line" | awk '{print $1}')
    name=$(echo "$line" | cut -d' ' -f2-)

    # Получаем мощность сигнала
    rssi=$(hcitool rssi "$mac" 2>/dev/null || echo "N/A")

    echo "  $mac | ${name:-Unknown} | $rssi"
    echo "$mac|$name|$rssi|$(date +%s)" >> "$BT_DIR/devices.txt"
done

echo ""
echo "[BT] 📶 Повторное сканирование для поиска уязвимых..."
echo ""

# Проверяем известные уязвимости Bluetooth
while read device; do
    mac=$(echo "$device" | cut -d'|' -f1)
    name=$(echo "$device" | cut -d'|' -f2)

    # Проверяем BlueBorne уязвимость
    echo "  🔍 Проверяю $name ($mac)..."

    # Пробуем l2ping для проверки доступности
    l2ping -c 1 "$mac" >/dev/null 2>&1 && echo "    ✅ L2CAP доступен — потенциальная уязвимость" >> "$BT_DIR/vulnerable.txt"

    # Проверяем SDP сервисы
    sdptool browse "$mac" 2>/dev/null | grep -q "OBEX" && echo "    ✅ OBEX доступен — возможна отправка файлов" >> "$BT_DIR/vulnerable.txt"

done < "$BT_DIR/devices.txt" 2>/dev/null

echo ""
echo "[BT] 📁 $BT_DIR/"
echo "[BT] 📶 Сканирование завершено"
