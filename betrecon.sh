#!/bin/bash
# TOOLNAME: Betrecon
# Author: BlackBet | Funbinet Ops
# Version: 1.0

RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; CYAN="\e[36m"; BLUE="\e[34m"; MAGENTA="\e[35m"; RESET="\e[0m"

banner() {
cat << "EOF"
#    ██████╗ ███████╗████████╗██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗
#    ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║
#    ██████╔╝█████╗     ██║   ██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║
#    ██╔══██╗██╔══╝     ██║   ██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║
#    ██████╔╝███████╗   ██║   ██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║
#    ╚═════╝ ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝
EOF
}

TOOLNAME="Betrecon"
WORKDIR="$HOME/Goods/BetRecon"
FILES_DIR="$WORKDIR/files"
mkdir -p "$FILES_DIR"
get_timestamp() { echo -e "${YELLOW}$(date '+%Y-%m-%d:%H:%M:%S:%Z')${RESET}"; }
ts_simple() { date '+%Y%m%dT%H%M%S'; }
pause() { read -rp "$(printf "${GREEN}[${TOOLNAME}]::[Next]:${RESET} Press Enter to continue ${YELLOW}(or Ctrl+C to exit)${RESET}\n ")" _; }

is_valid_ip() {
    [[ $1 =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}(/([0-9]|[1-2][0-9]|3[0-2]))?$ ]]
}

is_valid_domain() {
    [[ $1 =~ ^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,63}$ ]]
}

is_valid_ports() {
    [[ $1 =~ ^[0-9,\-]+$ ]]
}

check_dependencies() {
    echo -e "\n${CYAN}[?]::[Checking Dependencies]${RESET}\n"
    DEPS=("whois" "dig" "nslookup" "theHarvester" "sublist3r" "nmap" "masscan" "traceroute" "sslscan" "whatweb" "httpx" "nikto" "dirsearch" "gobuster" "whatwaf")
    MIS=()
    for dep in "${DEPS[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo -e "${RED}[!]::[$dep]: Not Found${RESET}"
            MIS+=("$dep")
        else
            echo -e "${GREEN}[✔]::[$dep]: Found${RESET}"
        fi
    done
    if [ "${#MIS[@]}" -gt 0 ]; then
        echo -e "\n${YELLOW}[+]::[Installing Missing]${RESET}\n"
        for m in "${MIS[@]}"; do
            echo -e "${BLUE}[-]::[${m}]: Installing${RESET}"
            sudo apt-get update -qq
            sudo apt-get install -y "$m" &>/dev/null && echo -e "${GREEN}[✔]::[${m}]: Done${RESET}" || echo -e "${RED}[✖]::[${m}]: Install Failed${RESET}"
        done
    fi
    echo ""
}

save_result() {
    local tool="$1"
    local target="$2"
    local content_file="$3"
    local safe_target
    safe_target="${target//\//_}"
    local outfile="$FILES_DIR/${TOOLNAME}_${tool}_${safe_target}_$(ts_simple).txt"
    printf '%s\n' "[$(date '+%Y-%m-%d %H:%M:%S')] $TOOLNAME | $tool | $target" > "$outfile"
    cat "$content_file" >> "$outfile"
    echo -e "${GREEN}[${TOOLNAME}]::[Results Saved]:${RESET} ${CYAN}${outfile}${RESET}"
    rm -f "$content_file"
}

run_theharvester() {
    prompt="$(printf '%b' "${BLUE}[${TOOLNAME}]::[theHarvester - Target Domain]: ${RESET}")"
    read -rp "$prompt" target
    target="${target:-}"
    if ! is_valid_domain "$target"; then
        echo -e "${RED}[!]::[Invalid domain: ${target}]${RESET}"
        return
    fi
    tmp=$(mktemp)
    echo -e "${CYAN}[${TOOLNAME}]::[theHarvester]: Running passive enumeration..${RESET}"
    theHarvester -d "$target" -b all > "$tmp" 2>&1 || true
    save_result "theHarvester" "$target" "$tmp"
}

