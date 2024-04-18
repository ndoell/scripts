## Services Description

This setup includes various services configured to work together for effective subdomain enumeration, vulnerability scanning, and data analysis:

### Subfinder
- **Image:** `projectdiscovery/subfinder`
- **Purpose:** Discovers subdomains using the provided list of root domains from `/setup/wildcards`.
- **Output:** Subdomains are saved to `/data/subfinder.subs`.

### Findomain
- **Image:** `edu4rdshl/findomain`
- **Purpose:** Performs fast subdomain scanning across multiple top-level domains.
- **Output:** Subdomain results are outputted to `/data/findomain.subs`.

### Assetfinder
- **Image:** `recon/assetfinder`
- **Purpose:** Gathers subdomains from various public sources to aid in reconnaissance.
- **Output:** Data is typically saved within the service's specific output directory.

### Recon
- **Image:** `recon/subcollector`
- **Purpose:** Integrates data from `subfinder`, `findomain`, and `assetfinder`, performing additional data processing.
- **Dependencies:** Executes after the successful completion of the linked subdomain discovery services.
- **Output:** Aggregated and processed data is stored at `/data/`.

### Katana
- **Image:** `projectdiscovery/katana:latest`
- **Purpose:** Processes the list of combined hosts for further analysis and data collection.
- **Output:** Scan results are documented in `/data/katana.crawl`.

### Crawl
- **Image:** `recon/crawlcollector`
- **Purpose:** Performs deep crawling based on the data obtained from `katana`.
- **Dependencies:** Only starts after `katana` has successfully completed.
- **Output:** Detailed crawling results are stored in `/data/`.

### Trufflehog
- **Image:** `recon/trufflehog`
- **Purpose:** Scans file systems for secrets and sensitive information by looking for high entropy strings.
- **Output:** Results from the analysis are directed to `/loot/trufflehog.loot`.

### Semgrep
- **Image:** `semgrep/semgrep`
- **Purpose:** Conducts static code analysis to find bugs and security vulnerabilities.
- **Output:** Findings are formatted in SARIF and saved at `/loot/semgrep.sarif`.

### NPM Dependencies
- **Image:** `recon/npm_dependencies`
- **Purpose:** Analyzes NPM package dependencies to uncover possible security issues.
- **Output:** Results from the analysis script are directed to `/loot/npm_dependencies.loot`.
