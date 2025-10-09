![banner](banner.png)


■ BetRecon — The Ultimate Reconnaissance
Framework
Author: BlackBet | Funbinet Ops
**Overview**
BetRecon is a **terminal-based reconnaissance framework** built for Kali Linux and UNIX systems.
It automates passive, active, and web-based reconnaissance using elite open-source tools.
### ■ Features
- Passive Recon (whois, dig, nslookup, theHarvester, sublist3r)
- Active Recon (nmap, masscan, traceroute, sslscan, httpx)
- Web Analysis (nikto, dirsearch, gobuster, whatweb, whatwaf)
---
### ■■ Installation
```bash
git clone https://github.com//BetRecon.git
cd BetRecon
chmod +x betrecon.sh
sudo ./betrecon.sh
```
If git not found:
```bash
sudo apt install git -y
```
---
### ■ Handling Non-APT Dependencies
**Install httpx (Snap):**
```bash
sudo apt install snapd -y
sudo snap install httpx
sudo ln -s /snap/bin/httpx /usr/local/bin/httpx
```
**Install WhatWaf manually:**
```bash
cd /opt
sudo git clone https://github.com/Ekultek/WhatWaf.git
cd WhatWaf
sudo pip3 install -r requirements.txt
sudo ln -s /opt/WhatWaf/whatwaf.py /usr/local/bin/whatwaf
```
---
### ■ Usage
```bash
sudo bash betrecon.sh
```
**Main Menu:**
```
[1] Passive Recon
[2] Active Recon
[3] Web Analysis
[4] Exit
```
Example workflow:
```bash
sudo bash betrecon.sh
[2] Active Recon
[1] nmap
Target IP: 192.168.1.0/24
Ports: 22,80,443
```
Results saved in output folder.
---
### ■ Troubleshooting
- Tool missing → `sudo apt install -y`
- Snap missing → `sudo apt install snapd -y`
- Permission issues → `chmod +x betrecon.sh`
- Stuck process → Press `Ctrl+C` and rerun
---
### ■■ Legal Disclaimer
BetRecon is for **authorized security testing only**.
Unauthorized use against third parties is illegal. You are responsible for your actions.
---
### ■■■ Credits
- **Author:** BlackBet | Funbinet Ops
- **Framework:** BetRecon BOL
- **Powered by:** ProjectDiscovery, Nmap, OWASP, Python Toolkit
> Reconnaissance is not about noise. It’s about knowing before acting.
