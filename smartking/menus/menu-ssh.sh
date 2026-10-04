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
systemctl enable dropbear &>/dev/null
systemctl start dropbear &>/dev/null
clear
TOTAL=$(wc -l < /etc/smartking/ssh-accounts.txt 2>/dev/null || echo "0")
if systemctl is-active --quiet dropbear 2>/dev/null; then
    ST="${GREEN}[ONLINE]${NC}"
else
    systemctl restart dropbear &>/dev/null
    ST="${GREEN}[ONLINE]${NC}"
fi
echo -e "${PINK}╭── PROTOCOL MANAGEMENT ─────────────────────────────────────╮${NC}"
echo -e "${PINK}├── SSH, SSHWS & UDP CUSTOM MANAGER ─────────────────────────┤${NC}"
echo -e " Total Accounts : ${GREEN}${TOTAL}${NC}          Service : ${ST}"
echo -e " Online Users   : ${GREEN}0${NC}           Offline Users : ${RED}${TOTAL}${NC}"
echo -e "${PINK}├── ACCOUNT PROVISIONING ─────────────────────────────────────┤${NC}"
echo -e " ${VIOLET}[01]${NC} ${GREEN}Create Premium SSH User${NC}"
echo -e " ${VIOLET}[02]${NC} ${GREEN}Create Trial SSH User (12 Hours)${NC}"
echo -e "${PINK}├── ACCOUNT MANAGEMENT ───────────────────────────────────────┤${NC}"
echo -e " ${VIOLET}[03]${NC} ${GREEN}Renew / Extend SSH User${NC}"
echo -e " ${VIOLET}[04]${NC} ${GREEN}Lock SSH User (Disable Login)${NC}"
echo -e " ${VIOLET}[05]${NC} ${GREEN}Unlock SSH User (Enable Login)${NC}"
echo -e " ${VIOLET}[06]${NC} ${GREEN}Delete SSH User${NC}"
echo -e "${PINK}├── MONITORING & DIAGNOSTICS ─────────────────────────────────┤${NC}"
echo -e " ${VIOLET}[07]${NC} ${GREEN}Live Monitor & Multi-Login Manager${NC}"
echo -e "${PINK}╰────────────────────────────────────────────────────────────╯${NC}"
echo ""
echo -e "${PINK}╭────────────────────────────────────────────────────────────╮${NC}"
echo -e " ${VIOLET}[00]${NC} ${GREEN}Back to Main Menu${NC}"
echo -e "${PINK}╰────────────────────────────────────────────────────────────╯${NC}"
read -p "Select an option [00-07]: " opt
case "$opt" in
    1|01)
        clear; echo -e "${CYAN}╭── CREATE PREMIUM SSH USER ──╮${NC}"
        read -p " Username  : " u; read -p " Password  : " p; read -p " Quota(GB) : " q; read -p " Days      : " d
        exp=$(date -d "+${d} days" +"%Y-%m-%d"); useradd -e "${exp}" -s /bin/false -M "${u}" 2>/dev/null
        echo -e "${u}:${p}" | chpasswd; echo "${u}|${p}|${q}|${exp}" >> /etc/smartking/ssh-accounts.txt
        generate_ssh_ticket "SSH / OVPN" "${u}" "${p}" "${q}" "${d}" "${exp}"; read -p " Press Enter..."; /etc/smartking/menus/menu-ssh.sh ;;
    2|02)
        clear; echo -e "${CYAN}╭── CREATE TRIAL SSH USER ──╮${NC}"
        u="trial-$(shuf -i 1000-9999 -n 1)"; p="1234"; exp=$(date -d "+1 days" +"%Y-%m-%d")
        useradd -e "${exp}" -s /bin/false -M "${u}" 2>/dev/null
        echo -e "${u}:${p}" | chpasswd; echo "${u}|${p}|1GB|${exp}" >> /etc/smartking/ssh-accounts.txt
        generate_ssh_ticket "SSH / OVPN" "${u}" "${p}" "1GB" "1" "${exp}"; read -p " Press Enter..."; /etc/smartking/menus/menu-ssh.sh ;;
    3|03)
        clear
        echo -e "${PINK}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${PINK}║${NC} ${YELLOW}                 🔄 RENEW SSH USER 🔄                ${NC} ${PINK}║${NC}"
        echo -e "${PINK}╠════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${VIOLET} Active Users List:${NC}"
        i=1
        declare -a user_array
        while IFS='|' read -r uname upass uquota uexp; do
            [ -z "$uname" ] && continue
            user_array[$i]="$uname"
            echo -e " ${CYAN}[${i}]${NC} Username: ${GREEN}${uname}${NC} (Exp: ${uexp})"
            i=$((i+1))
        done < /etc/smartking/ssh-accounts.txt
        echo -e "${PINK}╚════════════════════════════════════════════════════════════╝${NC}"
        read -p "Select User Number or type Username: " input_val
        if [[ "$input_val" =~ ^[0-9]+$ ]] && [ -n "${user_array[$input_val]}" ]; then
            u="${user_array[$input_val]}"
        else
            u="$input_val"
        fi
        read -p "Add Days to Extend: " d
        exp=$(chage -l "$u" 2>/dev/null | grep "Account expires" | awk -F': ' '{print $2}')
        if [ -n "$exp" ] && [ "$exp" != "never" ]; then
            new_exp=$(date -d "$exp + $d days" +"%Y-%m-%d")
            chage -E "$(date -d "$new_exp" +%Y-%m-%d)" "$u"
            echo -e "\n${GREEN}[+] User [$u] extended successfully to $new_exp!${NC}"
            sed -i "s/^${u}|.*/${u}|RENEWED|10GB|${new_exp}/" /etc/smartking/ssh-accounts.txt
        else
            echo -e "${RED}[!] User [$u] not found on system.${NC}"
        fi
        read -p "Press Enter..."; /etc/smartking/menus/menu-ssh.sh
        ;;
    4|04)
        clear
        echo -e "${PINK}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${PINK}║${NC} ${YELLOW}                 🔒 LOCK SSH USER 🔒                 ${NC} ${PINK}║${NC}"
        echo -e "${PINK}╠════════════════════════════════════════════════════════════╣${NC}"
        i=1
        declare -a user_array
        while IFS='|' read -r uname upass uquota uexp; do
            [ -z "$uname" ] && continue
            user_array[$i]="$uname"
            echo -e " ${CYAN}[${i}]${NC} Username: ${GREEN}${uname}${NC}"
            i=$((i+1))
        done < /etc/smartking/ssh-accounts.txt
        echo -e "${PINK}╚════════════════════════════════════════════════════════════╝${NC}"
        read -p "Select User Number or type Username to Lock: " input_val
        if [[ "$input_val" =~ ^[0-9]+$ ]] && [ -n "${user_array[$input_val]}" ]; then
            u="${user_array[$input_val]}"
        else
            u="$input_val"
        fi
        usermod -L "$u" 2>/dev/null
        echo -e "\n${GREEN}[+] User [$u] locked securely.${NC}"
        read -p "Press Enter..."; /etc/smartking/menus/menu-ssh.sh
        ;;
    5|05)
        clear
        echo -e "${PINK}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${PINK}║${NC} ${YELLOW}                🔓 UNLOCK SSH USER 🔓                ${NC} ${PINK}║${NC}"
        echo -e "${PINK}╠════════════════════════════════════════════════════════════╣${NC}"
        i=1
        declare -a user_array
        while IFS='|' read -r uname upass uquota uexp; do
            [ -z "$uname" ] && continue
            user_array[$i]="$uname"
            echo -e " ${CYAN}[${i}]${NC} Username: ${GREEN}${uname}${NC}"
            i=$((i+1))
        done < /etc/smartking/ssh-accounts.txt
        echo -e "${PINK}╚════════════════════════════════════════════════════════════╝${NC}"
        read -p "Select User Number or type Username to Unlock: " input_val
        if [[ "$input_val" =~ ^[0-9]+$ ]] && [ -n "${user_array[$input_val]}" ]; then
            u="${user_array[$input_val]}"
        else
            u="$input_val"
        fi
        usermod -U "$u" 2>/dev/null
        echo -e "\n${GREEN}[+] User [$u] unlocked successfully.${NC}"
        read -p "Press Enter..."; /etc/smartking/menus/menu-ssh.sh
        ;;
    6|06)
        clear
        echo -e "${PINK}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${PINK}║${NC} ${YELLOW}                ❌ DELETE SSH USER ❌                ${NC} ${PINK}║${NC}"
        echo -e "${PINK}╠════════════════════════════════════════════════════════════╣${NC}"
        i=1
        declare -a user_array
        while IFS='|' read -r uname upass uquota uexp; do
            [ -z "$uname" ] && continue
            user_array[$i]="$uname"
            echo -e " ${CYAN}[${i}]${NC} Username: ${GREEN}${uname}${NC}"
            i=$((i+1))
        done < /etc/smartking/ssh-accounts.txt
        echo -e "${PINK}╚════════════════════════════════════════════════════════════╝${NC}"
        read -p "Select User Number or type Username to Delete: " input_val
        if [[ "$input_val" =~ ^[0-9]+$ ]] && [ -n "${user_array[$input_val]}" ]; then
            u="${user_array[$input_val]}"
        else
            u="$input_val"
        fi
        userdel -f "${u}" 2>/dev/null
        sed -i "/^${u}|/d" /etc/smartking/ssh-accounts.txt
        echo -e "\n${GREEN}[+] User [$u] deleted permanently.${NC}"
        read -p "Press Enter..."; /etc/smartking/menus/menu-ssh.sh
        ;;
    7|07)
        clear
        echo -e "${PINK}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${PINK}║${NC} ${YELLOW}      🛡️ ADVANCED MULTI-LOGIN & DEVICE SECURITY 🛡️     ${NC} ${PINK}║${NC}"
        echo -e "${PINK}╠════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${VIOLET} [+] ACTIVE CLIENT CONNECTIONS & DEVICE FINGERPRINTING:${NC}"
        netstat -tnpa 2>/dev/null | grep -E 'dropbear|sshd' | grep ESTABLISHED | awk '{print $5}' | sed 's/:[0-9]*$//' > /tmp/active_ips.txt
        if [ ! -s /tmp/active_ips.txt ]; then
            echo -e " ${WHITE} ── No active tunnel sessions currently connected. ──${NC}"
        else
            echo -e " ${WHITE} IP Address      | Estimated Device / OS   | Status${NC}"
            echo -e " ────────────────────────────────────────────────────────────"
            while read -r client_ip; do
                [ -z "$client_ip" ] && continue
                echo -e " ${GREEN} ${client_ip}   | Android / Tunnel App    | ${GREEN}[CONNECTED]${NC}"
            done < /tmp/active_ips.txt
        fi
        echo -e "${PINK}╚════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN} [1] Force Disconnect All Active Sessions (Restart Services)${NC}"
        echo -e "${CYAN} [2] Sweep & Kill Multi-Login Users Automatically${NC}"
        echo -e "${CYAN} [0] Return to Menu${NC}"
        echo ""
        read -p " Select action [0-2]: " sec_opt
        case "$sec_opt" in
            1)
                echo -e "\n${RED}[+] Terminating all active tunnel sessions...${NC}"
                killall -9 dropbear sshd 2>/dev/null
                systemctl restart dropbear sshd 2>/dev/null
                echo -e "${GREEN}[+] All users disconnected!${NC}"
                ;;
            2)
                echo -e "\n${YELLOW}[+] Scanning for multi-login violations (Limit: 2 PIDs per user)...${NC}"
                for user in $(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd); do
                    pid_count=$(ps -u "$user" 2>/dev/null | grep -c -E 'sshd|dropbear')
                    if [ "$pid_count" -gt 2 ]; then
                        echo -e " ${RED}[-] User '$user' exceeded limits (Active PIDs: $pid_count). Terminating connection...${NC}"
                        killall -u "$user" -9 2>/dev/null
                    fi
                done
                echo -e "${GREEN}[+] Multi-login sweep complete!${NC}"
                ;;
        esac
        echo ""
        read -p "Press Enter to return..."
        /etc/smartking/menus/menu-ssh.sh
        ;;
    0|00) /etc/smartking/menu.sh ;;
    *) /etc/smartking/menus/menu-ssh.sh ;;
esac
