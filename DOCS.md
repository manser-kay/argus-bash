# ShadowStrike v56.1 — Документация

## Установка

### Termux (Android)
pkg install nmap curl python3 git openssl -y
git clone https://github.com/manser-kay/argus-bash
cd argus-bash && chmod +x shadow.sh

### Linux (Kali/Ubuntu)
sudo apt install nmap curl python3 git openssl -y
git clone https://github.com/manser-kay/argus-bash
cd argus-bash && chmod +x shadow.sh

## Быстрый старт

./shadow check              Проверка готовности
./shadow scan http://target Полный скан
./shadow passive            Пассивный сбор (прокси 127.0.0.1:9990)
./shadow c2 8443            C2 сервер

## Команды

### Сканирование
scan <url>                  Полный скан (Nmap + SQLMap + инъекции + Nuclei)
quick <url>                 Быстрый скан (только порты + директории)
stealth <url>               Скрытный режим (Tor + рандомизация)

### C2
c2 <port>                   Запуск C2 сервера
beacon <server>             Подключение к C2
hydra <server>              Мульти-протокольный Beacon

### Post-Exploit
escalate                    Эскалация привилегий
persist <url>               Закрепление в системе
spider                      Расползание по сети
harvest                     Сбор артефактов
clean                       Заметание следов

### Утилиты
check                       Проверка готовности
console                     Боевая консоль
report                      Генерация отчёта
update                      Авто-обновление

## Режимы Agentic Scanner (для shadow.sh)
--mode speed                Быстрый (5 минут)
--mode deep                 Глубокий (30+ минут)
--mode advisor              Только план, без атак
--mode executor             Выполнение плана

## Форматы отчётов
HTML, PDF, JSON, CSV, XML, Hacker Report

## Ответственность
Автор не несёт ответственности за использование.