run_whois() {
    prompt="$(printf '%b' "${BLUE}[${TOOLNAME}]::[whois - Target Domain/IP]: ${RESET}")"
    read -rp "$prompt" target
    target="${target:-}"
    if ! is_valid_domain "$target" && ! is_valid_ip "$target"; then
        echo -e "${RED}[!]::[Invalid domain/IP: ${target}]${RESET}"
        return
    fi
    tmp=$(mktemp)
    echo -e "${CYAN}[${TOOLNAME}]::[whois]: Querying whois..${RESET}"
    whois "$target" > "$tmp" 2>&1 || true
    save_result "whois" "$target" "$tmp"
}

run_dig() {
    prompt="$(printf '%b' "${BLUE}[${TOOLNAME}]::[dig - Domain]: ${RESET}")"
    read -rp "$prompt" target
    target="${target:-}"
    if ! is_valid_domain "$target"; then
        echo -e "${RED}[!]::[Invalid domain: ${target}]${RESET}"
        return
    fi
    tmp=$(mktemp)
    echo -e "${CYAN}[${TOOLNAME}]::[dig]: Resolving DNS records..${RESET}"
    dig ANY "$target" +noall +answer > "$tmp" 2>&1 || true
    save_result "dig" "$target" "$tmp"
}

run_nslookup() {
    prompt="$(printf '%b' "${BLUE}[${TOOLNAME}]::[nslookup - Domain]: ${RESET}")"
    read -rp "$prompt" target
    target="${target:-}"
    if ! is_valid_domain "$target"; then
        echo -e "${RED}[!]::[Invalid domain: ${target}]${RESET}"
        return
    fi
    tmp=$(mktemp)
    echo -e "${CYAN}[${TOOLNAME}]::[nslookup]: Running lookup..${RESET}"
    nslookup "$target" > "$tmp" 2>&1 || true
    save_result "nslookup" "$target" "$tmp"
}

run_sublist3r() {
    prompt="$(printf '%b' "${BLUE}[${TOOLNAME}]::[sublist3r - Domain]: ${RESET}")"
    read -rp "$prompt" target
    target="${target:-}"
    if ! is_valid_domain "$target"; then
        echo -e "${RED}[!]::[Invalid domain: ${target}]${RESET}"
        return
    fi
    tmp=$(mktemp)
    echo -e "${CYAN}[${TOOLNAME}]::[sublist3r]: Enumerating subdomains..${RESET}"
    sublist3r -d "$target" -o "$tmp" >/dev/null 2>&1 || true
    save_result "sublist3r" "$target" "$tmp"
}

run_nmap() {
    prompt_target="$(printf '%b' "${BLUE}[${TOOLNAME}]::[nmap - Target IP/Range]: ${RESET}")"
    read -rp "$prompt_target" target
    target="${target:-}"
    if [ -z "$target" ]; then
        echo -e "${RED}[!]::[No target provided. Aborting nmap run]${RESET}"
        return
    fi

    prompt_ports="$(printf '%b' "${BLUE}[${TOOLNAME}]::[nmap - Ports (e.g. 1-65535 or 80,443)]: ${RESET}")"
    read -rp "$prompt_ports" ports
    ports="${ports:-1-65535}"

    if ! is_valid_ports "$ports"; then
        echo -e "${RED}[!]::[Invalid ports format: ${ports}]${RESET}"
        return
    fi

    tmp=$(mktemp)
    echo -e "${CYAN}[${TOOLNAME}]::[nmap]: Running port/service scan on ${target} (ports: ${ports})..${RESET}"
    nmap -sV -p "${ports}" "$target" -oN "$tmp" >/dev/null 2>&1 || true
    save_result "nmap" "$target" "$tmp"
}

