#!/bin/bash
source /etc/smartking/account_templates.sh
BLUE="\e[38;5;39m"; CYAN="\e[36m"; GREEN="\e[32m"; RED="\e[31m"; NC="\e[0m"
clear
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "vpn.domain.com")
echo -e "${BLUE}╭── OPENVPN MANAGER ──────────────────────────────────────────╮${NC}"
echo -e " OpenVPN uses the exact same accounts as SSH. Generate"
echo -e " the client connection profiles (.ovpn) below."
echo -e "${BLUE}├── CONFIGURATION PROFILES ───────────────────────────────────┤${NC}"
echo -e " ${CYAN}[01]${NC} ${GREEN}Generate OpenVPN TCP Profile${NC}"
echo -e " ${CYAN}[02]${NC} ${GREEN}Generate OpenVPN UDP Profile${NC}"
echo -e " ${CYAN}[03]${NC} ${GREEN}Generate OpenVPN SSL Profile${NC}"
echo -e "${BLUE}╰─────────────────────────────────────────────────────────────╯${NC}"
echo ""
echo -e "${RED}╭─────────────────────────────────────────────────────────────╮${NC}"
echo -e " ${CYAN}[00]${NC} ${GREEN}Back to Main Menu${NC}"
echo -e "${RED}╰─────────────────────────────────────────────────────────────╯${NC}"
echo ""
read -p "Select option [00-03]: " opt
case "$opt" in
    1|01) echo -e "\n${GREEN}TCP Link:${NC} http://$DOMAIN:81/tcp.ovpn"; read -p " Press Enter..."; /etc/smartking/menus/menu-ovpn.sh ;;
    2|02) echo -e "\n${GREEN}UDP Link:${NC} http://$DOMAIN:81/udp.ovpn"; read -p " Press Enter..."; /etc/smartking/menus/menu-ovpn.sh ;;
    3|03) echo -e "\n${GREEN}SSL Link:${NC} http://$DOMAIN:81/ssl.ovpn"; read -p " Press Enter..."; /etc/smartking/menus/menu-ovpn.sh ;;
    0|00) /etc/smartking/menu.sh ;;
    *) /etc/smartking/menus/menu-ovpn.sh ;;
esac
