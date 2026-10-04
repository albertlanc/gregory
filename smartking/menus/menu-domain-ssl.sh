#!/bin/bash
source /etc/smartking/account_templates.sh
PINK="\e[1;38;5;205m"
VIOLET="\e[1;38;5;141m"
GREEN="\e[1;32m"
WHITE="\e[1;37m"
RED="\e[1;31m"
CYAN="\e[1;36m"
YELLOW="\e[1;33m"
NC="\e[0m"

clear

# Fetch current Domain and Nameserver dynamically
CURRENT_DOMAIN=$(cat /etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null)
[ -z "$CURRENT_DOMAIN" ] && CURRENT_DOMAIN="Not Configured"

CURRENT_NS=$(cat /etc/slowdns/nsdomain 2>/dev/null || cat /root/nsdomain 2>/dev/null)
[ -z "$CURRENT_NS" ] && CURRENT_NS="Not Configured"

echo -e "${PINK}╭── SSL/TLS & DOMAIN MANAGER ────────────────────────────────╮${NC}"
echo -e "${PINK}│${NC} ${WHITE}Active Domain :${NC} ${GREEN}${CURRENT_DOMAIN}${NC}"
echo -e "${PINK}│${NC} ${WHITE}Active NS     :${NC} ${GREEN}${CURRENT_NS}${NC}"
echo -e "${PINK}├── CONFIGURATION ───────────────────────────────────────────┤${NC}"
echo -e "${PINK}│${NC} ${VIOLET}[01]${NC} ${GREEN}Change Server Domain / Subdomain${NC}                      ${PINK}│${NC}"
echo -e "${PINK}│${NC} ${VIOLET}[02]${NC} ${GREEN}Renew Let's Encrypt SSL Certificate${NC}                   ${PINK}│${NC}"
echo -e "${PINK}│${NC} ${VIOLET}[03]${NC} ${GREEN}Configure SlowDNS Manager (Nameserver & Key Gen)${NC}      ${PINK}│${NC}"
echo -e "${PINK}╰────────────────────────────────────────────────────────────╯${NC}"
echo ""
echo -e "${PINK}╭────────────────────────────────────────────────────────────╮${NC}"
echo -e "${PINK}│${NC} ${VIOLET}[00]${NC} ${GREEN}Back to Main Menu${NC}                                     ${PINK}│${NC}"
echo -e "${PINK}╰────────────────────────────────────────────────────────────╯${NC}"
echo ""
read -p "Select an option [00-03]: " opt

case "$opt" in
    1|01)
        clear
        echo -e "${CYAN}╭── CHANGE SERVER DOMAIN ──╮${NC}"
        read -p " Enter New Domain (e.g., vpn.yourdomain.com): " new_domain
        if [ -n "$new_domain" ]; then
            mkdir -p /etc/xray
            echo "$new_domain" > /etc/xray/domain
            echo "$new_domain" > /root/domain
            echo -e "\n${GREEN}[+] Domain successfully updated to: $new_domain${NC}"
        else
            echo -e "\n${RED}[x] Invalid input!${NC}"
        fi
        read -p "Press Enter to return..."
        "${BASH_SOURCE[0]}"
        ;;
        
    2|02)
        clear
        echo -e "${CYAN}╭── RENEW SSL CERTIFICATE ──╮${NC}"
        domain=$(cat /etc/xray/domain 2>/dev/null)
        if [[ -z "$domain" || "$domain" == "Not Configured" ]]; then
            echo -e "${RED}[x] No domain found. Please configure a domain first!${NC}"
        else
            echo -e "${WHITE}[+] Stopping web ports to free up port 80...${NC}"
            systemctl stop nginx apache2 xray 2>/dev/null
            
            echo -e "${WHITE}[+] Requesting new Let's Encrypt SSL for ${domain}...${NC}"
            ~/.acme.sh/acme.sh --issue -d "$domain" --standalone --force
            ~/.acme.sh/acme.sh --installcert -d "$domain" --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key 2>/dev/null
            
            echo -e "${WHITE}[+] Restarting services...${NC}"
            systemctl start xray stunnel4 2>/dev/null
            echo -e "${GREEN}[+] SSL Request Complete!${NC}"
        fi
        read -p "Press Enter to return..."
        "${BASH_SOURCE[0]}"
        ;;
        
    3|03)
        clear
        echo -e "${CYAN}╭── CONFIGURE SLOWDNS NAMESERVER ──╮${NC}"
        read -p " Enter Nameserver (NS) Domain (e.g., ns.yourdomain.com): " ns_domain
        if [ -n "$ns_domain" ]; then
            mkdir -p /etc/slowdns
            echo "$ns_domain" > /etc/slowdns/nsdomain
            echo "$ns_domain" > /root/nsdomain
            echo -e "\n${GREEN}[+] Nameserver successfully updated to: $ns_domain${NC}"
            
            echo -e "\n${WHITE}[+] Regenerating SlowDNS Public/Private Keys...${NC}"
            # This triggers your slowdns keygen if the binary exists
            if [ -f "/etc/slowdns/dns-server" ]; then
                /etc/slowdns/dns-server -gen-key -privkey-file /etc/slowdns/server.key -pubkey-file /etc/slowdns/server.pub 2>/dev/null
                echo -e "${GREEN}[+] New keys generated successfully!${NC}"
            else
                echo -e "${YELLOW}[!] dns-server binary not found. Keys will be generated upon DNS installation.${NC}"
            fi
        else
            echo -e "\n${RED}[x] Invalid input!${NC}"
        fi
        read -p "Press Enter to return..."
        "${BASH_SOURCE[0]}"
        ;;
        
    0|00)
        /etc/smartking/menu.sh
        ;;
        
    *)
        "${BASH_SOURCE[0]}"
        ;;
esac
