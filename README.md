# Argus-Bash v56.0 — Red Team Framework

**77 сигнатур | 229 шаблонов Nuclei | 6 режимов работы | WebSocket C2 | Mimic Implant | After-Action Report**

Argus — автономный Red Team фреймворк, прошедший путь от bash-скрипта до профессионального инструмента за 56 версий.

## Возможности
- Пассивный сканер — 77 сигнатур + история запросов + авто-детект IDOR
- 12 типов инъекций — SQL, NoSQL, LDAP, XXE, SSTI, CMDi, LFI, SSRF, GraphQL, WebSocket
- Agentic Scanner — 6 режимов: smart, speed, deep, advisor, executor, favorites
- Sentinel AI — понимает ответы сервера и адаптирует атаку
- Malleable C2 — HTTPS Beacon (O365/Teams), DNS Beacon, WebSocket Beacon v2, Mimic Implant v2
- Supply Chain Hunter — атака через разработчиков, хостинг, CDN
- Vault — AES-256 шифрование конфигов + авто-Vault
- After-Action Report — боевой журнал: векторы, хеши, pivot, Metasploit
- Предполётная проверка + Оффлайн-режим + Авто-очистка

## Новое в v56.0
- 🦎 Mimic Implant v2 — проактивная маскировка под окружение
- 📡 WebSocket C2 Server — управление агентами в реальном времени
- 📊 After-Action Report — боевой журнал для пентестера
- 🛡️ 77 сигнатур (+10 CVE 2026)
- 🔧 Предполётная проверка зависимостей
- 📴 Оффлайн-режим для всех модулей
- 🧹 Авто-очистка временных файлов

## Быстрый старт
git clone https://github.com/manser-kay/argus-bash
cd argus-bash
chmod +x argus.sh argus
./argus check
./argus help

## Использование
./argus scan http://target.com
./argus agentic http://target.com --mode speed
./argus passive
./argus c2 8443
./argus_hacker_report.sh ~/argus_scan_*/

## Mimic Implant v2
python3 argus_implant_v2.py https://your-c2-server.com

## After-Action Report
- 💀 Immediate Attack Vectors
- 🔑 Looted Credentials & Hashes
- 🚪 Pivot Points & Lateral Movement
- 🥷 Stealth & Evasion
- ⚔️ Ready-to-Use Metasploit Commands

## Уникальные фичи
Self-learning payloads | Dead Man Switch | Стеганография | Honeypot Detector | P2P CVE Sync | Decoy Generator | Supply Chain Hunter | Mimic Implant

## Сравнение с другими инструментами

| Возможность | Argus-Bash | Burp Suite Pro | Metasploit | Nessus | Cobalt Strike | Sliver | OWASP ZAP |
|------------|------------|---------------|------------|--------|--------------|--------|-----------|
| **Тип** | Универсальный Red Team фреймворк | Ручной тест веб-приложений | Фреймворк эксплуатации | Сканер уязвимостей | C2 для Red Team | Современный C2 | Бесплатный веб-сканер |
| **Пассивный сканер** | ✅ 77 сигнатур | ✅ 100+ | ❌ | ❌ | ❌ | ❌ | ✅ 40+ |
| **Repeater** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Intruder** | ✅ (Agentic) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Типы инъекций** | ✅ 12 типов | 2-3 | 5+ | ❌ | ❌ | ❌ | 3-4 |
| **C2 Beacon** | ✅ HTTPS+WS+DNS | ❌ | ✅ Meterpreter | ❌ | ✅ Malleable | ✅ Multi-protocol | ❌ |
| **Malleable C2** | 🦎 Mimic (адаптивный) | ❌ | ❌ | ❌ | ✅ Полный | ✅ Гибкий | ❌ |
| **Agentic AI** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Supply Chain** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **After-Action Report** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Post-exploit** | ✅ SSH/WinRM | ❌ | ✅ Полный | ❌ | ✅ Продвинутый | ✅ | ❌ |
| **База сигнатур** | 77 | 100+ | 2000+ эксплойтов | 70,000+ | ❌ | ❌ | 40+ |
| **Отчёты** | ✅ HTML/PDF/JSON/CSV/XML | 2-3 формата | 1 формат | 4 формата | 1 формат | ❌ | 2-3 формата |
| **Платформа** | Android/Linux/macOS | Windows/Linux/macOS | Windows/Linux | Windows/Linux | Windows/Linux | Linux/macOS | Windows/Linux/macOS |
| **Цена** | **$0** | $449/год | $0/$15K | $3K/год | $3.5K/год | $0 | $0 |

## Сильные стороны каждого

**Burp Suite Pro** — лучший в ручном тестировании веб-приложений. Незаменим для deep-dive анализа HTTP/HTTPS трафика. Его главная сила — Repeater и Intruder с графическим интерфейсом.

**Metasploit** — король эксплуатации. 2000+ готовых эксплойтов, Meterpreter с полным контролем над системой, post-exploitation модули. Лучший выбор для фазы "взлома".

**Nessus** — рекордсмен по базе сигнатур (70,000+). Идеален для compliance-скан��рования (PCI DSS, HIPAA). Находит уязвимости которые пропускают все остальные.

**Cobalt Strike** — золотой стандарт C2 для Red Team. Malleable C2 позволяет полностью имитировать любой легитимный трафик. BeaconGate обходит самые продвинутые EDR.

**Sliver** — современный Open Source C2. Мультипротокольная связь с агентами на Go. Лучшая архитектура среди бесплатных C2.

**OWASP ZAP** — лучший бесплатный веб-сканер. Хороший выбор для начинающих и для CI/CD пайплайнов.

**Argus-Bash** — единственный инструмент "всё в одном". Закрывает полный цикл Red Team операции: от разведки до финального отчёта. Содержит 8 уникальных фич которых нет больше ни у кого.

## Ответственность
Инструмент создан для образовательных целей и легального тестирования безопасности. Используйте только на собственных системах или с разрешения владельца.

## Лицензия
MIT
