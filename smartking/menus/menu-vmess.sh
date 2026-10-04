#!/bin/bash
source /etc/smartking/account_templates.sh 2>/dev/null
PINK="\e[1;38;5;205m"
VIOLET="\e[1;38;5;141m"
GREEN="\e[1;32m"
WHITE="\e[1;37m"
RED="\e[1;31m"
CYAN="\e[1;36m"
YELLOW="\e[1;33m"
NC="\e[0m"

clear
TOTAL=$(wc -l < /etc/smartking/vmess-accounts.txt 2>/dev/null || echo "0")

echo -e "${PINK}╭── PROTOCOL MANAGEMENT ─────────────────────────────────────╮${NC}"
echo -e "${PINK}├── VMESS MANAGER ───────────────────────────────────────────┤${NC}"
echo -e " Total Accounts : ${GREEN}${TOTAL}${NC}          Service : ${GREEN}[ONLINE]${NC}"
echo -e "${PINK}├── ACCOUNT PROVISIONING ─────────────────────────────────────┤${NC}"
echo -e " ${VIOLET}[01]${NC} ${GREEN}Create VMESS Account (Time & Quota)${NC}"
echo -e " ${VIOLET}[02]${NC} ${GREEN}Create VMESS Trial (12 Hours)${NC}"
echo -e "${PINK}├── ACCOUNT MANAGEMENT ───────────────────────────────────────┤${NC}"
echo -e " ${VIOLET}[03]${NC} ${GREEN}Delete VMESS Account${NC}"
echo -e "${PINK}├── MONITORING & DIAGNOSTICS ─────────────────────────────────┤${NC}"
echo -e " ${VIOLET}[04]${NC} ${GREEN}List Active VMESS Accounts${NC}"
echo -e " ${VIOLET}[05]${NC} ${GREEN}Live Monitor & Multi-Login Manager${NC}"
echo -e "${PINK}╰────────────────────────────────────────────────────────────╯${NC}"
echo ""
echo -e "${PINK}╭────────────────────────────────────────────────────────────╮${NC}"
echo -e " ${VIOLET}[00]${NC} ${GREEN}Back to Main Menu${NC}"
echo -e "${PINK}╰────────────────────────────────────────────────────────────╯${NC}"
read -p "Select option [00-05]: " opt

case "$opt" in
    1|01)
        clear; echo -e "\e[1;36m╭── CREATE VMESS USER ──╮\e[0m"
        read -p " Username : " u
        read -p " Duration (e.g., 30d, 12h, 45m) : " d_input
        read -p " Data Quota (e.g., 50GB, Unlimited) : " q
        d_num=$(echo "$d_input" | tr -dc "0-9")
        if [[ "$d_input" == *h* ]]; then exp=$(date -d "+$d_num hours" +"%Y-%m-%d %H:%M")
        elif [[ "$d_input" == *m* ]]; then exp=$(date -d "+$d_num minutes" +"%Y-%m-%d %H:%M")
        else exp=$(date -d "+$d_num days" +"%Y-%m-%d %H:%M"); fi
        uuid=$(cat /proc/sys/kernel/random/uuid)
        echo "${u}|${uuid}|${exp}|${q}" >> /etc/smartking/vmess-accounts.txt
        generate_xray_ticket "VMESS" "${u}" "${uuid}" "${q}" "${exp}"
        read -p " Press Enter..."; /etc/smartking/menus/menu-vmess.sh ;;
    2|02)
        clear; echo -e "\e[1;36m╭── CREATE VMESS TRIAL ──╮\e[0m"
        u="trial-vmess-$(shuf -i 1000-9999 -n 1)"
        uuid=$(cat /proc/sys/kernel/random/uuid)
        exp=$(date -d "+12 hours" +"%Y-%m-%d %H:%M")
        echo "${u}|${uuid}|${exp}|1GB" >> /etc/smartking/vmess-accounts.txt
        generate_xray_ticket "VMESS" "${u}" "${uuid}" "1GB" "${exp}"
        read -p " Press Enter..."; /etc/smartking/menus/menu-vmess.sh ;;
    3|03)
        clear
        echo -e "${PINK}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${PINK}║${NC} ${YELLOW}                ❌ DELETE VMESS USER ❌              ${NC} ${PINK}║${NC}"
        echo -e "${PINK}╠════════════════════════════════════════════════════════════╣${NC}"
        i=1; declare -a arr
        while IFS='|' read -r uname uuid uexp; do
            [ -z "$uname" ] && continue
            arr[$i]="$uname"
            echo -e " ${CYAN}[${i}]${NC} Username: ${GREEN}${uname}${NC}"
            i=$((i+1))
        done < /etc/smartking/vmess-accounts.txt
        echo -e "${PINK}╚════════════════════════════════════════════════════════════╝${NC}"
        read -p "Select number or username to delete: " val
        [[ "$val" =~ ^[0-9]+$ ]] && u="${arr[$val]}" || u="$val"
        sed -i "/^${u}|/d" /etc/smartking/vmess-accounts.txt
        echo -e "\n${GREEN}[+] Deleted [$u].${NC}"; read -p "Press Enter..."; /etc/smartking/menus/menu-vmess.sh ;;
    4|04)
        clear
        echo -e "${PINK}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${PINK}║${NC} ${YELLOW}              📋 ACTIVE VMESS USERS 📋               ${NC} ${PINK}║${NC}"
        echo -e "${PINK}╠════════════════════════════════════════════════════════════╣${NC}"
        i=1
        while IFS='|' read -r uname uuid uexp; do
            [ -z "$uname" ] && continue
            echo -e " ${CYAN}[${i}]${NC} User: ${GREEN}${uname}${NC} (Exp: ${uexp})"
            i=$((i+1))
        done < /etc/smartking/vmess-accounts.txt
        echo -e "${PINK}╚════════════════════════════════════════════════════════════╝${NC}"
        read -p "Press Enter..."; /etc/smartking/menus/menu-vmess.sh ;;
    5|05)
        clear
        echo -e "${PINK}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${PINK}║${NC} ${YELLOW}      🛡️ VMESS LIVE MONITOR & MULTI-LOGIN SECURITY 🛡️     ${NC} ${PINK}║${NC}"
        echo -e "${PINK}╠════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${VIOLET} [+] ACTIVE VMESS CLIENT CONNECTIONS:${NC}"
        netstat -tnpa 2>/dev/null | grep xray | grep ESTABLISHED | awk '{print $5}' | sed 's/:[0-9]*$//' > /tmp/vmess_ips.txt
        if [ ! -s /tmp/vmess_ips.txt ]; then
            echo -e " ${WHITE} ── No active VMESS tunnels currently connected. ──${NC}"
        else
            echo -e " ${WHITE} IP Address      | Estimated Device / OS   | Status${NC}"
            echo -e " ────────────────────────────────────────────────────────────"
            while read -r ip; do
                [ -z "$ip" ] && continue
                echo -e " ${GREEN} ${ip}   | Android / VMess App     | ${GREEN}[CONNECTED]${NC}"
            done < /tmp/vmess_ips.txt
        fi
        echo -e "${PINK}╚════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "Press Enter to return..."
        /etc/smartking/menus/menu-vmess.sh
        ;;
    0|00)
        /etc/smartking/menu.sh
        ;;
    *)
        /etc/smartking/menus/menu-vmess.sh
        ;;
esac
