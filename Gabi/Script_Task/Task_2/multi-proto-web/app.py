#!/usr/bin/env python3
import re
import logging
from datetime import datetime, timezone
from aiohttp import web, WSMsgType
from urllib.parse import unquote_plus


APP_NAME = "multi-proto-app"
START_TIME = datetime.now(timezone.utc)

# Basic SQLi patterns (simple, for internship WAF requirement)
SQLI_PATTERNS = [
    r"('?\s*or\s*'?\d+'?\s*=\s*'?\d+'?)",   # ' OR '1'='1
    r"(\bor\b\s+\d+=\d+)",                  # OR 1=1
    r"(\bunion\b\s+\bselect\b)",            # UNION SELECT
    r"(\bdrop\b\s+\btable\b)",              # DROP TABLE
    r"(\binsert\b\s+\binto\b)",             # INSERT INTO
    r"(\bselect\b.+\bfrom\b)",              # SELECT ... FROM
    r"(--|#)",                              # SQL comments
]

SQLI_REGEX = re.compile("|".join(SQLI_PATTERNS), re.IGNORECASE)

LOG_FILE = "/tmp/task2-app.log"
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
    handlers=[logging.FileHandler(LOG_FILE), logging.StreamHandler()],
)

def is_malicious(request: web.Request) -> bool:
    # Decode URL-encoded characters so WAF sees real payloads (e.g. %27 -> ')
    decoded_url = unquote_plus(str(request.rel_url))

    combined = " ".join([
        decoded_url,
        request.headers.get("User-Agent", ""),
        request.headers.get("Referer", "")
    ])
    return bool(SQLI_REGEX.search(combined))


@web.middleware
async def waf_middleware(request: web.Request, handler):
    if is_malicious(request):
        logging.warning("WAF BLOCK ip=%s method=%s url=%s",
                        request.remote, request.method, request.rel_url)
        return web.json_response(
            {"blocked": True, "reason": "WAF: suspicious SQLi-like pattern"},
            status=403,
        )
    return await handler(request)

async def status(request: web.Request) -> web.Response:
    uptime_s = int((datetime.now(timezone.utc) - START_TIME).total_seconds())
    return web.json_response({
        "app": APP_NAME,
        "status": "ok",
        "uptime_seconds": uptime_s,
        "time_utc": datetime.now(timezone.utc).isoformat(),
    })

async def ws_handler(request: web.Request) -> web.WebSocketResponse:
    ws = web.WebSocketResponse()
    await ws.prepare(request)

    await ws.send_str("connected: send a message and I will echo it")

    async for msg in ws:
        if msg.type == WSMsgType.TEXT:
            await ws.send_str(f"echo: {msg.data}")
        elif msg.type == WSMsgType.BINARY:
            await ws.send_bytes(msg.data)
        elif msg.type == WSMsgType.ERROR:
            logging.error("ws error: %s", ws.exception())

    return ws

def main():
    app = web.Application(middlewares=[waf_middleware])
    app.router.add_get("/status", status)
    app.router.add_get("/ws", ws_handler)

    # Bind backend only to localhost; nginx will face the internet
    web.run_app(app, host="127.0.0.1", port=5000)

if __name__ == "__main__":
    main()
