from flask import Flask, render_template
import os

app = Flask(__name__)

@app.route("/")
def home():
    secret_path = "/run/secrets/app_secret"

    secret = "Secret unavailable"

    if os.path.exists(secret_path):
        # "r" for read
        with open(secret_path, "r") as file:
            secret = file.read().strip()

    return render_template("index.html", secret=secret)

@app.route("/health")
def health():
    return {
        "status": "healthy"
    }

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)