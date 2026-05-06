#!/bin/bash
CVE_ID=$1
[ -z "$CVE_ID" ] && echo "Usage: $0 CVE-2026-XXXXX" && exit 1

echo "[CVE v2] Обогащаю $CVE_ID..."

# Источник 1: NVD
echo "[CVE] NVD:"
curl -s "https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=$CVE_ID" 2>/dev/null | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)['vulnerabilities'][0]['cve']
    print(f\"  CVSS: {d.get('metrics',{}).get('cvssMetricV31',[{}])[0].get('cvssData',{}).get('baseScore','N/A')}\")
    print(f\"  Описание: {d.get('descriptions',[{}])[0].get('value','')[:150]}\")
except: pass
" 2>/dev/null

# Источник 2: EPSS (вероятность эксплуатации)
echo "[CVE] EPSS:"
curl -s "https://api.first.org/data/v1/epss?cve=$CVE_ID" 2>/dev/null | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)['data'][0]
    epss = float(d['epss'])
    risk = '🔴 Высокий' if epss > 0.5 else '🟡 Средний' if epss > 0.1 else '🟢 Низкий'
    print(f\"  Вероятность атаки: {epss}% — {risk}\")
except: pass
" 2>/dev/null

# Источник 3: PoC на GitHub
echo "[CVE] PoC:"
curl -s "https://poc-in-github.motikan2010.net/api/v1/?cve_id=$CVE_ID" 2>/dev/null | python3 -c "
import sys, json
try:
    pocs = json.load(sys.stdin).get('pocs',[])
    print(f\"  Готовых эксплойтов: {len(pocs)}\")
    for p in pocs[:3]:
        print(f\"  🔗 {p.get('html_url','')}\")
except: pass
" 2>/dev/null

echo "[CVE v2] Готово"
