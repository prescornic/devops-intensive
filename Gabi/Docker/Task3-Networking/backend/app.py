from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from backend", 200

@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

@app.route("/db-check")
def db_check():
    db_host = os.getenv("DB_HOST", "database")
    return jsonify({
        "backend_hostname": socket.gethostname(),
        "db_host_configured": db_host
    }), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)