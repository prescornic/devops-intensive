#!/usr/bin/env python3
import argparse
import csv
import datetime as dt
import json
import logging
import os
import re
import shutil
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Tuple

# External dep: PyYAML + requests
import requests
import yaml


EMAIL_DOMAIN_RE = re.compile(r"^[^@]+@([^@]+)$")
SAFE_USERNAME_RE = re.compile(r"^[a-z_][a-z0-9_-]{0,31}$")  # Linux-ish


@dataclass
class ApiResult:
    ok: bool
    status_code: int
    elapsed_ms: int
    data: Any
    error: str = ""


def load_config(path: str) -> Dict[str, Any]:
    with open(path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def ensure_dir(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)


def setup_logger(log_file: str) -> logging.Logger:
    logger = logging.getLogger("api-data-ops")
    logger.setLevel(logging.INFO)

    fmt = logging.Formatter("%(asctime)s [%(levelname)s] %(message)s")

    # Console
    ch = logging.StreamHandler(sys.stdout)
    ch.setFormatter(fmt)
    logger.addHandler(ch)

    # File
    fh = logging.FileHandler(log_file)
    fh.setFormatter(fmt)
    logger.addHandler(fh)

    return logger


def fetch_json(url: str, timeout: int, retries: int, backoff: float, logger: logging.Logger) -> ApiResult:
    last_err = ""
    for attempt in range(1, retries + 1):
        start = time.time()
        try:
            resp = requests.get(url, timeout=timeout)
            elapsed_ms = int((time.time() - start) * 1000)

            if resp.status_code >= 400:
                last_err = f"HTTP {resp.status_code}"
                logger.warning(f"API error ({url}): {last_err} (attempt {attempt}/{retries})")
            else:
                try:
                    return ApiResult(True, resp.status_code, elapsed_ms, resp.json())
                except Exception as e:
                    last_err = f"JSON parse error: {e}"
                    logger.warning(f"API JSON parse error ({url}): {last_err} (attempt {attempt}/{retries})")

        except requests.exceptions.Timeout:
            elapsed_ms = int((time.time() - start) * 1000)
            last_err = "timeout"
            logger.warning(f"API timeout ({url}) after {elapsed_ms}ms (attempt {attempt}/{retries})")
        except requests.exceptions.RequestException as e:
            elapsed_ms = int((time.time() - start) * 1000)
            last_err = f"request error: {e}"
            logger.warning(f"API request error ({url}) after {elapsed_ms}ms (attempt {attempt}/{retries})")

        if attempt < retries:
            time.sleep(backoff * attempt)

    return ApiResult(False, 0, 0, None, error=last_err)


def email_domains(users: List[Dict[str, Any]]) -> List[str]:
    domains = set()
    for u in users:
        m = EMAIL_DOMAIN_RE.match(str(u.get("email", "")).strip())
        if m:
            domains.add(m.group(1).lower())
    return sorted(domains)


def group_users_by_company(users: List[Dict[str, Any]]) -> Dict[str, List[Dict[str, Any]]]:
    grouped: Dict[str, List[Dict[str, Any]]] = {}
    for u in users:
        company = (u.get("company") or {}).get("name") or "UNKNOWN"
        grouped.setdefault(company, []).append(u)
    # sort users by username for readability
    for k in grouped:
        grouped[k] = sorted(grouped[k], key=lambda x: str(x.get("username", "")))
    return dict(sorted(grouped.items(), key=lambda kv: kv[0].lower()))


def top_posters(users: List[Dict[str, Any]], posts: List[Dict[str, Any]], top_n: int = 3) -> List[Tuple[str, int]]:
    # Map userId -> count
    counts: Dict[int, int] = {}
    for p in posts:
        uid = int(p.get("userId"))
        counts[uid] = counts.get(uid, 0) + 1

    # Map id -> username
    id_to_username = {int(u["id"]): str(u.get("username")) for u in users if "id" in u}

    scored = []
    for uid, cnt in counts.items():
        scored.append((id_to_username.get(uid, f"user-{uid}"), cnt))

    scored.sort(key=lambda x: (-x[1], x[0].lower()))
    return scored[:top_n]


def write_json(path: Path, obj: Any) -> None:
    with open(path, "w", encoding="utf-8") as f:
        json.dump(obj, f, indent=2, ensure_ascii=False)


def write_csv_users_by_company(path: Path, grouped: Dict[str, List[Dict[str, Any]]]) -> None:
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["company", "username", "name", "email", "website"])
        for company, users in grouped.items():
            for u in users:
                w.writerow([company, u.get("username", ""), u.get("name", ""), u.get("email", ""), u.get("website", "")])


