import os 
from flask import Flask, jsonify

app = Flask(__name__)

SECRET_FILE = os.getenv("APP_SECRET_FILE", "/run/secrets/app_secret")

@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

@app.route("/secret-check")
def secret_check():
    try:
        with open(SECRET_FILE, "r", encoding="utf-8") as f:
            secret = f.read().strip()

        return jsonify({
            "secret_loaded": True,
            "secret_length": len(secret)
        }), 200
    except Exception as e:
        return jsonify({
            "secret_loaded": False,
            "error": str(e)
        }), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)