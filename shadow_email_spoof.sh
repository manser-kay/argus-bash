#!/bin/bash
DOMAIN=$1
[ -z "$DOMAIN" ] && echo "Usage: $0 target.com" && exit 1

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — EMAIL SPOOF CHECKER        ║"
echo "╚══════════════════════════════════════════════╝"

echo "Проверяю $DOMAIN на возможность подделки email..."

# 1. SPF запись
echo "[SPF]"
SPF=$(dig +short "$DOMAIN" TXT 2>/dev/null | grep "v=spf1")
if [ -n "$SPF" ]; then
    echo "  ✅ SPF настроен"
    echo "$SPF" | grep -qi "\-all" && echo "  🔒 Жёсткая защита (-all)" || echo "  ⚠️ Мягкая защита (~all) — можно подделать!"
else
    echo "  🔴 SPF НЕ настроен — можно подделать!"
fi

# 2. DKIM
echo "[DKIM]"
DKIM=$(dig +short "google._domainkey.$DOMAIN" TXT 2>/dev/null)
[ -n "$DKIM" ] && echo "  ✅ DKIM найден" || echo "  🟡 DKIM не найден"

# 3. DMARC
echo "[DMARC]"
DMARC=$(dig +short "_dmarc.$DOMAIN" TXT 2>/dev/null | grep "v=DMARC1")
if [ -n "$DMARC" ]; then
    echo "  ✅ DMARC настроен"
    echo "$DMARC" | grep -qi "p=reject" && echo "  🔒 reject — подделка заблокирована" || echo "  ⚠️ p=none/quarantine — подделка возможна"
else
    echo "  🔴 DMARC НЕ настроен — можно подделать!"
fi

# Итог
echo ""
echo "══════════════════════════════════════════════"
if [ -z "$SPF" ] && [ -z "$DMARC" ]; then
    echo "  🔴 МОЖНО ПОДДЕЛАТЬ: SPF и DMARC отсутствуют"
elif [ -z "$SPF" ]; then
    echo "  🟡 SPF отсутствует — подделка возможна"
elif [ -z "$DMARC" ]; then
    echo "  🟡 DMARC отсутствует — подделка возможна"
else
    echo "  🟢 Защищено — подделка затруднена"
fi
echo "══════════════════════════════════════════════"
