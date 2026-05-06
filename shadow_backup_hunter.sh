#!/bin/bash
TARGET=${1:-"example.com"}
echo "╔══════════════════════════════════════════════╗"
echo "║   💾 BACKUP HUNTER — Поиск бэкапов          ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Ищем файлы бэкапов которые часто оставляют на сервере
BACKUP_PATTERNS=(
    "backup.zip" "backup.tar.gz" "backup.sql" "dump.sql"
    "db_backup.tar.gz" "database.sql" "export.sql"
    "backup_$(date +%Y).zip" "backup_$(date +%Y%m).zip"
    "wp-content/backup" "backups/"
    ".env.backup" ".env.old" ".env.example"
    "config.php.bak" "wp-config.php.bak" "wp-config.php.old"
)

echo "[BACKUP] 💾 Ищу бэкапы на $TARGET..."
for pattern in "${BACKUP_PATTERNS[@]}"; do
    code=$(curl -sk --max-time 3 -o /dev/null -w "%{http_code}" "$TARGET/$pattern" 2>/dev/null)
    [ "$code" = "200" ] && echo "  💀 НАЙДЕН: $TARGET/$pattern (HTTP 200)"
done

echo "[BACKUP] ✅ Поиск завершён"
