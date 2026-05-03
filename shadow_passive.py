#!/usr/bin/env python3
import http.server, re, os
LOG = os.path.expanduser('~/shadow_scan.txt')
PATTERNS = {
    'SQLi': [r"union\s+select", r"sql\s+syntax", r"ORA-\d+"],
    'XSS': [r'<script', r'alert\(', r'onerror='],
    'LFI': [r'\.\./\.\./', r'/etc/passwd'],
    'Token': [r'api_key=', r'bearer [A-Za-z0-9]'],
    'IDOR': [r'(?:id|user_id|uid)=\d+'],
    'Email': [r'[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}'],
}
class S(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        for cat, pats in PATTERNS.items():
            for p in pats:
                if re.search(p, self.path, re.I):
                    msg = cat + ': ' + self.path
                    with open(LOG, 'a') as f:
                        f.write(msg + '\n')
                    print('\033[91m[PASSIVE] ' + msg + '\033[0m')
                    break
        self.send_response(200)
        self.end_headers()
    def do_POST(self):
        self.do_GET()
http.server.HTTPServer(('0.0.0.0', 9998), S).serve_forever()
