import requests
import time
from .ssl_utils import get_ssl_info

def test_http(endpoint, timeout):
    url = endpoint['url']
    expected = endpoint.get('expected_status', 200)
    start = time.time()
    
    try:
        response = requests.get(url, timeout=timeout)
        duration = (time.time() - start) * 1000
        
        res = {
            "url": url,
            "status_code": response.status_code,
            "success": response.status_code == expected,
            "time_ms": round(duration, 2),
            "ssl": None
        }

        if url.startswith("https"):
            hostname = url.split("//")[-1].split("/")[0]
            res["ssl"] = get_ssl_info(hostname, timeout)
        
        return res
    except Exception as e:
        return {"url": url, "success": False, "error": str(e)}