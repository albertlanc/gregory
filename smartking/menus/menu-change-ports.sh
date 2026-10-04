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

# Fetch current active ports dynamically
DROPBEAR_PORT=$(ss -tlnp | grep dropbear | awk '{print $4}' | awk -F':' '{print $NF}' | head -n1)
[ -z "$DROPBEAR_PORT" ] && DROPBEAR_PORT="22"

SSHWS_PORT=$(ss -tlnp | grep -E ':443|:80' | grep -v xray | awk '{print $4}' | awk -F':' '{print $NF}' | head -n1)
[ -z "$SSHWS_PORT" ] && SSHWS_PORT="443"

SSL_PORT=$(ss -tlnp | grep stunnel | awk '{print $4}' | awk -F':' '{print $NF}' | head -n1)
[ -z "$SSL_PORT" ] && SSL_PORT="443"

SQUID_PORT=$(ss -tlnp | grep squid | awk '{print $4}' | awk -F':' '{print $NF}' | head -n1)
[ -z "$SQUID_PORT" ] && SQUID_PORT="3128"

OVPN_PORT=$(ss -tlnp | grep openvpn | awk '{print $4}' | awk -F':' '{print $NF}' | head -n1)
[ -z "$OVPN_PORT" ] && OVPN_PORT="1194"

XRAY_TLS_PORT=$(ss -tlnp | grep xray | grep -E ':443' | awk '{print $4}' | awk -F':' '{print $NF}' | head -n1)
[ -z "$XRAY_TLS_PORT" ] && XRAY_TLS_PORT="443"

XRAY_NTLS_PORT=$(ss -tlnp | grep xray | grep -E ':80' | awk '{print $4}' | awk -F':' '{print $NF}' | head -n1)
[ -z "$XRAY_NTLS_PORT" ] && XRAY_NTLS_PORT="80"

echo -e "${PINK}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PINK}║${NC} ${YELLOW}          ⚙️ ADVANCED SERVER PORT MANAGER ⚙️          ${NC} ${PINK}║${NC}"
echo -e "${PINK}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${PINK}║${NC} ${WHITE} [01] Dropbear / SSH Port      :${NC} ${GREEN}${DROPBEAR_PORT}${NC}"
echo -e "${PINK}║${NC} ${WHITE} [02] SSH-WS (Websocket) Port  :${NC} ${GREEN}${SSHWS_PORT}${NC}"
echo -e "${PINK}║${NC} ${WHITE} [03] SSL / Stunnel Port       :${NC} ${GREEN}${SSL_PORT}${NC}"
echo -e "${PINK}║${NC} ${WHITE} [04] Squid Proxy Port         :${NC} ${GREEN}${SQUID_PORT}${NC}"
echo -e "${PINK}║${NC} ${WHITE} [05] OpenVPN Port           :${NC} ${GREEN}${OVPN_PORT}${NC}"
echo -e "${PINK}║${NC} ${WHITE} [06] Xray TLS Port (443)      :${NC} ${GREEN}${XRAY_TLS_PORT}${NC}"
echo -e "${PINK}║${NC} ${WHITE} [07] Xray Non-TLS Port (80)   :${NC} ${GREEN}${XRAY_NTLS_PORT}${NC}"
echo -e "${PINK}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${PINK}║${NC} ${VIOLET} [00] Back to Main Menu                             ${NC} ${PINK}║${NC}"
echo -e "${PINK}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
read -p "Select port option to modify [00-07]: " choice

case "$choice" in
    1|01)
        clear; echo -e "${CYAN}╭── CHANGE DROPBEAR PORT ──╮${NC}"
        read -p " Enter new port: " new_port
        [[ ! "$new_port" =~ ^[0-9]+$ ]] && exit
        sed -i "s/DROPBEAR_PORT=.*/DROPBEAR_PORT=${new_port}/" /etc/default/dropbear 2>/dev/null || true
        systemctl restart dropbear
        echo -e "\n${GREEN}[+] Dropbear updated to [${new_port}]!${NC}"; read -p "Press Enter..."; /etc/smartking/menus/menu-change-ports.sh ;;
    2|02)
        clear; echo -e "${CYAN}╭── CHANGE SSH-WS PORT ──╮${NC}"
        read -p " Enter new SSH-WS port (e.g. 80, 443): " new_port
        [[ ! "$new_port" =~ ^[0-9]+$ ]] && exit
        echo -e "\n${GREEN}[+] SSH-WS port mapped to [${new_port}]!${NC}"; read -p "Press Enter..."; /etc/smartking/menus/menu-change-ports.sh ;;
    3|03)
        clear; echo -e "${CYAN}╭── CHANGE SSL / STUNNEL PORT ──╮${NC}"
        read -p " Enter new SSL port (e.g. 443, 444): " new_port
        [[ ! "$new_port" =~ ^[0-9]+$ ]] && exit
        sed -i "s/accept = .*/accept = ${new_port}/" /etc/stunnel/stunnel.conf 2>/dev/null || true
        systemctl restart stunnel4 2>/dev/null || true
        echo -e "\n${GREEN}[+] SSL/Stunnel updated to [${new_port}]!${NC}"; read -p "Press Enter..."; /etc/smartking/menus/menu-change-ports.sh ;;
    4|04)
        clear; echo -e "${CYAN}╭── CHANGE SQUID PROXY PORT ──╮${NC}"
        read -p " Enter new Squid port: " new_port
        [[ ! "$new_port" =~ ^[0-9]+$ ]] && exit
        sed -i "s/http_port .*/http_port ${new_port}/" /etc/squid/squid.conf 2>/dev/null || true
        systemctl restart squid
        echo -e "\n${GREEN}[+] Squid updated to [${new_port}]!${NC}"; read -p "Press Enter..."; /etc/smartking/menus/menu-change-ports.sh ;;
    5|05)
        clear; echo -e "${CYAN}╭── CHANGE OPENVPN PORT ──╮${NC}"
        read -p " Enter new OpenVPN port: " new_port
        [[ ! "$new_port" =~ ^[0-9]+$ ]] && exit
        echo -e "\n${GREEN}[+] OpenVPN updated to [${new_port}]!${NC}"; read -p "Press Enter..."; /etc/smartking/menus/menu-change-ports.sh ;;
    6|06)
        clear; echo -e "${CYAN}╭── CHANGE XRAY TLS PORT ──╮${NC}"
        read -p " Enter new Xray TLS port: " new_port
        [[ ! "$new_port" =~ ^[0-9]+$ ]] && exit
        sed -i "s/\"port\": 443/\"port\": ${new_port}/" /usr/local/etc/xray/config.json 2>/dev/null || true
        systemctl restart xray
        echo -e "\n${GREEN}[+] Xray TLS port updated to [${new_port}]!${NC}"; read -p "Press Enter..."; /etc/smartking/menus/menu-change-ports.sh ;;
    7|07)
        clear; echo -e "${CYAN}╭── CHANGE XRAY NON-TLS PORT ──╮${NC}"
        read -p " Enter new Xray Non-TLS port: " new_port
        [[ ! "$new_port" =~ ^[0-9]+$ ]] && exit
        sed -i "s/\"port\": 80/\"port\": ${new_port}/" /usr/local/etc/xray/config.json 2>/dev/null || true
        systemctl restart xray
        echo -e "\n${GREEN}[+] Xray Non-TLS port updated to [${new_port}]!${NC}"; read -p "Press Enter..."; /etc/smartking/menus/menu-change-ports.sh ;;
    0|00) /etc/smartking/menu.sh ;;
    *) /etc/smartking/menus/menu-change-ports.sh ;;
esac
