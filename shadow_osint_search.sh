#!/bin/bash
QUERY=$1
[ -z "$QUERY" ] && echo "Usage: $0 'search query'" && exit 1

ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$QUERY'))" 2>/dev/null || echo "$QUERY")

echo "[OSINT] Поиск '$QUERY':"
echo "  🔗 Shodan:     https://www.shodan.io/search?query=$ENCODED"
echo "  🔗 Censys:     https://search.censys.io/search?resource=hosts&q=$ENCODED"
echo "  🔗 FOFA:       https://fofa.info/result?q=$ENCODED"
echo "  🔗 Hunter:     https://hunter.io/search/$ENCODED"
echo "  🔗 DeHashed:   https://dehashed.com/search?query=$ENCODED"
echo "  🔗 LeakIX:     https://leakix.net/search?q=$ENCODED"
echo "  🔗 URLScan:    https://urlscan.io/search/#$ENCODED"
echo "  🔗 Wayback:    https://web.archive.org/web/*/$ENCODED"
echo "  🔗 GreyNoise:  https://viz.greynoise.io/query?gnql=$ENCODED"
echo "  🔗 CRT.sh:     https://crt.sh/?q=$ENCODED"
