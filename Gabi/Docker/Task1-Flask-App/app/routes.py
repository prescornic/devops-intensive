from flask import Blueprint, jsonify
from datetime import datetime, timezone
import socket
import platform
import os

main = Blueprint("main", __name__)

@main.route("/")
def home():
    return "Hello from Docker!", 200

@main.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.now(timezone.utc).isoformat()
    })

@main.route("/info")
def info():
    return jsonify({
        "hostname": socket.gethostname(),
        "platform": platform.platform(),
        "python_version": platform.python_version(),
        "environment": os.getenv("APP_ENV", "development")
    })