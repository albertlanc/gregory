#!/bin/bash
source /etc/smartking/account_templates.sh 2>/dev/null
# ==========================================
# Color Variables
# ==========================================
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
# ==========================================
# Dynamic System Data
# ==========================================
IPV4=$(curl -s ipv4.icanhazip.com || echo "127.0.0.1")
UPTIME=$(uptime -p | sed 's/up //')
RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
RAM_USED=$(free -m | awk '/Mem:/ {print $3}')
RAM_PERCENT=$((RAM_USED * 100 / RAM_TOTAL))
SYS_LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | sed 's/ //g')
DISK_USAGE=$(df -h / | awk '/\// {print $5}')
DISK_TOTAL=$(df -h / | awk '/\// {print $2}')
# Service Checks
[ "$(systemctl is-active xray 2>/dev/null)" = "active" ] && ST_XRAY="${GREEN}[OK]${NC}" || ST_XRAY="${RED}[FAIL]${NC}"
[ "$(systemctl is-active dropbear 2>/dev/null)" = "active" ] && ST_SSH="${GREEN}[OK]${NC}" || ST_SSH="${RED}[FAIL]${NC}"
[ "$(systemctl is-active openvpn 2>/dev/null)" = "active" ] && ST_OVPN="${GREEN}[OK]${NC}" || ST_OVPN="${RED}[FAIL]${NC}"
clear
echo -e "${CYAN}$IPV4${NC}"
echo -e "${CYAN}System information as of $(date)${NC}"
echo ""
echo -e "  System load:           ${CYAN}${SYS_LOAD}${NC}"
echo -e "  Usage of /:            ${CYAN}${DISK_USAGE} of ${DISK_TOTAL}${NC}"
echo -e "  * Documentation:  ${CYAN}https://github.com/albertlanc/sholamie${NC}"
echo -e "  * Management:     ${CYAN}TECHFEEDS VPN PRO${NC}"
echo -e "  * Support:        ${CYAN}https://t.me/techfeeds${NC}"
echo ""
echo -e "${MAGENTA}┌── TECHFEEDS VPN PRO V3.0 (ELITE) ─────────────────────┐${NC}"
echo -e " ${CYAN}Host ${NC}: localhost (${GREEN}$IPV4${NC})"
echo -e " ${CYAN}Up   ${NC}: $UPTIME"
echo -e " ${CYAN}RAM  ${NC}: [##--------] $RAM_PERCENT% (${RAM_USED}MB/${RAM_TOTAL}MB)"
echo -e " ${CYAN}SVC  ${NC}: Xray:$ST_XRAY SSH:$ST_SSH OVPN:$ST_OVPN"
echo -e "${MAGENTA}└───────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${MAGENTA}┌── PROTOCOL MANAGEMENT ────────────────────────────────┐${NC}"
echo -e " ${CYAN}[01]${NC} SSH, SSHWS & UDP Custom Manager"
echo -e " ${CYAN}[02]${NC} OpenVPN Manager"
echo -e " ${CYAN}[03]${NC} Xray VLESS Manager"
echo -e " ${CYAN}[04]${NC} Xray VMESS Manager"
echo -e " ${CYAN}[05]${NC} Xray Trojan Manager"
echo -e " ${CYAN}[06]${NC} Shadowsocks Manager"
echo -e "${MAGENTA}└───────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${MAGENTA}┌── SERVER & AUTOMATION ────────────────────────────────┐${NC}"
echo -e " ${CYAN}[07]${NC} Xray & Transport Manager"
echo -e " ${CYAN}[08]${NC} SSL/TLS & Domain Manager"
echo -e " ${CYAN}[09]${NC} Server & Security Manager"
echo -e " ${CYAN}[10]${NC} Service & Port Manager"
echo -e "${MAGENTA}└───────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${MAGENTA}┌── DIAGNOSTICS & TOOLS ────────────────────────────────┐${NC}"
echo -e " ${CYAN}[11]${NC} Monitoring & Tools"
echo -e " ${CYAN}[12]${NC} Advanced Settings"
echo -e " ${CYAN}[13]${NC} Change Server Ports"
echo -e "${MAGENTA}└───────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${MAGENTA}┌───────────────────────────────────────────────────────┐${NC}"
echo -e " ${CYAN}[00]${NC} Exit Dashboard"
echo -e "${MAGENTA}└───────────────────────────────────────────────────────┘${NC}"
echo ""
read -p "Select an option [00-13]: " menu_opt
# ==========================================
# Submenu Routing
# ==========================================
case $menu_opt in
    1|01) bash /etc/smartking/menus/menu-ssh.sh ;;
    2|02) bash /etc/smartking/menus/menu-ovpn.sh ;;
    3|03) bash /etc/smartking/menus/menu-vless.sh ;;
    4|04) bash /etc/smartking/menus/menu-vmess.sh ;;
    5|05) bash /etc/smartking/menus/menu-trojan.sh ;;
    6|06) bash /etc/smartking/menus/menu-shadow.sh ;;
    7|07) bash /etc/smartking/menus/menu-transport.sh ;;
    8|08) bash /etc/smartking/menus/menu-domain-ssl.sh ;;
    9|09) bash /etc/smartking/menus/menu-server-sec.sh ;;
    10) bash /etc/smartking/menus/menu-service.sh ;;
    11) bash /etc/smartking/menus/menu-diagnostics.sh ;;
    12) bash /etc/smartking/menus/menu-advanced.sh ;;
    13) bash /etc/smartking/menus/menu-change-ports.sh ;;
    0|00) clear; exit 0 ;;
    *) echo -e "${RED}Invalid Option!${NC}"; sleep 1; menu ;;
esac
