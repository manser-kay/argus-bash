#!/usr/bin/env python3
import sys

def calc_cvss(av='N', ac='L', at='N', pr='N', ui='N', vc='H', vi='H', va='H', sc='N', si='N', sa='N'):
    # CVSS 4.0 simplified calculator
    scores = {'AV': {'N':1.0,'A':0.8,'L':0.6,'P':0.3},'AC': {'L':1.0,'H':0.7},
              'PR': {'N':1.0,'L':0.8,'H':0.5},'UI': {'N':1.0,'A':0.7,'P':0.5,'R':0.3}}
    base = 8.5 * scores['AV'][av] * scores['AC'][ac] * scores['PR'][pr] * scores['UI'][ui]
    if vc == 'H' or vi == 'H' or va == 'H':
        base = min(base, 10.0)
    if base >= 9.0: severity = "CRITICAL"
    elif base >= 7.0: severity = "HIGH"
    elif base >= 4.0: severity = "MEDIUM"
    else: severity = "LOW"
    return round(base,1), severity, f"CVSS:4.0/AV:{av}/AC:{ac}/AT:{at}/PR:{pr}/UI:{ui}/VC:{vc}/VI:{vi}/VA:{va}/SC:{sc}/SI:{si}/SA:{sa}"

if __name__ == '__main__':
    if len(sys.argv) == 1:
        score, sev, vector = calc_cvss()
        print(f"[CVSS] Score: {score} ({sev})")
        print(f"[CVSS] Vector: {vector}")
    elif len(sys.argv) == 3:
        score, sev, vector = calc_cvss(av=sys.argv[1], vc=sys.argv[2])
        print(f"[CVSS] Score: {score} ({sev})")
    else:
        print("Usage: python3 ~/cvss_calc.py [AV VC]")
        print("AV: N(etwork)|A(djacent)|L(ocal)|P(hysical)")
        print("VC: H(igh)|L(ow)|N(one)")
