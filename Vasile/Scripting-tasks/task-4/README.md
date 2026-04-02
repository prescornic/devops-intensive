# Network Service Tester

A modular Python-based utility to monitor the health of network endpoints. This tool supports HTTP/HTTPS status checks, SSL certificate expiration monitoring, and DNS resolution timing.

## Features

- **Multi-protocol Support**: Test HTTP, HTTPS, and DNS.
- **SSL Monitoring**: Detects certificate expiration and alerts if < 30 days remain.
- **Concurrent Testing**: Uses `ThreadPoolExecutor` for high-performance parallel checks.
- **Modular Architecture**: Logic split into `utils/` for easy scalability (e.g., adding gRPC).
- **Dual Reporting**:
  - **Console**: Real-time, color-coded output.
  - **Dashboard**: Clean HTML/Tailwind CSS report.
  - **Data**: Raw JSON output for CI/CD integration.

---

## Prerequisites

- **Python 3.9+**
- **Pip**

---

## Installation

1. **Clone the repository:**

2. **Create a Virtual Environment:**

   ```bash
   # macOS/Linux
   python3 -m venv venv
   source venv/bin/activate

   # Windows
   python -m venv venv
   .\venv\Scripts\activate
   ```

3. **Install Dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

## Usage

1. **Run the Network Tests**
   **Execute the main script to perform checks and generate the raw data:**
   ```bash
   python network_tester.py
   ```
2. **Generate the HTML Dashboard**
   **After running the tester, generate the visual report:**
   ```bash
   python generate_report.py
   ```
   **Open the resulting `report.html` in any web browser.**
   ```
