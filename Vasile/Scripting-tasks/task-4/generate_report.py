import json
import os
from datetime import datetime

def generate_html():
    report_file = 'report.json'
    
    if not os.path.exists(report_file):
        print(f"Error: {report_file} not found. Run network_tester.py first.")
        return

    with open(report_file, 'r') as f:
        data = json.load(f)

    results = data.get('results', [])
    timestamp = data.get('timestamp', 'Unknown')
    
    total = len(results)
    passed = sum(1 for r in results if r.get('success'))
    failed = total - passed
    pass_rate = (passed / total * 100) if total > 0 else 0

    html_content = f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Network Test Dashboard</title>
        <script src="https://cdn.tailwindcss.com"></script>
    </head>
    <body class="bg-gray-900 text-gray-100 font-sans p-8">
        <div class="max-w-6xl mx-auto">
            <header class="mb-10 flex justify-between items-end border-b border-gray-700 pb-6">
                <div>
                    <h1 class="text-4xl font-bold text-blue-400">Network Service Monitor</h1>
                    <p class="text-gray-400 mt-2">Report Generated: {timestamp}</p>
                </div>
                <div class="text-right">
                    <span class="text-5xl font-mono text-blue-500">{pass_rate:.0f}%</span>
                    <p class="text-xs uppercase tracking-widest text-gray-500">Success Rate</p>
                </div>
            </header>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
                <div class="bg-gray-800 p-6 rounded-xl border-l-4 border-blue-500">
                    <p class="text-gray-400 text-sm">Total Checks</p>
                    <p class="text-3xl font-bold">{total}</p>
                </div>
                <div class="bg-gray-800 p-6 rounded-xl border-l-4 border-green-500">
                    <p class="text-gray-400 text-sm">Passed</p>
                    <p class="text-3xl font-bold text-green-400">{passed}</p>
                </div>
                <div class="bg-gray-800 p-6 rounded-xl border-l-4 border-red-500">
                    <p class="text-gray-400 text-sm">Failed</p>
                    <p class="text-3xl font-bold text-red-400">{failed}</p>
                </div>
            </div>

            <div class="bg-gray-800 rounded-xl overflow-hidden shadow-2xl">
                <table class="w-full text-left">
                    <thead class="bg-gray-700 text-gray-300 uppercase text-xs">
                        <tr>
                            <th class="px-6 py-4">Status</th>
                            <th class="px-6 py-4">Endpoint / Host</th>
                            <th class="px-6 py-4">Response Time</th>
                            <th class="px-6 py-4">Details</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-700">
    """

    for res in results:
        status_bg = "bg-green-900/30 text-green-400" if res.get('success') else "bg-red-900/30 text-red-400"
        
        # Format the Details column
        details = ""
        if res.get('status_code'):
            details += f"Status: {res['status_code']} "
        if res.get('ssl') and res['ssl'].get('valid'):
            details += f"| SSL: {res['ssl']['expires']}"
        if res.get('error'):
            details = f"<span class='text-red-300 text-xs'>{res['error']}</span>"

        html_content += f"""
                        <tr class="hover:bg-gray-750 transition-colors">
                            <td class="px-6 py-4">
                                <span class="px-3 py-1 rounded-full text-xs font-bold {status_bg}">
                                    {"PASS" if res.get('success') else "FAIL"}
                                </span>
                            </td>
                            <td class="px-6 py-4 font-medium">{res.get('url')}</td>
                            <td class="px-6 py-4 font-mono text-blue-300">{res.get('time_ms', 'N/A')}ms</td>
                            <td class="px-6 py-4 text-sm text-gray-400 italic">{details}</td>
                        </tr>
        """

    html_content += """
                    </tbody>
                </table>
            </div>
        </div>
    </body>
    </html>
    """

    with open('report.html', 'w') as f:
        f.write(html_content)
    
    print(f"Done! Dashboard generated: {os.path.abspath('report.html')}")

if __name__ == "__main__":
    generate_html()