def write_top_posters_txt(path: Path, top: List[Tuple[str, int]]) -> None:
    lines = [f"{i+1}. {username} - {count} posts" for i, (username, count) in enumerate(top)]
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def is_root() -> bool:
    return os.geteuid() == 0


def validate_username(username: str) -> bool:
    return bool(SAFE_USERNAME_RE.match(username))


def run_cmd(cmd: List[str]) -> Tuple[int, str]:
    p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    return p.returncode, p.stdout


def linux_user_exists(username: str) -> bool:
    code, _ = run_cmd(["id", username])
    return code == 0


def create_linux_user(username: str, logger: logging.Logger, dry_run: bool) -> None:
    if linux_user_exists(username):
        logger.info(f"User exists: {username}")
        return
    if dry_run:
        logger.info(f"[DRY-RUN] Would create Linux user: {username}")
        return

    # Create with home directory
    code, out = run_cmd(["useradd", "-m", "-s", "/bin/bash", username])
    if code != 0:
        raise RuntimeError(f"useradd failed for {username}: {out}")
    logger.info(f"Created Linux user: {username}")


def create_home_subdirs(username: str, logger: logging.Logger, dry_run: bool) -> None:
    home = Path("/home") / username
    subdirs = ["logs", "data", "backup"]
    for sd in subdirs:
        p = home / sd
        if dry_run:
            logger.info(f"[DRY-RUN] Would create dir: {p}")
            continue
        p.mkdir(parents=True, exist_ok=True)
    if dry_run:
        return
    # Set ownership to user
    code, out = run_cmd(["chown", "-R", f"{username}:{username}", str(home)])
    if code != 0:
        raise RuntimeError(f"chown failed for {username}: {out}")
    logger.info(f"Ensured /home/{username}/{{logs,data,backup}} with ownership")


def ensure_ssh_key(username: str, logger: logging.Logger, dry_run: bool) -> None:
    home = Path("/home") / username
    ssh_dir = home / ".ssh"
    priv = ssh_dir / "id_ed25519"
    pub = ssh_dir / "id_ed25519.pub"

    if pub.exists() and priv.exists():
        logger.info(f"SSH key already exists for {username}: {pub}")
        return

    if dry_run:
        logger.info(f"[DRY-RUN] Would generate SSH key for {username}")
        return

    ssh_dir.mkdir(parents=True, exist_ok=True)
    code, out = run_cmd(["ssh-keygen", "-t", "ed25519", "-f", str(priv), "-N", "", "-C", f"{username}@api-data-ops"])
    if code != 0:
        raise RuntimeError(f"ssh-keygen failed for {username}: {out}")

    # Permissions + ownership
    run_cmd(["chmod", "700", str(ssh_dir)])
    run_cmd(["chmod", "600", str(priv)])
    run_cmd(["chmod", "644", str(pub)])
    code, out = run_cmd(["chown", "-R", f"{username}:{username}", str(ssh_dir)])
    if code != 0:
        raise RuntimeError(f"chown .ssh failed for {username}: {out}")

    logger.info(f"Generated SSH key for {username}: {pub}")


