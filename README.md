# ShadowStrike v56.1 — Red Team Framework

**87 сигнатур | 249 шаблонов Nuclei | 6 режимов работы | WebSocket C2 | Mimic Implant v2 | Hydra Beacon | Плагин-система | Smart Brute**

ShadowStrike прошёл путь от простого bash-скрипта до профессионального Red Team фреймворка за 56 версий.

## Что нового в v56.1
- **Smart Brute** — контекстный брутфорс: анализирует сайт и генерирует пароли на основе имени компании, email, годов основания
- Плагин-система — сообщество может добавлять свои модули
- Plugin Guard — защита от удаления и изменения чужих плагинов
- ROADMAP — план развития проекта
- Установщик одной командой

## Что умеет ShadowStrike
- Пассивный сканер — 87 сигнатур + история + авто-детект IDOR
- 12 типов инъекций — SQL, NoSQL, LDAP, XXE, SSTI, CMDi, LFI, SSRF, GraphQL, WebSocket
- Agentic Scanner — 6 режимов: smart, speed, deep, advisor, executor, favorites
- C2 — HTTPS Beacon (O365/Teams), DNS Beacon, WebSocket C2, Mimic Implant, Hydra Beacon
- Уникальные фичи — Predictor, Lie Detector, Mirror Maze, Echo, Whisper, Supply Chain Hunter
- Отчёты — After-Action Report, HTML, PDF, JSON, CSV, XML

## Быстрый старт
git clone https://github.com/manser-kay/shadowstrike
cd shadowstrike && chmod +x argus.sh argus
./argus check && ./argus help

## Кто кого: ShadowStrike vs Профи

| Возможность | ShadowStrike | Burp Pro | Metasploit | Nessus | CobaltStrike | Sliver | ZAP |
|---|---|---|---|---|---|---|---|
| Пассивный сканер | 87 | 100+ | нет | нет | нет | нет | 40+ |
| База сигнатур | 87 + 249 | 100+ | 2000+ | 70000+ | нет | нет | 40+ |
| Repeater/Intruder | да | да | нет | нет | нет | нет | да |
| Типы инъекций | 12 | 2-3 | 5+ | нет | нет | нет | 3-4 |
| C2 Beacon | 5 каналов | нет | да | нет | да | да | нет |
| Agentic AI | да | нет | нет | нет | нет | нет | нет |
| Supply Chain | да | нет | нет | нет | нет | нет | нет |
| Smart Brute | да | нет | нет | нет | нет | нет | нет |
| Плагин-система | да | да | да | да | да | нет | да |
| Predictor | да | нет | нет | нет | нет | нет | нет |
| Lie Detector | да | нет | нет | нет | нет | нет | нет |
| Echo (WAF) | да | нет | нет | нет | нет | нет | нет |
| Whisper (пассив) | да | нет | нет | нет | нет | нет | нет |
| Hacker Report | да | нет | нет | нет | нет | нет | нет |
| Цена | 0 | 449/год | 15K/год | 3K/год | 3.5K/год | 0 | 0 |

## Где мы пока слабы (честно)
- База эксплойтов: 249 шаблонов против 70,000 у Nessus
- C2 скрытность: уступаем Cobalt Strike в Malleable C2
- Графический интерфейс: только терминал

## Дорожная карта
Смотри ROADMAP.md

## Это базовая версия
Данный репозиторий содержит только публичные функции. Эксклюзивные хакерские модули доступны в закрытой версии.

## Дисклеймер
Мы не несём ответственности за ваши действия. Вы сами решаете как использовать этот инструмент.

## Лицензия
MIT
