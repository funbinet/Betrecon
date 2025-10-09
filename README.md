![banner](banner.png)

# 🧠 BetRecon — The Ultimate Terminal Recon Framework

**Author:** BlackBet | Funbinet Ops  
---

## Overview

BetRecon is a terminal-first reconnaissance framework for penetration testers and red‑teamers.  
It runs on Kali Linux and other Debian/Ubuntu-based systems. The tool is menu-driven, colorized, and stores every tool's output in structured files — the terminal displays only formatted status messages.

Divisions:
- **Passive Recon** — non-intrusive OSINT (whois, dig, nslookup, theHarvester, sublist3r)  
- **Active Recon** — network/service discovery (nmap, masscan, traceroute, sslscan, httpx)  
- **Web Analysis** — web fingerprinting & surface mapping (httpx, nikto, dirsearch, gobuster, whatweb, whatwaf)

---

## What this README contains (MVP)
- Full installation instructions (apt/snap/git/manual)  
- How to obtain non‑apt dependencies (httpx, whatwaf, others)  
- Usage examples, file paths, and output locations  
- Fallback commands and recovery steps if cloning/install fails  
- Troubleshooting, validation rules, and security/legal notice

---

## Repo layout (recommended)
```
BetRecon/
├─ betrecon.sh
├─ banner.png
├─ README.md
└─ files/      # runtime output saved here
```

---

## Quick Install & Run

```bash
git clone https://github.com/<your-username>/BetRecon.git
cd BetRecon
chmod +x betrecon.sh
sudo ./betrecon.sh
```

If you don't have git:
```bash
sudo apt update
sudo apt install git -y
git clone https://github.com/<your-username>/BetRecon.git
```

---

## Dependency handling (automatic + manual)

BetRecon attempts to auto-detect and install missing dependencies. It uses `apt` where possible, but several modern tools are not packaged in apt and require alternative installs.

### Automatic (what the script does)
- Checks binaries listed in the script (whois, dig, nmap, masscan, httpx, etc.)
- For missing `apt`-packaged tools: runs `sudo apt-get install -y <tool>`
- For known non-apt tools (e.g., `httpx`, `whatwaf`) the script can be extended to:
  - call `snap install httpx` and symlink `/snap/bin/httpx` → `/usr/local/bin/httpx`
  - `git clone` and `pip3 install -r requirements.txt` for Python-based tools (WhatWaf)

### Manual installs (fallbacks)

**httpx (recommended via snap):**
```bash
sudo apt update
sudo apt install snapd -y
sudo snap install httpx
sudo ln -s /snap/bin/httpx /usr/local/bin/httpx
httpx -version
```

**WhatWaf (manual GitHub install):**
```bash
sudo mkdir -p /opt
cd /opt
sudo git clone https://github.com/Ekultek/WhatWaf.git
cd WhatWaf
sudo pip3 install -r requirements.txt
sudo ln -s /opt/WhatWaf/whatwaf.py /usr/local/bin/whatwaf
whatwaf -h
```

**Dirsearch, Gobuster, Nikto (if missing):**
```bash
sudo apt update
sudo apt install nikto gobuster -y
# dirsearch may be under /usr/bin/dirsearch or install via pip:
sudo pip3 install dirsearch
```

---

## Usage (detailed)

Run the script:
```bash
sudo bash betrecon.sh
```

Main menu appears (examples):
```
[1]:: Passive Recon
[2]:: Active Recon
[3]:: Web Analysis
[4]:: Exit
```

Select a division, then pick a tool. Each tool will prompt for the appropriate vector (domain, IP, URL, ports, wordlist path, etc.). The interface validates inputs and rejects obvious bad formats (e.g., non-numeric ports).

### Output files
- All tool outputs saved to: `~/Goods/BetRecon/files/`  
- Filenames follow:
```
BetRecon_<tool>_<target>_YYYYMMDDTHHMMSS.txt
```
- The terminal shows status messages and the saved results path only — raw tool output is kept in the files.

---

## Examples

**Nmap**
```
[2] Active Recon → [1] nmap
Prompt: Target IP/Range: 192.168.1.0/24
Prompt: Ports: 22,80,443
Output: [Results Saved]: ~/Goods/BetRecon/files/BetRecon_nmap_192.168.1.0_20251009T063341.txt
```

**httpx (quick host probe)**
```
[3] Web Analysis → [1] httpx
Prompt: Domain/URL: example.com
Output saved as JSON lines in results file.
```

---

## Validation & Safety (what script enforces)

- Domain validation (regex) for domain-based tools.
- IP/CIDR basic validation for network tools.
- Ports validation — only digits, commas, and dashes allowed; defaults to `1-65535` when empty.
- URL handling: `nikto`/`dirsearch` will default to `http://` when scheme missing.
- Script **never** prints raw external command outputs to the terminal — outputs are redirected to temp files and saved.

---

## Troubleshooting & Fallbacks

**If `sudo apt install <tool>` fails:**
- Check network and repository:
```bash
sudo apt update
sudo apt install -y <tool>
```
- If apt repo signature errors appear (OpenPGP), clean apt lists:
```bash
sudo rm -rf /var/lib/apt/lists/*
sudo apt update
```
- Use manual install per "Manual installs" above.

**If `snap install httpx` fails:**
```bash
sudo apt install snapd -y
sudo snap install httpx
sudo ln -s /snap/bin/httpx /usr/local/bin/httpx
```

**If git clone fails (HTTPS blocked):**
- Try `git clone git@github.com:<user>/BetRecon.git` (SSH) after adding your SSH key to GitHub.
- Or download zip from GitHub Releases page and extract.

**If script reports `command not found` after install:**
- Ensure `/usr/local/bin` and `/snap/bin` are in your PATH when running as root or via sudo. Example:
```bash
sudo ln -s /snap/bin/httpx /usr/local/bin/httpx
export PATH=$PATH:/usr/local/bin:/snap/bin
```

---

## Hardening & Production Tips

- Prefer installing tools as a non-root user and only invoke script with `sudo` for operations that require elevated privileges (masscan, nmap with raw-socket options).
- If you run BetRecon on multiple environments, pin tool versions or use containerized environments (Docker) for reproducible results.
- Consider disabling auto-install behavior in the script for production — instead, document and let admins review installs.

---

## Contributing & Extending

Want to add a new tool? Follow these steps:
1. Add a `run_<tool>()` function to `betrecon.sh` mirroring existing patterns.  
2. Add the new entry into the appropriate menu function (`passive_menu`, `active_menu`, or `web_menu`).  
3. Ensure input validation and call `save_result "<tool>" "$target" "$tmp"`.

Example skeleton:
```bash
run_example() {
  prompt="$(printf '%b' "${BLUE}[${TOOLNAME}]::[example - Target]: ${RESET}")"
  read -rp "$prompt" target
  # validation...
  tmp=$(mktemp)
  example_cmd "$target" > "$tmp" 2>&1 || true
  save_result "example" "$target" "$tmp"
}
```

---

## Legal & Responsible Use

BetRecon is for authorized security assessments, learning, and research. Scanning or attacking systems without permission is illegal. Always obtain written authorization.

---

## License

Choose a license appropriate to your project (MIT, Apache-2.0, etc.). Example:
```
MIT License
```

---

## Contact / Credits

- **Maintainer:** BlackBet | Funbinet Ops  
- **Recommend reading:** Nmap reference guide, OWASP testing guide, ProjectDiscovery docs.

