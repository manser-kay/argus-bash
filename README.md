# Argus-Bash v56.0 — Red Team Framework

**67 сигнатур | 229 шаблонов Nuclei | 6 режимов работы | WebSocket C2 | After-Action Report**

Argus — автономный Red Team фреймворк, прошедший путь от bash-скрипта до профессионального инструмента за 56 версий.

## Возможности
- Пассивный сканер — 67 сигнатур + история запросов + авто-детект IDOR
- 12 типов инъекций — SQL, NoSQL, LDAP, XXE, SSTI, CMDi, LFI, SSRF, GraphQL, WebSocket
- Agentic Scanner — 6 режимов: smart, speed, deep, advisor, executor, favorites
- Sentinel AI — понимает ответы сервера и адаптирует атаку
- Malleable C2 — HTTPS Beacon (O365/Teams), DNS Beacon, WebSocket Beacon v2
- Supply Chain Hunter — атака через разработчиков, хостинг, CDN
- Vault — AES-256 шифрование конфигов + авто-Vault
- After-Action Report — боевой журнал: векторы, хеши, pivot, Metasploit
- Предполётная проверка + Оффлайн-режим + Авто-очистка

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

## After-Action Report
- 💀 Immediate Attack Vectors
- 🔑 Looted Credentials & Hashes
- 🚪 Pivot Points & Lateral Movement
- 🥷 Stealth & Evasion
- ⚔️ Ready-to-Use Metasploit Commands

## Уникальные фичи
Self-learning payloads | Dead Man Switch | Стеганография | Honeypot Detector | P2P CVE Sync | Decoy Generator | Supply Chain Hunter

## Сравнение
|                    | Argus-Bash | Burp Suite Pro | Metasploit | Nessus    |
|--------------------|------------|----------------|------------|-----------|
| Пассивный сканер   | 67 сигнатур| 100+           | ❌         | ❌        |
| Repeater + Intruder| ✅         | ✅             | ❌         | ❌        |
| C2 Beacon          | HTTPS + WS | ❌             | ✅         | ❌        |
| Agentic AI         | ✅         | ❌             | ❌         | ❌        |
| Supply Chain       | ✅         | ❌             | ❌         | ❌        |
| After-Action Report| ✅         | ❌             | ❌         | ❌        |
| Цена               | $0         | $449/год       | $15K       | $3K/год   |

## Ответственность
Данный инструмент предназначен исключительно для тестирования собственных систем
или для работы с письменного разрешения владельца тестируемого ресурса.

Атака на сайты без разрешения владельца преследуется по закону (ст. 272, 273, 274 УК РФ —
неправомерный доступ к компьютерной информации, создание и распространение
вредоносных программ, нарушение правил эксплуатации средств хранения данных).

Мы снимаем с себя ответственность за ваши действия. Вы сами решаете,
как использовать этот инструмент, и сами несёте ответственность
за его применение.

## Лицензия
MIT
