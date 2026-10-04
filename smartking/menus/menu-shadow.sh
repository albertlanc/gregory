#!/bin/bash
source /etc/smartking/account_templates.sh 2>/dev/null
BLUE="\e[38;5;39m"; CYAN="\e[36m"; GREEN="\e[32m"; RED="\e[31m"; NC="\e[0m"
clear
echo -e "${BLUE}╭── SHADOWSOCKS MANAGER ──────────────────────────────────────╮${NC}"
echo -e " ${CYAN}[01]${NC} ${GREEN}Create Shadowsocks Account${NC}"
echo -e " ${CYAN}[02]${NC} ${GREEN}Delete Shadowsocks Account${NC}"
echo -e "${BLUE}╰─────────────────────────────────────────────────────────────╯${NC}"
echo ""
echo -e "${RED}╭─────────────────────────────────────────────────────────────╮${NC}"
echo -e " ${CYAN}[00]${NC} ${GREEN}Back to Main Menu${NC}"
echo -e "${RED}╰─────────────────────────────────────────────────────────────╯${NC}"
echo ""
read -p "Select option [00-02]: " opt
case "$opt" in
    1|01)
        clear; echo -e "${CYAN}╭── CREATE SHADOWSOCKS USER ──╮${NC}"
        read -p " Username : " u; read -p " Quota(GB): " q; read -p " Days     : " d
        uuid=$(cat /proc/sys/kernel/random/uuid); exp=$(date -d "+${d} days" +"%Y-%m-%d")
        jq --arg pass "$uuid" --arg email "$u" '.inbounds[3].settings.clients += [{"password": $pass, "email": $email, "method": "chacha20-poly1305"}]' /etc/xray/config.json > /tmp/x.json && mv /tmp/x.json /etc/xray/config.json
        systemctl restart xray; generate_xray_ticket "SHADOWSOCKS" "$u" "$uuid" "${q}GB" "$exp"
        read -p " Press Enter..."; /etc/smartking/menus/menu-shadow.sh ;;
    2|02)
        clear; echo -e "${CYAN}╭── DELETE SHADOWSOCKS USER ──╮${NC}"; echo -e "${CYAN}Active Users:${NC}"
        jq -r '.inbounds[3].settings.clients[].email' /etc/xray/config.json 2>/dev/null | awk '{print "  - " $0}'
        echo -e "${CYAN}───────────────────────────────${NC}"; read -p " Username to Delete: " u
        jq --arg email "$u" 'del(.inbounds[3].settings.clients[] | select(.email == $email))' /etc/xray/config.json > /tmp/x.json && mv /tmp/x.json /etc/xray/config.json
        systemctl restart xray; echo -e "\n${GREEN}[+] User $u deleted.${NC}"; read -p " Press Enter..."; /etc/smartking/menus/menu-shadow.sh ;;
    0|00) /etc/smartking/menu.sh ;;
    *) /etc/smartking/menus/menu-shadow.sh ;;
esac
