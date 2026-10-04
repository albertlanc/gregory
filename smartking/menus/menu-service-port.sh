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
echo -e "${PINK}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PINK}║${NC} ${YELLOW}              ⚙️ SERVICE & PORT CONFIG ⚙️              ${NC} ${PINK}║${NC}"
echo -e "${PINK}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${PINK}║${NC} ${WHITE} [01] Restart All VPN Services                             ${NC} ${PINK}║${NC}"
echo -e "${PINK}║${NC} ${WHITE} [02] Reboot Server VPS                                    ${NC} ${PINK}║${NC}"
echo -e "${PINK}║${NC} ${RED} [03] Uninstall Suite & Purge System (Reboot)              ${NC} ${PINK}║${NC}"
echo -e "${PINK}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${PINK}║${NC} ${VIOLET} [00] Back to Main Menu                                    ${NC} ${PINK}║${NC}"
echo -e "${PINK}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
read -p "Select an option [00-03]: " opt

case "$opt" in
    1|01)
        clear; echo -e "${CYAN}[+] Restarting all services...${NC}"
        systemctl restart xray dropbear stunnel4 squid openvpn nginx 2>/dev/null || true
        echo -e "${GREEN}[+] All services restarted successfully!${NC}"
        read -p "Press Enter..."; "${BASH_SOURCE[0]}" ;;
    2|02)
        clear; echo -e "${RED}[+] Rebooting server...${NC}"
        reboot ;;
    3|03)
        /usr/local/bin/smartking-uninstall ;;
    0|00)
        /etc/smartking/menu.sh ;;
    *)
        "${BASH_SOURCE[0]}" ;;
esac
