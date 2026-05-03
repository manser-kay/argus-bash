# ShadowStrike — Hacker's Swiss Army Knife

**30+ базовых модулей + архив оригинальных версий | Android/Linux/macOS | Бесплатно**

Персональный Red Team фреймворк. Всё что нужно для пентеста в одном месте.

## 🚀 Быстрый старт

git clone https://github.com/manser-kay/shadowstrike
cd shadowstrike
chmod +x shadow.sh
./shadow check
./shadow scan http://testphp.vulnweb.com

## ⚡ Основные команды

./shadow scan <url>         Полный скан
./shadow quick <url>        Быстрый скан (5 минут)
./shadow passive            Пассивный сбор (прокси)
./shadow c2 <port>          C2 сервер
./shadow console            Боевая консоль

## 📁 Состав

**Ядро:**
shadow.sh               Основной фреймворк
shadow_passive.py        Пассивный сканер
shadow_c2_server.py      C2 сервер
shadow_c2_agent.sh       C2 агент

**Утилиты:**
smart_brute.sh           Умный брутфорс
waf_detect.sh            Детектор WAF
quick_loot.sh            Поиск сокровищ
subfinder.sh             Поиск поддоменов
portscan.sh              Скан портов
header_audit.sh          Аудит заголовков
stealer.sh               Аудитор утечек данных

**Архив (archive/):**
Оригинальные v1 модули — Echo, Spider, Jammer, Hydra, Reflective WAF, Psycho

## ⚠️ Ответственность

Автор не несёт ответственности. Ты сам решаешь что делать.

## 📜 Лицензия

MIT
