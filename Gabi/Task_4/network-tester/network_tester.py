#!/usr/bin/env python3
import json
import os
import socket
import ssl
import sys
import time
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from concurrent.futures import ThreadPoolExecutor, as_completed
from urllib.parse import urlparse

import requests
from colorama import Fore, Style, init as colorama_init

colorama_init(autoreset=True)


@dataclass
class TestResult:
    target: str
    type: str
    ok: bool
    timestamp_utc: str
    response_time_ms: float | None = None
    status_code: int | None = None
    error: str | None = None
    ssl_valid: bool | None = None
    ssl_not_after_utc: str | None = None
    ssl_days_remaining: int | None = None
    ssl_expiring_soon: bool | None = None
    dns_time_ms: float | None = None
    resolved_ips: list[str] | None = None


def now_utc_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def load_config(path: str) -> dict:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def ensure_reports_dir() -> str:
    reports_dir = os.path.join(os.getcwd(), "reports")
    os.makedirs(reports_dir, exist_ok=True)
    return reports_dir


def color_line(ok: bool, text: str) -> str:
    return (Fore.GREEN + "✓ " + text + Style.RESET_ALL) if ok else (Fore.RED + "✗ " + text + Style.RESET_ALL)


def http_test(url: str, is_https: bool, timeout_s: int, expected_status: int | None,
              ssl_warn_days: int) -> TestResult:
    start = time.perf_counter()
    parsed = urlparse(url)
    host = parsed.hostname or ""

    try:
        resp = requests.get(url, timeout=timeout_s)
        elapsed_ms = (time.perf_counter() - start) * 1000
        ok = True
        if expected_status is not None and resp.status_code != expected_status:
            ok = False

        result = TestResult(
            target=url,
            type="https" if is_https else "http",
            ok=ok,
            timestamp_utc=now_utc_iso(),
            response_time_ms=round(elapsed_ms, 2),
            status_code=resp.status_code
        )

        if is_https:
            ssl_info = get_ssl_info(host, parsed.port or 443, timeout_s, ssl_warn_days)
            # merge ssl info
            result.ssl_valid = ssl_info["ssl_valid"]
            result.ssl_not_after_utc = ssl_info["ssl_not_after_utc"]
            result.ssl_days_remaining = ssl_info["ssl_days_remaining"]
            result.ssl_expiring_soon = ssl_info["ssl_expiring_soon"]
            if not ssl_info["ssl_valid"]:
                result.ok = False
                result.error = ssl_info["error"]

        return result

    except requests.exceptions.RequestException as e:
        elapsed_ms = (time.perf_counter() - start) * 1000
        return TestResult(
            target=url,
            type="https" if is_https else "http",
            ok=False,
            timestamp_utc=now_utc_iso(),
            response_time_ms=round(elapsed_ms, 2),
            error=str(e)
        )


def get_ssl_info(host: str, port: int, timeout_s: int, warn_days: int) -> dict:
    """
    Fetch certificate from server and compute expiration.
    """
    start = time.perf_counter()
    try:
        ctx = ssl.create_default_context()
        with socket.create_connection((host, port), timeout=timeout_s) as sock:
            with ctx.wrap_socket(sock, server_hostname=host) as ssock:
                cert = ssock.getpeercert()
        # cert['notAfter'] example: 'Mar 15 12:00:00 2026 GMT'
        not_after_str = cert.get("notAfter")
        if not not_after_str:
            return {"ssl_valid": False, "ssl_not_after_utc": None, "ssl_days_remaining": None,
                    "ssl_expiring_soon": None, "error": "Certificate missing notAfter"}

        not_after_dt = datetime.strptime(not_after_str, "%b %d %H:%M:%S %Y %Z").replace(tzinfo=timezone.utc)
        days_remaining = int((not_after_dt - datetime.now(timezone.utc)).total_seconds() / 86400)

        return {
            "ssl_valid": days_remaining >= 0,
            "ssl_not_after_utc": not_after_dt.isoformat(),
            "ssl_days_remaining": days_remaining,
            "ssl_expiring_soon": days_remaining <= warn_days,
            "error": None
        }
    except Exception as e:
        _ = (time.perf_counter() - start) * 1000
        return {"ssl_valid": False, "ssl_not_after_utc": None, "ssl_days_remaining": None,
                "ssl_expiring_soon": None, "error": str(e)}