def normalize_domain(website: str) -> str:
    # jsonplaceholder websites are like "hildegard.org"
    w = str(website).strip().lower()
    w = w.replace("http://", "").replace("https://", "")
    w = w.split("/")[0]
    return w


def generate_nginx_vhost(username: str, website: str, out_dir: Path, server_root: str, listen_http: int,
                         logger: logging.Logger, dry_run: bool) -> None:
    domain = normalize_domain(website)
    if not domain or "." not in domain:
        logger.info(f"Skipping nginx config for {username} (no valid domain): website={website}")
        return

    conf_path = out_dir / f"{username}.conf"
    root_dir = Path(server_root) / username

    content = f"""server {{
    listen {listen_http};
    server_name {domain};

    access_log /var/log/nginx/{username}.access.log;
    error_log  /var/log/nginx/{username}.error.log;

    location / {{
        root {root_dir};
        index index.html;
        try_files $uri $uri/ =404;
    }}
}}
"""

    if dry_run:
        logger.info(f"[DRY-RUN] Would write nginx vhost: {conf_path} (server_name={domain})")
        return

    ensure_dir(out_dir)
    conf_path.write_text(content, encoding="utf-8")
    logger.info(f"Wrote nginx vhost config: {conf_path} (server_name={domain})")


def cleanup_old_reports(reports_dir: Path, keep_days: int, logger: logging.Logger) -> int:
    if not reports_dir.exists():
        return 0
    cutoff = dt.datetime.now(dt.timezone.utc) - dt.timedelta(days=keep_days)
    removed = 0
    for child in reports_dir.iterdir():
        if not child.is_dir():
            continue
        # Expect YYYY-MM-DD
        try:
            d = dt.datetime.strptime(child.name, "%Y-%m-%d").replace(tzinfo=dt.timezone.utc)
        except ValueError:
            continue
        if d < cutoff:
            shutil.rmtree(child)
            removed += 1
            logger.info(f"Removed old report dir: {child}")
    return removed


