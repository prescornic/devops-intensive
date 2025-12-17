#!/usr/bin/env python3
import argparse
import datetime as dt
import os
import signal
import subprocess
import sys
from dataclasses import dataclass
from typing import Any, Dict, List, Optional

import yaml

LOG_DIR_DEFAULT = "./logs"
BACKUP_DIR_DEFAULT = "./backups"

SAFE_BASELINE_RULES = [
    # Keep existing connections alive (prevents killing your current SSH session)
    ["-A", "INPUT", "-m", "conntrack", "--ctstate", "ESTABLISHED,RELATED", "-j", "ACCEPT"],
    # Always allow loopback
    ["-A", "INPUT", "-i", "lo", "-j", "ACCEPT"],
]


@dataclass
class Rule:
    name: str
    port: int
    protocol: str
    action: str
    source: str = "any"


def sh(cmd: List[str], check=True, capture=True, text=True) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, check=check, capture_output=capture, text=text)


def log_line(log_file: str, level: str, msg: str) -> None:
    ts = dt.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
    line = f"{ts} [{level}] {msg}"
    print(line)
    with open(log_file, "a", encoding="utf-8") as f:
        f.write(line + "\n")


def require_root():
    if os.geteuid() != 0:
        print("ERROR: Run as root (use sudo).")
        sys.exit(1)


