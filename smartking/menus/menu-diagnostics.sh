#!/bin/bash
source /etc/smartking/account_templates.sh
PINK="\e[38;5;205m"; CYAN="\e[36m"; GREEN="\e[32m"; RED="\e[31m"; NC="\e[0m"
clear
echo -e "${PINK}╭── MONITORING & TOOLS ───────────────────────────────────────╮${NC}"
echo -e " ${CYAN}[01]${NC} ${GREEN}Check RAM, CPU & Disk Usage${NC}"
echo -e " ${CYAN}[02]${NC} ${GREEN}Clear System Cache & RAM Buffers${NC}"
echo -e "${PINK}╰─────────────────────────────────────────────────────────────╯${NC}"
echo ""
echo -e "${RED}╭─────────────────────────────────────────────────────────────╮${NC}"
echo -e " ${CYAN}[00]${NC} ${GREEN}Back to Main Menu${NC}"
echo -e "${RED}╰─────────────────────────────────────────────────────────────╯${NC}"
read -p "Select an option: " opt
case "$opt" in
    1|01) clear; free -h; df -h /; read -p " Press Enter..."; /etc/smartking/menus/menu-diagnostics.sh ;;
    2|02) clear; sync; echo 3 > /proc/sys/vm/drop_caches; echo "[+] Cache flushed."; read -p " Press Enter..."; /etc/smartking/menus/menu-diagnostics.sh ;;
    0|00) /etc/smartking/menu.sh ;;
    *) /etc/smartking/menus/menu-diagnostics.sh ;;
esac