run_masscan() {
    prompt_target="$(printf '%b' "${BLUE}[${TOOLNAME}]::[masscan - Target IP/Range]: ${RESET}")"
    read -rp "$prompt_target" target
    target="${target:-}"
    if [ -z "$target" ]; then
        echo -e "${RED}[!]::[No target provided. Aborting masscan run]${RESET}"
        return
    fi

    prompt_ports="$(printf '%b' "${BLUE}[${TOOLNAME}]::[masscan - Ports (e.g., 1-65535)]: ${RESET}")"
    read -rp "$prompt_ports" ports
    ports="${ports:-1-65535}"

    if ! is_valid_ports "$ports"; then
        echo -e "${RED}[!]::[Invalid ports format: ${ports}]${RESET}"
        return
    fi

    tmp=$(mktemp)
    echo -e "${CYAN}[${TOOLNAME}]::[masscan]: Fast port discovery on ${target} (ports: ${ports})..${RESET}"
    sudo masscan "$target" -p"${ports}" --rate 1000 -oL "$tmp" >/dev/null 2>&1 || true
    save_result "masscan" "$target" "$tmp"
}

run_traceroute() {
    prompt_target="$(printf '%b' "${BLUE}[${TOOLNAME}]::[traceroute - Host/IP]: ${RESET}")"
    read -rp "$prompt_target" target
    target="${target:-}"
    if [ -z "$target" ]; then
        echo -e "${RED}[!]::[No target provided. Aborting traceroute]${RESET}"
        return
    fi
    tmp=$(mktemp)
    echo -e "${CYAN}[${TOOLNAME}]::[traceroute]: Tracing route for ${target}..${RESET}"
    traceroute "$target" > "$tmp" 2>&1 || true
    save_result "traceroute" "$target" "$tmp"
}

run_sslscan() {
    prompt_target="$(printf '%b' "${BLUE}[${TOOLNAME}]::[sslscan - Host:Port (host:443)]: ${RESET}")"
    read -rp "$prompt_target" target
    target="${target:-}"
    if [[ ! "$target" =~ : ]]; then
        echo -e "${YELLOW}[~]::[No port provided, defaulting to :443]${RESET}"
        target="${target}:443"
    fi
    tmp=$(mktemp)
    echo -e "${CYAN}[${TOOLNAME}]::[sslscan]: Scanning TLS for ${target}..${RESET}"
    sslscan "$target" > "$tmp" 2>&1 || true
    save_result "sslscan" "$target" "$tmp"
}

run_whatweb() {
    prompt_target="$(printf '%b' "${BLUE}[${TOOLNAME}]::[whatweb - URL]: ${RESET}")"
    read -rp "$prompt_target" target
    target="${target:-}"
    if [ -z "$target" ]; then
        echo -e "${RED}[!]::[No URL provided. Aborting whatweb]${RESET}"
        return
    fi
    tmp=$(mktemp)
    echo -e "${CYAN}[${TOOLNAME}]::[whatweb]: Detecting tech for ${target}..${RESET}"
    whatweb -v "$target" > "$tmp" 2>&1 || true
    save_result "whatweb" "$target" "$tmp"
}

run_httpx() {
    prompt_target="$(printf '%b' "${BLUE}[${TOOLNAME}]::[httpx - Domain/URL (e.g., example.com)]: ${RESET}")"
    read -rp "$prompt_target" target
    target="${target:-}"
    if [ -z "$target" ]; then
        echo -e "${RED}[!]::[No target provided. Aborting httpx]${RESET}"
        return
    fi
    tmp=$(mktemp)
    echo -e "${CYAN}[${TOOLNAME}]::[httpx]: Probing ${target}..${RESET}"
    httpx -silent -l <(printf "%s\n" "$target") -json > "$tmp" 2>&1 || true
    save_result "httpx" "$target" "$tmp"
}