def load_config(path: str) -> Dict[str, Any]:
    with open(path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def parse_rules(cfg: Dict[str, Any]) -> List[Rule]:
    rules = []
    for r in cfg.get("rules", []):
        rules.append(
            Rule(
                name=str(r.get("name", "unnamed")),
                port=int(r["port"]),
                protocol=str(r.get("protocol", "tcp")).lower(),
                action=str(r.get("action", "accept")).lower(),
                source=str(r.get("source", "any")),
            )
        )
    return rules


def normalize_policy(p: str) -> str:
    p = p.lower()
    if p not in ("accept", "drop", "reject"):
        raise ValueError(f"Invalid policy: {p}")
    return p.upper()


def iptables_save() -> str:
    return sh(["iptables-save"]).stdout


def iptables_restore(rules_blob: str) -> None:
    p = subprocess.run(["iptables-restore"], input=rules_blob, text=True, capture_output=True)
    if p.returncode != 0:
        raise RuntimeError(f"iptables-restore failed: {p.stderr.strip()}")


def backup_current(backup_dir: str) -> str:
    os.makedirs(backup_dir, exist_ok=True)
    ts = dt.datetime.utcnow().strftime("%Y%m%d-%H%M%S")
    path = os.path.join(backup_dir, f"firewall-{ts}.rules")
    with open(path, "w", encoding="utf-8") as f:
        f.write(iptables_save())
    return path


def build_iptables_restore_blob(policies: Dict[str, str], rules: List[Rule]) -> str:
    """
    Build an iptables-restore compatible ruleset for the filter table.
    We set default policies, apply a safe baseline, then apply user rules.
    """
    lines = []
    lines.append("*filter")

    lines.append(f":INPUT {policies['input']} [0:0]")
    lines.append(f":FORWARD {policies['forward']} [0:0]")
    lines.append(f":OUTPUT {policies['output']} [0:0]")

    # Baseline safety rules
    for parts in SAFE_BASELINE_RULES:
        lines.append(" ".join(parts))

    # Apply user rules
    for r in rules:
        action = "ACCEPT" if r.action == "accept" else ("DROP" if r.action == "drop" else "REJECT")
        proto = r.protocol
        if proto not in ("tcp", "udp"):
            raise ValueError(f"Unsupported protocol {proto} in rule {r.name}")

        # source handling
        if r.source == "any":
            src_parts = []
        elif r.source.startswith("!"):
            src_parts = ["!", "-s", r.source[1:]]
        else:
            src_parts = ["-s", r.source]

        # Build: -A INPUT -p tcp --dport 22 [source] -j ACCEPT
        parts = ["-A", "INPUT", "-p", proto] + src_parts + ["--dport", str(r.port), "-j", action]
        lines.append(" ".join(parts))

    lines.append("COMMIT")
    return "\n".join(lines) + "\n"


def validate_applied(cfg: Dict[str, Any], rules: List[Rule]) -> (bool, str):
    """
    Basic validation:
    - default policies match
    - required ports are present in INPUT chain
    """
    # Check policies
    out = sh(["iptables", "-S"]).stdout

    desired = cfg.get("default_policy", {})
    try:
        want_in = normalize_policy(desired.get("input", "drop"))
        want_fwd = normalize_policy(desired.get("forward", "drop"))
        want_out = normalize_policy(desired.get("output", "accept"))
    except Exception as e:
        return False, f"Invalid default policy in config: {e}"

    if f"-P INPUT {want_in}" not in out:
        return False, f"Validation failed: INPUT policy is not {want_in}"
    if f"-P FORWARD {want_fwd}" not in out:
        return False, f"Validation failed: FORWARD policy is not {want_fwd}"
    if f"-P OUTPUT {want_out}" not in out:
        return False, f"Validation failed: OUTPUT policy is not {want_out}"

    # Always preserve SSH access rule (port 22 tcp ACCEPT somewhere)
    if "--dport 22" not in out or "-j ACCEPT" not in out:
        return False, "Validation failed: SSH (tcp/22 ACCEPT) rule missing"

    # Validate each configured ACCEPT rule exists (simple check)
    for r in rules:
        if r.action != "accept":
            continue
        needle = f"--dport {r.port} -j ACCEPT"
        if needle not in out:
            return False, f"Validation failed: missing ACCEPT rule for port {r.port}"

    return True, "Validation OK"


def prompt_confirm_or_timeout(seconds: int, log_file: str) -> bool:
    """
    Require user to type CONFIRM within N seconds.
    If not confirmed, we'll rollback automatically.
    """
    def handler(signum, frame):
        raise TimeoutError()

    signal.signal(signal.SIGALRM, handler)
    signal.alarm(seconds)
    try:
        ans = input(f"\nType CONFIRM within {seconds}s to keep the new firewall rules: ").strip()
        signal.alarm(0)
        return ans == "CONFIRM"
    except TimeoutError:
        log_line(log_file, "WARN", f"No confirmation within {seconds}s (auto-rollback).")
        return False


def main():
    require_root()

    ap = argparse.ArgumentParser(description="Declarative firewall manager (iptables)")
    ap.add_argument("--config", required=True, help="Path to rules.yaml")
    ap.add_argument("--dry-run", action="store_true", help="Show what would be applied")
    ap.add_argument("--apply", action="store_true", help="Apply the firewall rules")
    ap.add_argument("--no-confirm", action="store_true", help="Skip confirmation prompt (NOT recommended)")
    ap.add_argument("--rollback-seconds", type=int, default=60, help="Auto-rollback timer unless confirmed")
    ap.add_argument("--log-dir", default=LOG_DIR_DEFAULT)
    ap.add_argument("--backup-dir", default=BACKUP_DIR_DEFAULT)
    args = ap.parse_args()

    if not args.dry_run and not args.apply:
        print("ERROR: Choose --dry-run or --apply")
        sys.exit(1)

    os.makedirs(args.log_dir, exist_ok=True)
    log_file = os.path.join(args.log_dir, f"firewall-{dt.datetime.utcnow().strftime('%Y-%m-%d')}.log")

    cfg = load_config(args.config)
    rules = parse_rules(cfg)

    # Safety check: MUST include SSH accept on tcp/22
    has_ssh = any(r.action == "accept" and r.protocol == "tcp" and r.port == 22 for r in rules)
    if not has_ssh:
        log_line(log_file, "ERROR", "Config is missing required SSH allow rule (tcp/22 accept). Refusing to apply.")
        sys.exit(1)

    policies_cfg = cfg.get("default_policy", {})
    try:
        policies = {
            "input": normalize_policy(policies_cfg.get("input", "drop")),
            "forward": normalize_policy(policies_cfg.get("forward", "drop")),
            "output": normalize_policy(policies_cfg.get("output", "accept")),
        }
    except Exception as e:
        log_line(log_file, "ERROR", f"Invalid default_policy: {e}")
        sys.exit(1)

    restore_blob = build_iptables_restore_blob(policies, rules)

    if args.dry_run:
        log_line(log_file, "INFO", "DRY RUN: Below is the iptables-restore ruleset that would be applied:")
        print("\n" + restore_blob)
        sys.exit(0)

    # apply mode
    if args.apply:
        # Confirmation prompt
        if not args.no_confirm:
            ans = input("This will modify iptables rules. Type APPLY to continue: ").strip()
            if ans != "APPLY":
                log_line(log_file, "INFO", "User aborted.")
                sys.exit(0)

        # Backup current rules
        backup_path = backup_current(args.backup_dir)
        log_line(log_file, "INFO", f"Backup saved: {backup_path}")

        # Apply new rules
        log_line(log_file, "INFO", "Applying new firewall rules via iptables-restore...")
        try:
            iptables_restore(restore_blob)
        except Exception as e:
            log_line(log_file, "ERROR", f"Apply failed: {e}. Restoring backup...")
            iptables_restore(open(backup_path, "r", encoding="utf-8").read())
            sys.exit(1)

        # Validate
        ok, msg = validate_applied(cfg, rules)
        if not ok:
            log_line(log_file, "ERROR", msg)
            log_line(log_file, "WARN", "Validation failed. Rolling back immediately...")
            iptables_restore(open(backup_path, "r", encoding="utf-8").read())
            sys.exit(1)

        log_line(log_file, "INFO", msg)
        log_line(log_file, "INFO", f"Safety timer started: auto-rollback in {args.rollback_seconds}s unless confirmed.")

        # Auto rollback unless confirmed
        if args.no_confirm:
            log_line(log_file, "WARN", "no-confirm enabled: keeping rules without safety confirmation.")
            sys.exit(0)

        keep = prompt_confirm_or_timeout(args.rollback_seconds, log_file)
        if keep:
            log_line(log_file, "INFO", "Confirmed. Keeping new firewall rules.")
            sys.exit(0)
        else:
            log_line(log_file, "WARN", "Rolling back to previous firewall rules...")
            iptables_restore(open(backup_path, "r", encoding="utf-8").read())
            log_line(log_file, "INFO", "Rollback complete.")
            sys.exit(1)


if __name__ == "__main__":
    main()
