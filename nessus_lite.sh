#!/bin/bash
# TOP-10 Nessus-подобных проверок которые реально нужны
TARGET=$1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')

echo "[TOP10] Running top 10 Nessus-like checks..."

# 1. SSL/TLS уязвимости
echo "[1/10] SSL/TLS..."
nmap --script ssl-poodle,ssl-heartbleed -p 443 "$DOMAIN" 2>/dev/null | grep -E "VULNERABLE|State:"

# 2. Открытые SMB порты
echo "[2/10] SMB..."
timeout 2 bash -c "echo >/dev/tcp/$DOMAIN/445" 2>/dev/null && echo "  🔴 SMB open — EternalBlue risk!"

# 3. RDP доступ
echo "[3/10] RDP..."
timeout 2 bash -c "echo >/dev/tcp/$DOMAIN/3389" 2>/dev/null && echo "  🔴 RDP open — BlueKeep risk!"

# 4. MySQL без пароля
echo "[4/10] MySQL..."
timeout 2 bash -c "echo >/dev/tcp/$DOMAIN/3306" 2>/dev/null && echo "  🟡 MySQL open"

# 5. Redis без пароля
echo "[5/10] Redis..."
timeout 2 bash -c "echo >/dev/tcp/$DOMAIN/6379" 2>/dev/null && echo "  🟡 Redis open"

# 6. Jenkins exposed
echo "[6/10] Jenkins..."
CODE=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET/jenkins" 2>/dev/null)
[ "$CODE" = "200" ] && echo "  🔴 Jenkins exposed!"

# 7. phpMyAdmin exposed
echo "[7/10] phpMyAdmin..."
for p in /phpmyadmin /phpMyAdmin /pma; do
    CODE=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET$p" 2>/dev/null)
    [ "$CODE" = "200" ] && echo "  🔴 phpMyAdmin: $p"
done

# 8. Уязвимые заголовки
echo "[8/10] Headers..."
HEADERS=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null)
echo "$HEADERS" | grep -qi "X-Powered-By" && echo "  🟡 X-Powered-By leaks tech stack"
echo "$HEADERS" | grep -qi "X-AspNet-Version" && echo "  🔴 ASP.NET version leaked"

# 9. Directory listing
echo "[9/10] Directory listing..."
for d in /uploads /backup /files /images /wp-content/uploads; do
    RESP=$(curl -sk --max-time 5 "$TARGET$d" 2>/dev/null)
    echo "$RESP" | grep -qi "Index of" && echo "  🔴 Directory listing: $d"
done

# 10. Default credentials (Tomcat)
echo "[10/10] Default creds..."
for cred in "admin:admin" "tomcat:tomcat" "admin:password"; do
    user="${cred%%:*}"
    pass="${cred##*:}"
    CODE=$(curl -sk -u "$user:$pass" -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET/manager/html" 2>/dev/null)
    [ "$CODE" = "200" ] && echo "  🔴 TOMCAT DEFAULT: $cred"
done

echo "[TOP10] Done"
