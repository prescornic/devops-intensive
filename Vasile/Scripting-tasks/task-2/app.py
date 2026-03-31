from flask import Flask, jsonify
from flask_sock import Sock

app = Flask(__name__)
sock = Sock(app)

@app.route('/status')
def status():
    return jsonify({
        "status": "online",
        "message": "Server is running smoothly"
    })

@sock.route('/ws')
def echo(ws):
    while True:
        data = ws.receive()
        if data:
            ws.send(f"Echo: {data}")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

@app.before_request
def basic_waf():
    malicious_patterns = ["' OR '1'='1", "UNION SELECT", "DROP TABLE", "--"]
    
    query = request.query_string.decode('utf-8').upper()
    
    for pattern in malicious_patterns:
        if pattern.upper() in query:
            app.logger.warning(f"WAF Blocked potential SQLi: {query}")
            abort(403)