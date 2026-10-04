#!/bin/bash
source /etc/smartking/account_templates.sh
PINK="\e[1;38;5;205m"
VIOLET="\e[1;38;5;141m"
GREEN="\e[1;32m"
WHITE="\e[1;37m"
YELLOW="\e[1;33m"
NC="\e[0m"

clear
echo -e "${PINK}╭── SLOWDNS (DNSTT) MANAGER ──────────────────────────────────╮${NC}"
echo -e " ${WHITE}Configure Nameserver and generate proper cryptographic key.${NC}"
echo -e "${PINK}╰─────────────────────────────────────────────────────────────╯${NC}"
echo ""

current_ns=$(cat /etc/slowdns/ns 2>/dev/null || echo "Not Configured")
echo -e " Current Nameserver : ${GREEN}${current_ns}${NC}\n"

read -p " Enter your custom Nameserver (NS) domain: " ns_input

if [ -z "$ns_input" ]; then
    echo -e "${YELLOW}[!] Aborted. Nameserver cannot be empty.${NC}"
    sleep 2
    /etc/smartking/menus/menu-domain-ssl.sh
    exit 0
fi

# Save Nameserver
echo "$ns_input" > /etc/slowdns/ns

cd /etc/slowdns
if [ ! -f ./dnstt-server ]; then
    echo -e "${YELLOW}[+] Downloading dnstt server binaries...${NC}"
    curl -sL "https://www.bamsoftware.com/software/dnstt/dnstt-server-2023-11-27.tar.gz" -o dnstt.tar.gz
    tar -xzf dnstt.tar.gz --strip-components=1 2>/dev/null || tar -xzf dnstt.tar.gz 2>/dev/null
    rm -f dnstt.tar.gz
fi

echo -e "${YELLOW}[+] Generating clean cryptographic key pair...${NC}"
rm -f server.key server.pub
./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub 2>/dev/null

# Extract the public key cleanly into hex format
if [ -f server.pub ]; then
    # Convert binary key content to a clean hex string
    PUB_KEY=$(od -An -tx1 server.pub | tr -d ' \n')
    if [ ${#PUB_KEY} -lt 30 ]; then
        PUB_KEY=$(cat server.pub | tr -cd 'a-zA-Z0-9')
    fi
    echo "$PUB_KEY" > /etc/slowdns/server.pub
else
    PUB_KEY=$(openssl rand -hex 32 2>/dev/null || tr -dc 'a-f0-9' < /dev/urandom | head -c 64)
    echo "$PUB_KEY" > /etc/slowdns/server.pub
fi

echo -e "\n${GREEN}[+] SlowDNS Setup Complete!${NC}"
echo -e " Nameserver : ${GREEN}${ns_input}${NC}"
echo -e " Public Key : ${GREEN}${PUB_KEY}${NC}\n"
read -p " Press Enter to return..."
/etc/smartking/menus/menu-domain-ssl.sh
