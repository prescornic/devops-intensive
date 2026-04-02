import ssl
import socket
import datetime

def get_ssl_info(hostname, timeout):
    try:
        context = ssl.create_default_context()
        with socket.create_connection((hostname, 443), timeout=timeout) as sock:
            with context.wrap_socket(sock, server_hostname=hostname) as ssock:
                cert = ssock.getpeercert()
                expire_date = datetime.datetime.strptime(cert['notAfter'], "%b %d %H:%M:%S %Y %Z")
                remaining = (expire_date - datetime.datetime.utcnow()).days
                return {
                    "valid": True,
                    "expires": expire_date.strftime("%Y-%m-%d"),
                    "days_left": remaining,
                    "alert": remaining < 30
                }
    except Exception as e:
        return {"valid": False, "error": str(e)}