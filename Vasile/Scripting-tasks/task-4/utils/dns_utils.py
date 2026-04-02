import socket
import time

def test_dns(host):
    start = time.time()
    try:
        addr = socket.gethostbyname(host)
        duration = (time.time() - start) * 1000
        return {"status": "success", "ip": addr, "time_ms": round(duration, 2)}
    except Exception as e:
        return {"status": "failed", "error": str(e)}