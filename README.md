# SECURITY-COMPOSE

## Overview
Project Recon is a suite of Docker-based tools designed for cybersecurity practitioners to automate the process of discovering and analyzing web assets. This Docker Compose setup orchestrates multiple services to perform subdomain enumeration, crawling, and vulnerability scanning.

For detailed description of [services](services.md).

## Getting Started

### Prerequisites
Ensure Docker and Docker Compose are installed on your system. You can download and install these tools from [Docker's official website](https://docker.com).

### Installation
To set up the project, follow these steps:
1. Clone the repository to your local machine:
   ```bash
   git clone https://github.com/10gen/security-compose.git
   ```
2. Navigate to the cloned directory:
    ```bash
    cd security-compose/recon/
    ```

## How To Run
The effective flow would be to run:\
     `subdomain scan` -> `crawl sites` -> `static analysis`\
     AND/OR\
     `subdomain scan` -> `dynamic analysis` (Flow not available yet)

### Scope
Update `/setup/wildcards` to any number root domain you are testing.

### Static Analysis flow
- **Subdomain Search:** 
  - Runs services `subfinder`, `findomain` and `assetfinder`.
  - Combines results into `/data/combined.subs` and `/data/combined.hosts`.
    - Both lists are the same domains, the `combined.hosts` file has `https://` appended for passing to http tools such as `httpx`
    ```bash
    # Run Recon Service
    $ docker-compose up recon
    ```
- **Crawl:**
  - Runs service `katana`.
  - Additional crawlers to be added `gau`, `hakrawler` and `gospider`.
  - All crawled URLs are passed to `subjs` which reads all JS links found in the response and extracts them.
  - Finally `httpx` is ran to save every repsonse.
  - Note: The `crawl` service depends on a completed run of `recon`. 
    - IE: This service will kick off it's own recon scan.
    ```bash
    # Run Crawl Service
    $ docker-compose up crawl
    ```
- **Static Analysis:** 
  - Runs semgrep, trufflehog, npm dependency search on saved responses from `/data/httpxout/`
  - `docker-compose up trufflehog`: Creates `/loot/tufflehog.loot`
  - `docker-compose up semgrep`: Creates `/loot/semgrep.sarif`
  - `docker-compose up npm_dependencies`: Creates a list of all npm dependencies found in JS files. `/loot/npm_dependencies.loot`
    ```bash
    # Run Static Analysis Services
    $ docker-compose up trufflehog
    $ docker-compose up semgrep
    $ docker-compose up npm_dependencies
    ```

## Notifications

Slack notifications can be added upon completion of `recon` and `crawl`\
Rename `/setup/provider-config-example.yaml` to `/setup/provider-config.yaml`\
See [Project Discovery's Notify Project](https://github.com/projectdiscovery/notify?tab=readme-ov-file#provider-config) for additional information.


## To-Do
- [ ] Add amass
- [ ] Add gau
- [ ] Add hakrawler
- [ ] Add gospider
- [ ] Add Vuln Scanning
  - [ ] Nuclei
  - [ ] Nmap
