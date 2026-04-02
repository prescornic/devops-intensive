import json
import datetime
from concurrent.futures import ThreadPoolExecutor
from colorama import Fore, Style, init
from utils.http_utils import test_http
from utils.dns_utils import test_dns

init(autoreset=True)

class NetworkTester:
    def __init__(self, config_path='config.json'):
        with open(config_path, 'r') as f:
            self.config = json.load(f)
        self.results = []
        self.settings = self.config.get('settings', {})
        self.timeout = self.settings.get('timeout', 5)
        self.retries = self.settings.get('retries', 0)

    def run_test(self, endpoint):
        last_result = None
        for _ in range(self.retries + 1):
            try:
                etype = endpoint['type']
                if etype in ['http', 'https']:
                    last_result = test_http(endpoint, self.timeout)
                elif etype == 'dns':
                    res = test_dns(endpoint['host'])
                    res.update({"url": endpoint['host'], "success": res['status'] == "success"})
                    last_result = res
                else:
                    last_result = {"url": endpoint.get('url', 'unknown'), "success": False, "error": f"Unsupported: {etype}"}

                if last_result.get('success'):
                    break
            except Exception as e:
                last_result = {"url": endpoint.get('url'), "success": False, "error": str(e)}
        
        self.print_result(last_result)
        return last_result

    def print_result(self, res):
        symbol = f"{Fore.GREEN}✓" if res.get('success') else f"{Fore.RED}✗"
        url = res.get('url', 'N/A')
        details = f"({res.get('time_ms', 0)}ms)"
        
        ssl_msg = ""
        if res.get('ssl') and res['ssl'].get('valid'):
            ssl_msg = f" - SSL expires: {res['ssl']['expires']}"
            if res['ssl']['alert']:
                ssl_msg += f" {Fore.YELLOW}(EXPIRING SOON)"

        print(f"{symbol} {Fore.WHITE}{url} {Style.DIM}{details}{ssl_msg}")

    def execute(self):
        print(f"\nNetwork Service Test Report - {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("="*50)
        
        with ThreadPoolExecutor(max_workers=5) as executor:
            self.results = list(executor.map(self.run_test, self.config['endpoints']))
        
        passed = sum(1 for r in self.results if r.get('success'))
        print(f"\nSummary: {passed} passed, {len(self.results) - passed} failed")
        
        with open('report.json', 'w') as f:
            json.dump({"timestamp": str(datetime.datetime.now().strftime('%Y-%m-%d %H:%M')), "results": self.results}, f, indent=4)

if __name__ == "__main__":
    tester = NetworkTester()
    tester.execute()