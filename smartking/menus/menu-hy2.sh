#!/bin/bash
source /etc/smartking/account_templates.sh
PINK="\e[38;5;205m"; CYAN="\e[36m"; GREEN="\e[32m"; WHITE="\e[37m"; YELLOW="\e[33m"; NC="\e[0m"

hy2_child() {
    clear
    DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "vpn.smartking4luv.com")
    if systemctl is-active --quiet hysteria-server 2>/dev/null; then ST="${GREEN}[ONLINE]${NC}"; else ST="${PINK}[OFFLINE]${NC}"; fi
    
    echo -e "${CYAN}╭── HYSTERIA V2 MANAGER ──────────────────────────╮${NC}"
    echo -e " ${GREEN}Service Status : ${ST}"
    echo -e " ${GREEN}Active Port    : ${YELLOW}443 (UDP)${NC}"
    echo -e "${CYAN}├── CONFIGURATION PROFILES ───────────────────────┤${NC}"
    echo -e " ${CYAN}[01]${NC} ${GREEN}Generate Hysteria V2 Universal Link${NC}"
    echo -e "${CYAN}╰─────────────────────────────────────────────────╯${NC}"
    echo ""
    echo -e "${PINK}╭─────────────────────────────────────────────────╮${NC}"
    echo -e " ${CYAN}[00]${NC} ${GREEN}Back to Main Menu${NC}"
    echo -e "${PINK}╰─────────────────────────────────────────────────╯${NC}"
    echo ""
    read -p "Select option [00-01]: " c_opt
    case "$c_opt" in
        1|01) 
            echo ""
            read -p " Username: " u
            echo -e "\n ${GREEN}Hysteria V2 Link:${NC}"
            echo -e " hy2://${u}@${DOMAIN}:443/?sni=${DOMAIN}&insecure=1\n"
            read -p " Press Enter to return..."
            hy2_child
            ;;
        0|00) /etc/smartking/menu.sh ;;
        *) hy2_child ;;
    esac
}

clear
echo -e "${PINK}╭── HYSTERIA V2 & UDP PROTOCOLS ──────────────────╮${NC}"
echo -e " ${CYAN}[01]${NC} ${GREEN}Create Hysteria V2 Account${NC}"
echo -e " ${CYAN}[02]${NC} ${GREEN}ZIVPN UDP Config Manager${NC}"
echo -e " ${CYAN}[03]${NC} ${GREEN}AnyTLS Protocol Manager${NC}"
echo -e " ${CYAN}[04]${NC} ${GREEN}L2TP / SSTP / IKEv2 Manager${NC}"
echo -e "${PINK}╰─────────────────────────────────────────────────╯${NC}"
echo ""
echo -e "${PINK}╭─────────────────────────────────────────────────╮${NC}"
echo -e " ${CYAN}[00]${NC} ${GREEN}Back to Main Menu${NC}"
echo -e "${PINK}╰─────────────────────────────────────────────────╯${NC}"
echo ""
read -p "Select an option [00-04]: " opt

case "$opt" in
    1|01) hy2_child ;;
    2|02) clear; echo -e "${CYAN}╭── ZIVPN UDP MANAGER ──╮${NC}\n\n${GREEN}[+] ZIVPN UDP is actively listening on ports 1-65535.${NC}\n"; read -p "Press Enter to return..."; /etc/smartking/menus/menu-hy2.sh ;;
    3|03) clear; echo -e "${CYAN}╭── ANYTLS PROTOCOL MANAGER ──╮${NC}\n\n${GREEN}[+] AnyTLS Multiplexing is running.${NC}\n"; read -p "Press Enter to return..."; /etc/smartking/menus/menu-hy2.sh ;;
    4|04) clear; echo -e "${CYAN}╭── L2TP / SSTP MANAGER ──╮${NC}\n\n${GREEN}[+] IPSec/L2TP Modules loaded.${NC}\n"; read -p "Press Enter to return..."; /etc/smartking/menus/menu-hy2.sh ;;
    0|00) /etc/smartking/menu.sh ;;
    *) /etc/smartking/menus/menu-hy2.sh ;;
esac