def dns_test(host: str, timeout_s: int) -> TestResult:
    start = time.perf_counter()
    try:
        # Set global default timeout for socket operations in this thread
        socket.setdefaulttimeout(timeout_s)
        infos = socket.getaddrinfo(host, None)
        elapsed_ms = (time.perf_counter() - start) * 1000
        ips = sorted({info[4][0] for info in infos})
        return TestResult(
            target=host,
            type="dns",
            ok=True,
            timestamp_utc=now_utc_iso(),
            dns_time_ms=round(elapsed_ms, 2),
            resolved_ips=ips
        )
    except Exception as e:
        elapsed_ms = (time.perf_counter() - start) * 1000
        return TestResult(
            target=host,
            type="dns",
            ok=False,
            timestamp_utc=now_utc_iso(),
            dns_time_ms=round(elapsed_ms, 2),
            error=str(e)
        )


def run_with_retries(fn, retries: int):
    last = None
    for attempt in range(retries + 1):
        last = fn()
        if last.ok:
            return last
    return last


def test_endpoint(ep: dict, timeout_s: int, retries: int, ssl_warn_days: int) -> TestResult:
    ep_type = ep.get("type")
    if ep_type in ("http", "https"):
        url = ep.get("url")
        if not url:
            return TestResult(target=str(ep), type=ep_type or "unknown", ok=False,
                              timestamp_utc=now_utc_iso(), error="Missing url field")
        expected = ep.get("expected_status")
        return run_with_retries(
            lambda: http_test(url, ep_type == "https", timeout_s, expected, ssl_warn_days),
            retries
        )
    if ep_type == "dns":
        host = ep.get("host")
        if not host:
            return TestResult(target=str(ep), type="dns", ok=False,
                              timestamp_utc=now_utc_iso(), error="Missing host field")
        return run_with_retries(lambda: dns_test(host, timeout_s), retries)

    # grpc optional - not implemented
    return TestResult(target=str(ep), type=ep_type or "unknown", ok=False,
                      timestamp_utc=now_utc_iso(), error="Unsupported endpoint type")


def print_console_summary(results: list[TestResult]) -> None:
    passed = sum(1 for r in results if r.ok)
    failed = len(results) - passed

    print(f"\nNetwork Service Test Report - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 55)

    for r in results:
        if r.type in ("http", "https"):
            base = f"{r.target} - "
            if r.ok and r.status_code is not None:
                msg = f"{base}{r.status_code} OK ({r.response_time_ms}ms)"
            else:
                msg = f"{base}{r.error or 'FAILED'}"
            if r.type == "https" and r.ssl_not_after_utc:
                msg += f" - SSL until {r.ssl_not_after_utc}"
                if r.ssl_expiring_soon:
                    msg += " (EXPIRING SOON)"
            print(color_line(r.ok, msg))

        elif r.type == "dns":
            if r.ok:
                msg = f"{r.target} - DNS resolved ({r.dns_time_ms}ms) -> {', '.join(r.resolved_ips or [])}"
            else:
                msg = f"{r.target} - DNS failed: {r.error}"
            print(color_line(r.ok, msg))

        else:
            print(color_line(False, f"{r.target} - Unsupported type: {r.type}"))

    print(f"\nSummary: {passed} passed, {failed} failed")


def save_json_report(results: list[TestResult], config_path: str) -> str:
    reports_dir = ensure_reports_dir()
    ts = datetime.now().strftime("%Y%m%d-%H%M%S")
    out_path = os.path.join(reports_dir, f"report-{ts}.json")

    payload = {
        "generated_at_utc": now_utc_iso(),
        "config_path": config_path,
        "results": [asdict(r) for r in results],
    }

    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2)

    return out_path


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 network_tester.py config.json")
        sys.exit(1)

    config_path = sys.argv[1]
    cfg = load_config(config_path)

    timeout_s = int(cfg.get("timeout_seconds", 5))
    retries = int(cfg.get("retries", 1))
    concurrency = int(cfg.get("concurrency", 10))
    ssl_warn_days = int(cfg.get("ssl_expiry_warning_days", 30))

    endpoints = cfg.get("endpoints", [])
    if not isinstance(endpoints, list) or not endpoints:
        print("ERROR: config must include endpoints list")
        sys.exit(1)

    results: list[TestResult] = []

    with ThreadPoolExecutor(max_workers=concurrency) as pool:
        futures = [
            pool.submit(test_endpoint, ep, timeout_s, retries, ssl_warn_days)
            for ep in endpoints
        ]
        for fut in as_completed(futures):
            results.append(fut.result())

    # Print + save
    print_console_summary(results)
    report_path = save_json_report(results, config_path)
    print(f"\nJSON report saved to: {report_path}")

    # SSL expiry alert summary
    expiring = [r for r in results if r.type == "https" and r.ssl_expiring_soon]
    if expiring:
        print(Fore.YELLOW + "\nALERT: SSL certificates expiring soon:" + Style.RESET_ALL)
        for r in expiring:
            print(Fore.YELLOW + f"- {r.target} expires in {r.ssl_days_remaining} days ({r.ssl_not_after_utc})" + Style.RESET_ALL)


if __name__ == "__main__":
    main()
