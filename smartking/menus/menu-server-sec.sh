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
echo -e "${PINK}╭── SERVER & SECURITY MGR ───────────────────────────────────╮${NC}"
echo -e "${PINK}│${NC}                                                            ${PINK}│${NC}"
echo -e "${PINK}│${NC} ${VIOLET}[01]${NC} ${GREEN}Delete All Expired Accounts (Sweep)${NC}                   ${PINK}│${NC}"
echo -e "${PINK}│${NC} ${VIOLET}[02]${NC} ${GREEN}Change SSH Login Banner${NC}                               ${PINK}│${NC}"
echo -e "${PINK}╰────────────────────────────────────────────────────────────╯${NC}"
echo ""
echo -e "${PINK}╭────────────────────────────────────────────────────────────╮${NC}"
echo -e "${PINK}│${NC} ${VIOLET}[00]${NC} ${GREEN}Back to Main Menu${NC}                                     ${PINK}│${NC}"
echo -e "${PINK}╰────────────────────────────────────────────────────────────╯${NC}"
echo ""
read -p "Select an option: " opt

case "$opt" in
    1|01)
        clear
        echo -e "${CYAN}╭── SWEEPING EXPIRED ACCOUNTS ──╮${NC}"
        TODAY=$(date +%s)
        DELETED_COUNT=0
        
        # 1. Sweep Xray Protocols (VLESS, VMESS, TROJAN)
        for proto in vless vmess trojan; do
            FILE="/etc/smartking/${proto}-accounts.txt"
            if [ -f "$FILE" ]; then
                # Output to a temp file to avoid reading/writing issues
                > /tmp/valid_${proto}.txt
                while IFS='|' read -r uname upass uexp; do
                    [ -z "$uname" ] && continue
                    EXP_SEC=$(date -d "$uexp" +%s 2>/dev/null)
                    if [[ -n "$EXP_SEC" && "$TODAY" -ge "$EXP_SEC" ]]; then
                        echo -e " ${RED}[-] Deleted Expired ${proto^^} User:${NC} $uname (Expired: $uexp)"
                        DELETED_COUNT=$((DELETED_COUNT+1))
                    else
                        echo "${uname}|${upass}|${uexp}" >> /tmp/valid_${proto}.txt
                    fi
                done < "$FILE"
                mv /tmp/valid_${proto}.txt "$FILE"
            fi
        done

        # 2. Sweep System SSH Users
        for user in $(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd); do
            exp_date=$(chage -l "$user" 2>/dev/null | grep "Account expires" | cut -d: -f2 | sed 's/^ *//')
            if [[ "$exp_date" != "never" && -n "$exp_date" ]]; then
                EXP_SEC=$(date -d "$exp_date" +%s 2>/dev/null)
                if [[ -n "$EXP_SEC" && "$TODAY" -ge "$EXP_SEC" ]]; then
                    userdel -f "$user" 2>/dev/null
                    echo -e " ${RED}[-] Deleted Expired SSH User:${NC} $user (Expired: $exp_date)"
                    DELETED_COUNT=$((DELETED_COUNT+1))
                fi
            fi
        done

        if [ "$DELETED_COUNT" -eq 0 ]; then
            echo -e "\n ${GREEN}[+] No expired accounts found. System is clean!${NC}"
        else
            echo -e "\n ${GREEN}[+] Cleanup complete! Deleted $DELETED_COUNT expired account(s).${NC}"
            systemctl restart xray dropbear 2>/dev/null
        fi
        
        echo ""
        read -p "Press Enter to return..."
        "${BASH_SOURCE[0]}"
        ;;
        
    2|02)
        clear
        echo -e "${CYAN}╭── CHANGE SSH LOGIN BANNER ──╮${NC}"
        echo -e "${WHITE}Type your new banner text below.${NC}"
        echo -e "${WHITE}(HTML tags like <b>, <font color='red'> are supported by some clients)${NC}"
        echo -e "${YELLOW}------------------------------------------------------------${NC}"
        read -p "New Banner: " new_banner
        
        # Write to issue.net
        echo -e "$new_banner" > /etc/issue.net
        
        # Ensure Dropbear is configured to use it
        sed -i 's|DROPBEAR_BANNER=.*|DROPBEAR_BANNER="/etc/issue.net"|' /etc/default/dropbear 2>/dev/null || true
        systemctl restart dropbear 2>/dev/null || true
        systemctl restart sshd 2>/dev/null || true
        
        echo -e "\n${GREEN}[+] SSH Banner successfully updated and services restarted!${NC}"
        read -p "Press Enter to return..."
        "${BASH_SOURCE[0]}"
        ;;
        
    0|00)
        /etc/smartking/menu.sh
        ;;
        
    *)
        "${BASH_SOURCE[0]}"
        ;;
esac
