#!/bin/bash
source /etc/smartking/account_templates.sh
PINK="\e[38;5;205m"; CYAN="\e[36m"; GREEN="\e[32m"; RED="\e[31m"; NC="\e[0m"
clear
echo -e "${PINK}╭── ADVANCED SETTINGS ────────────────────────────────────────╮${NC}"
echo -e " ${CYAN}[01]${NC} ${GREEN}Backup VPS Data${NC}"
echo -e " ${CYAN}[02]${NC} ${GREEN}Update Script Suite from GitHub${NC}"
echo -e "${PINK}╰─────────────────────────────────────────────────────────────╯${NC}"
echo ""
echo -e "${RED}╭─────────────────────────────────────────────────────────────╮${NC}"
echo -e " ${CYAN}[00]${NC} ${GREEN}Back to Main Menu${NC}"
echo -e "${RED}╰─────────────────────────────────────────────────────────────╯${NC}"
read -p "Select an option: " opt
case "$opt" in
    1|01) clear; tar -czf /root/backup.tar.gz /etc/smartking /etc/xray; echo "[+] Backup saved to /root/backup.tar.gz"; read -p " Press Enter..."; /etc/smartking/menus/menu-advanced.sh ;;
    2|02) clear; cd /etc/smartking && git pull origin main; read -p " Press Enter..."; /etc/smartking/menu.sh ;;
    0|00) /etc/smartking/menu.sh ;;
    *) /etc/smartking/menus/menu-advanced.sh ;;
esac
