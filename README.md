# ShadowStrike v56.1 — Red Team Framework

**26 файлов | 0 ошибок синтаксиса | Открытый исходный код**

ShadowStrike — автономный Red Team фреймворк, прошедший путь от простого bash-скрипта до профессионального инструмента.

## Что внутри

### Ядро
- `shadow.sh` — основной фреймворк
- `shadow_passive.py` — пассивный сканер
- `shadow_c2_server.py` + `shadow_c2_agent.sh` — C2 сервер и агент
- `shadow_console.sh` — боевая консоль
- `shadow_check.sh` — проверка готовности

### Атака
- `shadow_supervisor.sh` — диспетчер атак
- `shadow_autopwn.sh` — цепочки эксплуатации
- `shadow_lootrun.sh` — быстрый поиск сокровищ

### Post-exploit
- `shadow_escalate.sh` — эскалация привилегий
- `shadow_persistence.sh` — закрепление
- `shadow_spider.sh` — расползание по сети
- `shadow_harvester.sh` — сбор артефактов
- `shadow_cleaner.sh` — заметание следов
- `shadow_jammer.sh` — дымовая завеса
- `shadow_stealth.sh` — режим невидимки

### Утилиты
- `smart_brute.sh` — контекстный брутфорс
- `waf_detect.sh` — определение WAF
- `quick_loot.sh` — быстрый поиск сокровищ
- `subfinder.sh` — поиск поддоменов
- `portscan.sh` — скан портов

## Быстрый старт
git clone https://github.com/manser-kay/argus-bash
cd argus-bash
chmod +x shadow.sh
./shadow check
./shadow scan http://testphp.vulnweb.com

## Автор
Автор не несёт ответственности за использование данного программного обеспечения.

## Лицензия
MIT
