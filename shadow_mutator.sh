#!/bin/bash
# ╔══════════════════════════════════════════════╗
# ║   🧬 MUTATOR — Мутирует код перед запуском  ║
# ╚══════════════════════════════════════════════╝

INPUT=$1
[ -z "$INPUT" ] && { echo "Usage: $0 script.sh"; exit 1; }
[ ! -f "$INPUT" ] && { echo "Файл $INPUT не найден"; exit 1; }

MUTATED="${INPUT%.sh}_mutated.sh"

echo "[MUTATOR] 🧬 Мутирую $INPUT..."

# Случайные мутации
MUTATIONS=$((RANDOM % 10 + 5))
for i in $(seq 1 $MUTATIONS); do
    case $((RANDOM % 5)) in
        0) sed -i "s/TARGET/TARGET_$RANDOM/g" "$INPUT" ;;                          # Переименование переменных
        1) sed -i "/^#/a # $(openssl rand -hex 8 2>/dev/null || echo $RANDOM)" "$INPUT" ;; # Мусорные комментарии
        2) sed -i "s/curl/\\$(echo 'curl' | base64)/g" "$INPUT" ;;                  # Обфускация команд
        3) sed -i "/^$/d" "$INPUT" ;;                                              # Удаление пустых строк
        4) sed -i "s|http://|https://|g" "$INPUT" ;;                               # Замена HTTP на HTTPS
    esac
done

cp "$INPUT" "$MUTATED"
chmod +x "$MUTATED"
echo "[MUTATOR] ✅ Мутированный: $MUTATED"