run_nikto() {
    prompt_target="$(printf '%b' "${BLUE}[${TOOLNAME}]::[nikto - URL (http://host)]: ${RESET}")"
    read -rp "$prompt_target" target
    target="${target:-}"
    if [[ ! "$target" =~ ^https?:// ]]; then
        echo -e "${YELLOW}[~]::[No scheme provided; defaulting to http://]${RESET}"
        target="http://${target}"
    fi
    tmp=$(mktemp)
    echo -e "${CYAN}[${TOOLNAME}]::[nikto]: Scanning ${target}..${RESET}"
    nikto -h "$target" -output "$tmp" >/dev/null 2>&1 || true
    save_result "nikto" "$target" "$tmp"
}

run_dirsearch() {
    prompt_target="$(printf '%b' "${BLUE}[${TOOLNAME}]::[dirsearch - URL]: ${RESET}")"
    read -rp "$prompt_target" target
    prompt_wl="$(printf '%b' "${BLUE}[${TOOLNAME}]::[dirsearch - Wordlist path]: ${RESET}")"
    read -rp "$prompt_wl" wlist
    target="${target:-}"
    wlist="${wlist:-/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt}"
    if [ ! -f "$wlist" ]; then
        echo -e "${YELLOW}[~]::[Wordlist not found, using default fallback]${RESET}"
        wlist="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
    fi
    if [ -z "$target" ]; then
        echo -e "${RED}[!]::[No URL provided. Aborting dirsearch]${RESET}"
        return
    fi
    tmp=$(mktemp)
    echo -e "${CYAN}[${TOOLNAME}]::[dirsearch]: Enumerating ${target} with ${wlist}..${RESET}"
    python3 /usr/bin/dirsearch -u "$target" -w "$wlist" -e php,html,js,txt -o "$tmp" >/dev/null 2>&1 || true
    save_result "dirsearch" "$target" "$tmp"
}

run_gobuster() {
    prompt_target="$(printf '%b' "${BLUE}[${TOOLNAME}]::[gobuster - URL]: ${RESET}")"
    read -rp "$prompt_target" target
    prompt_wl="$(printf '%b' "${BLUE}[${TOOLNAME}]::[gobuster - Wordlist path]: ${RESET}")"
    read -rp "$prompt_wl" wlist
    target="${target:-}"
    wlist="${wlist:-/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt}"
    if [ ! -f "$wlist" ]; then
        echo -e "${YELLOW}[~]::[Wordlist not found, using default fallback]${RESET}"
        wlist="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
    fi
    if [ -z "$target" ]; then
        echo -e "${RED}[!]::[No URL provided. Aborting gobuster]${RESET}"
        return
    fi
    tmp=$(mktemp)
    echo -e "${CYAN}[${TOOLNAME}]::[gobuster]: Brute forcing ${target} with ${wlist}..${RESET}"
    gobuster dir -u "$target" -w "$wlist" -o "$tmp" >/dev/null 2>&1 || true
    save_result "gobuster" "$target" "$tmp"
}

passive_menu() {
    while true; do
        echo -e "\n${BLUE}     [ PASSIVE RECON ]${RESET}\n"
        echo -e "${YELLOW}     [1]:: theHarvester${RESET}"
        echo -e "${YELLOW}     [2]:: whois${RESET}"
        echo -e "${YELLOW}     [3]:: dig${RESET}"
        echo -e "${YELLOW}     [4]:: nslookup${RESET}"
        echo -e "${YELLOW}     [5]:: sublist3r${RESET}"
        echo -e "${YELLOW}     [6]:: Back to Main Menu${RESET}\n"
        prompt_opt="$(printf '%b' "${CYAN}[${TOOLNAME}]::[SELECT OPTION]: ${RESET}")"
        read -rp "$prompt_opt" opt
        case $opt in
            1) run_theharvester ;;
            2) run_whois ;;
            3) run_dig ;;
            4) run_nslookup ;;
            5) run_sublist3r ;;
            6) break ;;
            *) echo -e "${RED}[!]::[Invalid Option]${RESET}" ;;
        esac
        pause
    done
}

