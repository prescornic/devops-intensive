#!/usr/bin/env python3
import json
import sys
from datetime import datetime

HTML_TEMPLATE = """<!doctype html>
<html>
<head>
  <meta charset="utf-8"/>
  <title>Network Tester Report</title>
  <style>
    body {{ font-family: Arial, sans-serif; margin: 24px; }}
    table {{ border-collapse: collapse; width: 100%; }}
    th, td {{ border: 1px solid #ddd; padding: 8px; }}
    th {{ background: #f2f2f2; }}
    .ok {{ color: green; font-weight: bold; }}
    .fail {{ color: red; font-weight: bold; }}
  </style>
</head>
<body>
<h2>Network Service Test Report</h2>
<p>Generated: {generated}</p>
<table>
  <thead>
    <tr>
      <th>Target</th>
      <th>Type</th>
      <th>OK</th>
      <th>Status</th>
      <th>Resp/DNS Time (ms)</th>
      <th>SSL Expiry</th>
      <th>Error</th>
    </tr>
  </thead>
  <tbody>
    {rows}
  </tbody>
</table>
</body>
</html>
"""

def main():
    if len(sys.argv) < 3:
        print("Usage: python3 generate_report.py <report.json> <output.html>")
        sys.exit(1)

    report_json = sys.argv[1]
    out_html = sys.argv[2]

    with open(report_json, "r", encoding="utf-8") as f:
        data = json.load(f)

    rows = []
    for r in data["results"]:
        ok = r.get("ok")
        ok_class = "ok" if ok else "fail"
        status = r.get("status_code") or ""
        t = r.get("response_time_ms") or r.get("dns_time_ms") or ""
        ssl_exp = r.get("ssl_not_after_utc") or ""
        err = r.get("error") or ""
        rows.append(f"<tr><td>{r.get('target')}</td><td>{r.get('type')}</td>"
                    f"<td class='{ok_class}'>{'YES' if ok else 'NO'}</td>"
                    f"<td>{status}</td><td>{t}</td><td>{ssl_exp}</td><td>{err}</td></tr>")

    html = HTML_TEMPLATE.format(
        generated=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        rows="\n".join(rows),
    )

    with open(out_html, "w", encoding="utf-8") as f:
        f.write(html)

    print(f"HTML report written to: {out_html}")

if __name__ == "__main__":
    main()
