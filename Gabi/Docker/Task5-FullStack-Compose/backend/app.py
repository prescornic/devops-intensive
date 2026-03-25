import os
from flask import Flask, jsonify, request
import psycopg2
import redis

app = Flask(__name__)

DB_HOST = os.getenv("POSTGRES_HOST", "postgres")
DB_NAME = os.getenv("POSTGRES_DB", "appdb")
DB_USER = os.getenv("POSTGRES_USER", "appuser")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD", "secretpass")
DB_PORT = int(os.getenv("POSTGRES_PORT", "5432"))

REDIS_HOST = os.getenv("REDIS_HOST", "redis")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))

def get_db_connection():
    return psycopg2.connect(
        host=DB_HOST,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        port=DB_PORT
    )

def get_redis_client():
    return redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)

@app.route("/api/health")
def health():
    db_ok = False
    redis_ok = False

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT 1;")
        cur.fetchone()
        cur.close()
        conn.close()
        db_ok = True
    except Exception:
        db_ok = False

    try:
        r = get_redis_client()
        r.ping()
        redis_ok = True
    except Exception:
        redis_ok = False

    status = "healthy" if db_ok and redis_ok else "unhealthy"

    return jsonify({
        "status": status,
        "database": db_ok,
        "redis": redis_ok
    }), 200 if status == "healthy" else 503

@app.route("/api/users", methods=["GET"])
def get_users():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id, name, email FROM users ORDER BY id;")
        rows = cur.fetchall()
        cur.close()
        conn.close()

        users = [{"id": row[0], "name": row[1], "email": row[2]} for row in rows]
        return jsonify(users), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/users", methods=["POST"])
def create_user():
    data = request.get_json()
    name = data.get("name")
    email = data.get("email")

    if not name or not email:
        return jsonify({"error": "name and email are required"}), 400

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO users (name, email) VALUES (%s, %s) RETURNING id;",
            (name, email)
        )
        user_id = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({
            "id": user_id,
            "name": name,
            "email": email
        }), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/cache", methods=["GET"])
def cache_demo():
    try:
        r = get_redis_client()
        count = r.incr("api_cache_counter")
        return jsonify({
            "message": "Redis counter incremented",
            "counter": count
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api")
def api_root():
    return jsonify({"message": "Backend API is running"}), 200

if __name__ == "__main__":
    port = int(os.getenv("BACKEND_PORT", "5000"))
    app.run(host="0.0.0.0", port=port)