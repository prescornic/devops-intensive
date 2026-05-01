import os
import platform
import time
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello from Docker!"

@app.route('/health')
def health():
    return jsonify({
        "status": "healthy",
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    })

@app.route('/info')
def info():
    return jsonify({
        "hostname": os.uname().nodename,
        "platform": platform.platform(),
        "python_version": platform.python_version(),
        "app_env": os.getenv("APP_ENV", "production")
    })

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)