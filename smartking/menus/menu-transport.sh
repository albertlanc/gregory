#!/bin/bash
source /etc/smartking/account_templates.sh
PINK="\e[38;5;205m"; CYAN="\e[36m"; GREEN="\e[32m"; RED="\e[31m"; NC="\e[0m"
clear
echo -e "${PINK}╭── XRAY & TRANSPORT MANAGER ─────────────────────────────────╮${NC}"
echo -e " ${CYAN}[01]${NC} ${GREEN}Edit Reality SNI / Fallback Domain${NC}"
echo -e " ${CYAN}[02]${NC} ${GREEN}Restart Xray Core${NC}"
echo -e "${PINK}╰─────────────────────────────────────────────────────────────╯${NC}"
echo ""
echo -e "${RED}╭─────────────────────────────────────────────────────────────╮${NC}"
echo -e " ${CYAN}[00]${NC} ${GREEN}Back to Main Menu${NC}"
echo -e "${RED}╰─────────────────────────────────────────────────────────────╯${NC}"
read -p "Select an option: " opt
case "$opt" in
    1|01) clear; read -p " New SNI: " sni; echo "$sni" > /etc/xray/reality_sni; echo "[+] Saved."; read -p " Press Enter..."; /etc/smartking/menus/menu-transport.sh ;;
    2|02) clear; systemctl restart xray; echo "[+] Xray Restarted."; read -p " Press Enter..."; /etc/smartking/menus/menu-transport.sh ;;
    0|00) /etc/smartking/menu.sh ;;
    *) /etc/smartking/menus/menu-transport.sh ;;
esac