def main() -> int:
    ap = argparse.ArgumentParser(description="Task 6 - API Data Operations and Monitoring")
    ap.add_argument("--config", default="config.yaml", help="Path to config.yaml")
    ap.add_argument("--report-only", action="store_true", help="Only generate reports (no system ops)")
    ap.add_argument("--dry-run", action="store_true", help="Do not change system; log intended actions")
    ap.add_argument("--apply", action="store_true", help="Allow system operations (requires sudo for user changes)")
    args = ap.parse_args()

    cfg = load_config(args.config)

    log_file = cfg["paths"]["log_file"]
    ensure_dir(Path(log_file).parent)
    logger = setup_logger(log_file)

    today = dt.datetime.now(dt.timezone.utc).strftime("%Y-%m-%d")
    reports_dir = Path(cfg["paths"]["reports_dir"]) / today
    ensure_dir(reports_dir)

    timeout = int(cfg["api"]["timeout_seconds"])
    retries = int(cfg["api"]["retries"])
    backoff = float(cfg["api"]["backoff_seconds"])

    users_url = cfg["api"]["users_url"]
    posts_url = cfg["api"]["posts_url"]

    logger.info("Starting fetch-and-process run")
    users_res = fetch_json(users_url, timeout, retries, backoff, logger)
    posts_res = fetch_json(posts_url, timeout, retries, backoff, logger)

    api_metrics = {
        "users": {"url": users_url, "ok": users_res.ok, "status_code": users_res.status_code, "elapsed_ms": users_res.elapsed_ms, "error": users_res.error},
        "posts": {"url": posts_url, "ok": posts_res.ok, "status_code": posts_res.status_code, "elapsed_ms": posts_res.elapsed_ms, "error": posts_res.error},
    }

    if not users_res.ok or not posts_res.ok:
        # Alert condition: API unreachable
        logger.error("API unreachable or failed after retries. Aborting report/system ops.")
        write_json(reports_dir / "api-metrics.json", api_metrics)
        (reports_dir / "summary.txt").write_text(
            f"FAILED: API unreachable. users_ok={users_res.ok} posts_ok={posts_res.ok}\n", encoding="utf-8"
        )
        return 2

    users = list(users_res.data)
    posts = list(posts_res.data)

    grouped = group_users_by_company(users)
    top3 = top_posters(users, posts, top_n=3)
    domains = email_domains(users)

    report = {
        "timestamp_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "total_users": len(users),
        "unique_email_domains": domains,
        "top_posters": [{"username": u, "posts": c} for (u, c) in top3],
        "users_by_company": {company: [u.get("username") for u in us] for company, us in grouped.items()},
        "api_metrics": api_metrics,
    }

    # Write reports
    write_json(reports_dir / "users-summary.json", report)
    write_csv_users_by_company(reports_dir / "users-by-company.csv", grouped)
    write_top_posters_txt(reports_dir / "top-posters.txt", top3)
    write_json(reports_dir / "api-metrics.json", api_metrics)
    logger.info(f"Wrote reports to: {reports_dir}")

    # System operations
    ops_cfg = cfg.get("system_ops", {})
    do_ops = (not args.report_only) and args.apply
    if (not args.report_only) and (not args.apply):
        logger.info("System ops are disabled unless you pass --apply (safety default).")

    if do_ops and not is_root():
        logger.error("You passed --apply but are not running with sudo/root. Re-run with: sudo ./fetch-and-process.py --apply")
        return 3

    operations_done: List[str] = []
    errors: List[str] = []

    if not args.report_only:
        for u in users:
            username = str(u.get("username", "")).strip().lower()
            if not validate_username(username):
                logger.warning(f"Skipping invalid username from API: {username}")
                continue

            try:
                if ops_cfg.get("create_users", True):
                    create_linux_user(username, logger, args.dry_run or (not do_ops))
                    operations_done.append(f"user:{username}")

                if ops_cfg.get("create_home_subdirs", True):
                    # Requires user to exist for chown to work; in dry-run it's fine.
                    create_home_subdirs(username, logger, args.dry_run or (not do_ops))
                    operations_done.append(f"dirs:{username}")

                if ops_cfg.get("generate_ssh_keys", True):
                    ensure_ssh_key(username, logger, args.dry_run or (not do_ops))
                    operations_done.append(f"ssh:{username}")

                if ops_cfg.get("generate_nginx_configs", True):
                    nginx_out = Path(cfg["paths"]["nginx_configs_dir"])
                    generate_nginx_vhost(
                        username=username,
                        website=str(u.get("website", "")),
                        out_dir=nginx_out,
                        server_root=str(cfg["nginx"]["server_root"]),
                        listen_http=int(cfg["nginx"]["listen_http"]),
                        logger=logger,
                        dry_run=args.dry_run or (not do_ops),
                    )
                    operations_done.append(f"nginx:{username}")

            except Exception as e:
                msg = f"{username}: {e}"
                logger.error(msg)
                errors.append(msg)

    # Cleanup old reports
    removed = cleanup_old_reports(Path(cfg["paths"]["reports_dir"]), int(cfg["retention"]["keep_days"]), logger)

    summary_lines = [
        f"SUCCESS: report generated for {today}",
        f"Users: {len(users)}",
        f"Top posters: {', '.join([f'{u}({c})' for u,c in top3])}",
        f"Unique email domains: {', '.join(domains)}",
        f"API response times: users={users_res.elapsed_ms}ms posts={posts_res.elapsed_ms}ms",
        f"Operations requested: report_only={args.report_only} dry_run={args.dry_run} apply={args.apply}",
        f"Operations performed count: {len(operations_done)}",
        f"Old report dirs removed: {removed}",
    ]
    if errors:
        summary_lines.append("ERRORS:")
        summary_lines.extend([f"- {e}" for e in errors])

    (reports_dir / "summary.txt").write_text("\n".join(summary_lines) + "\n", encoding="utf-8")
    logger.info("Run complete. Summary written.")

    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
