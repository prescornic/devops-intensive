from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    return "Multi-stage Build Successful!"

@app.route('/health')
def health():
    return jsonify(status="up", engine="multi-stage")

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)