# Argus-Bash v56.0 — Red Team Framework

**87 сигнатур | 229 шаблонов Nuclei | 6 режимов работы | WebSocket C2 | Mimic Implant v2 | Hydra Beacon | Hunter Mode**

Argus прошёл путь от простого bash-скрипта до профессионального Red Team фреймворка за 56 версий.

## Что умеет Argus
- Пассивный сканер — 87 сигнатур + история + авто-детект IDOR
- 12 типов инъекций — SQL, NoSQL, LDAP, XXE, SSTI, CMDi, LFI, SSRF, GraphQL, WebSocket
- Agentic Scanner — 6 режимов: smart, speed, deep, advisor, executor, favorites
- C2 — HTTPS Beacon (O365/Teams), DNS Beacon, WebSocket C2, Mimic Implant, Hydra Beacon
- Уникальные фичи — Predictor, Lie Detector, Mirror Maze, Echo, Whisper, Supply Chain Hunter
- Отчёты — After-Action Report, HTML, PDF, JSON, CSV, XML

## Быстрый старт
git clone https://github.com/manser-kay/argus-bash && cd argus-bash && chmod +x argus.sh argus && ./argus check && ./argus help

## Кто кого: Argus vs Профи

| Возможность | Argus | Burp Pro | Metasploit | Nessus | CobaltStrike | Sliver | ZAP |
|---|---|---|---|---|---|---|---|
| **Пассивный сканер** | ✅ **87** | ✅ 100+ | ❌ | ❌ | ❌ | ❌ | ✅ 40+ |
| **База сигнатур/шаблонов** | 87 + 229 | 100+ | 2000+ эксплойтов | **70,000+** | ❌ | ❌ | 40+ |
| **Repeater/Intruder** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Типы инъекций** | ✅ **12** | 2-3 | 5+ | ❌ | ❌ | ❌ | 3-4 |
| **C2 Beacon** | ✅ **5 каналов** | ❌ | ✅ | ❌ | ✅ | ✅ | ❌ |
| **Agentic AI** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Supply Chain** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Predictor** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Lie Detector** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Mirror Maze** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Echo (WAF timing)** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Whisper (пассив)** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Hacker Report** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Hydra Beacon** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Цена** | **$0** | $449/год | $15K/год | $3K/год | $3.5K/год | $0 | $0 |

## Где мы пока слабы (честно)
- **База эксплойтов**: 229 шаблонов против 70,000 у Nessus
- **C2 скрытность**: уступаем Cobalt Strike в Malleable C2
- **Графический интерфейс**: только терминал (но это и наша фишка)

## Уникальные фичи (нет ни у кого)
Self-learning payloads | Dead Man Switch | Стеганография | Honeypot Detector | P2P CVE Sync | Decoy Generator | Supply Chain Hunter | Mimic Implant | Hydra Beacon | Echo | Whisper | Predictor | Lie Detector | Mirror Maze

## Эксклюзивные возможности
Данный репозиторий содержит базовую версию Argus. Продвинутые хакерские модули доступны только в закрытой версии.

## Ответственность
Инструмент создан для образовательных целей и легального тестирования безопасности.

## Лицензия
MIT
