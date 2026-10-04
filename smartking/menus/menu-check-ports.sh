#!/bin/bash
source /etc/smartking/account_templates.sh
PINK="\e[1;38;5;205m"
GREEN="\e[1;32m"
RED="\e[1;31m"
WHITE="\e[1;37m"
NC="\e[0m"

clear
echo -e "${PINK}============================================================${NC}"
echo -e "${WHITE}          🔍 PORT & SERVICE LISTENING DIAGNOSTICS          ${NC}"
echo -e "${PINK}============================================================${NC}"
echo ""

ports=(22 80 443 2053 2083 8443)

for p in "${ports[@]}"; do
    if ss -tlnp | grep -q ":$p "; then
        echo -e " Port [${p}] : ${GREEN}[LISTENING]${NC}"
    else
        echo -e " Port [${p}] : ${RED}[NOT LISTENING]${NC}"
    fi
done

echo ""
echo -e "${PINK}============================================================${NC}"
echo -e "${WHITE}          🌐 ACTIVE PROTOCOL PROCESS CHECK                  ${NC}"
echo -e "${PINK}============================================================${NC}"
echo -n " Dropbear SSH : " && pgrep dropbear &>/dev/null && echo -e "${GREEN}[ACTIVE]${NC}" || echo -e "${RED}[INACTIVE]${NC}"
echo -n " Xray Core    : " && pgrep xray &>/dev/null && echo -e "${GREEN}[ACTIVE]${NC}" || echo -e "${RED}[INACTIVE]${NC}"
echo -n " Stunnel / SSL: " && pgrep stunnel &>/dev/null && echo -e "${GREEN}[ACTIVE]${NC}" || echo -e "${RED}[INACTIVE]${NC}"
echo -e "${PINK}============================================================${NC}"
echo ""
read -p "Press Enter to return..."
