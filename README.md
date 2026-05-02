# Argus-Bash v56.0 — Red Team Framework

**67 сигнатур | 229 шаблонов Nuclei | 6 режимов работы | WebSocket C2 | БЕСПЛАТНО**

Argus — автономный Red Team фреймворк, прошедший путь от bash-скрипта до профессионального инструмента за 56 версий.

## Возможности
- Пассивный сканер — 67 сигнатур (SQLi, XSS, LFI, CORS, JWT, токены, CMS, облака)
- 12 типов инъекций — SQL, NoSQL, LDAP, XXE, SSTI, CMDi, LFI, SSRF, GraphQL, WebSocket
- Agentic Scanner — самонаводящийся, определяет тип цели и выбирает стратегию атаки
- Sentinel AI — понимает ответы сервера и адаптирует атаку на лету
- Malleable C2 — маскировка под Teams/O365, WebSocket Beacon
- Supply Chain Hunter — поиск уязвимостей через разработчиков, хостинг, CDN
- Vault — шифрование секретов (AES-256)
- 6 форматов отчётов — HTML, PDF, JSON, CSV, XML + PoC + CVSS + EPSS

## Быстрый старт
git clone https://github.com/manser/argus-bash
cd argus-bash
chmod +x argus.sh argus
./argus check
./argus help

## Использование
./argus scan http://target.com                    # Полный скан
./argus agentic http://target.com --mode speed     # Быстрая разведка
./argus agentic http://target.com --mode advisor   # Только план, без атак
./argus passive                                    # Пассивный сбор (прокси 127.0.0.1:9990)
./argus c2 8443                                    # C2 сервер

## Режимы Agentic Scanner
| Режим     | Описание                      |
|-----------|-------------------------------|
| smart     | Авто-выбор стратегии          |
| speed     | Быстрая разведка (5 мин)      |
| deep      | Глубокий анализ (30+ мин)     |
| advisor   | Только план, без атак         |
| executor  | Выполнение плана              |
| favorites | Только избранные проверки     |

## Уникальные фичи (нет у конкурентов)
- Self-learning payloads (SQLite + авто-подбор)
- Dead Man's Switch (авто-слив результатов)
- Стеганография (exfil в изображениях)
- Honeypot Detector (определение ловушек)
- P2P CVE Sync (mesh-сеть)
- Decoy Generator (путаем SOC)

## Сравнение
|                    | Argus-Bash | Burp Suite Pro | Metasploit | Nessus    |
|--------------------|------------|----------------|------------|-----------|
| Пассивный сканер   | 67 сигнатур| 100+           | ❌         | ❌        |
| Repeater + Intruder| ✅         | ✅             | ❌         | ❌        |
| C2 Beacon          | HTTPS + WS | ❌             | ✅         | ❌        |
| Agentic AI         | ✅         | ❌             | ❌         | ❌        |
| Supply Chain       | ✅         | ❌             | ❌         | ❌        |
| Цена               | $0         | $449/год       | $15K       | $3K/год   |

## Дисклеймер
Только для легального тестирования с письменного разрешения владельца системы.

## Лицензия
MIT