active_menu() {
    while true; do
        echo -e "\n${BLUE}     [ ACTIVE RECON ]${RESET}\n"
        echo -e "${YELLOW}     [1]:: nmap${RESET}"
        echo -e "${YELLOW}     [2]:: masscan${RESET}"
        echo -e "${YELLOW}     [3]:: traceroute${RESET}"
        echo -e "${YELLOW}     [4]:: sslscan${RESET}"
        echo -e "${YELLOW}     [5]:: whatweb${RESET}"
        echo -e "${YELLOW}     [6]:: Back to Main Menu${RESET}\n"
        prompt_opt="$(printf '%b' "${CYAN}[${TOOLNAME}]::[SELECT OPTION]: ${RESET}")"
        read -rp "$prompt_opt" opt
        case $opt in
            1) run_nmap ;;
            2) run_masscan ;;
            3) run_traceroute ;;
            4) run_sslscan ;;
            5) run_whatweb ;;
            6) break ;;
            *) echo -e "${RED}[!]::[Invalid Option]${RESET}" ;;
        esac
        pause
    done
}

web_menu() {
    while true; do
        echo -e "\n${BLUE}     [ WEB ANALYSIS ]${RESET}\n"
        echo -e "${YELLOW}     [1]:: httpx${RESET}"
        echo -e "${YELLOW}     [2]:: nikto${RESET}"
        echo -e "${YELLOW}     [3]:: dirsearch${RESET}"
        echo -e "${YELLOW}     [4]:: gobuster${RESET}"
        echo -e "${YELLOW}     [5]:: whatweb${RESET}"
        echo -e "${YELLOW}     [6]:: Back to Main Menu${RESET}\n"
        prompt_opt="$(printf '%b' "${CYAN}[${TOOLNAME}]::[SELECT OPTION]: ${RESET}")"
        read -rp "$prompt_opt" opt
        case $opt in
            1) run_httpx ;;
            2) run_nikto ;;
            3) run_dirsearch ;;
            4) run_gobuster ;;
            5) run_whatweb ;;
            6) break ;;
            *) echo -e "${RED}[!]::[Invalid Option]${RESET}" ;;
        esac
        pause
    done
}

main_menu() {
    check_dependencies
    clear
    echo -e "${YELLOW}$(banner)${RESET}"
    echo -e "\n${CYAN}[=]::[${TOOLNAME}]: Starting..${RESET}"
    NOW=$(get_timestamp)
    echo -e "${YELLOW}[${TOOLNAME}]::[${NOW}]:[EAT]${RESET}\n"
    while true; do
        echo -e "${BLUE}     [ MAIN MENU ]${RESET}\n"
        echo -e "${YELLOW}     [1]:: Passive Recon${RESET}"
        echo -e "${YELLOW}     [2]:: Active Recon${RESET}"
        echo -e "${YELLOW}     [3]:: Web Analysis${RESET}"
        echo -e "${YELLOW}     [4]:: Exit${RESET}\n"
        prompt_choice="$(printf '%b' "${CYAN}[${TOOLNAME}]::[SELECT OPTION]: ${RESET}")"
        read -rp "$prompt_choice" choice
        case $choice in
            1) passive_menu ;;
            2) active_menu ;;
            3) web_menu ;;
            4)
                echo -e "\n${RED}[#]::[${TOOLNAME}]: Exiting..${RESET}"
                NOW=$(get_timestamp)
                echo -e "${YELLOW}[${TOOLNAME}]::[${NOW}]:[EAT]${RESET}"
                echo -e "${RED}[${TOOLNAME}]:: Bye !!${RESET}"
                exit 0 ;;
            *) echo -e "${RED}[!]::[Invalid Option]${RESET}" ;;
        esac
    done
}

main_menu

