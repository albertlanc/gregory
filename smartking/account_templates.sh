# ==========================================================
# SMARTKING4LUV V2 - ACCOUNT TEMPLATES & TICKET GENERATORS
# ==========================================================

generate_ssh_ticket() {
    local proto="$1"
    local u="$2"
    local p="$3"
    local q="$4"
    local d="$5"
    local exp="$6"
    
    local ip=$(curl -s ipv4.icanhazip.com || hostname -I | awk '{print $1}')
    local domain=$(cat /etc/xray/domain 2>/dev/null || echo "domain.com")
    local pub_key=$(cat /etc/slowdns/server.pub 2>/dev/null || echo "Not Configured")
    local ns_domain=$(cat /etc/slowdns/nsdomain 2>/dev/null || echo "ns-$domain")

    echo -e "\033[1;35m────────────────────────────────────────────────────────────\033[0m"
    echo -e " \033[1;33m🔒 PRIVATE PREMIUM [ SSH & OVPN TICKET ] 🔒\033[0m"
    echo -e "\033[1;35m────────────────────────────────────────────────────────────\033[0m"
    echo -e " » Host / IP        : $ip"
    echo -e " » Domain SNI       : $domain"
    echo -e " » Username         : $u"
    echo -e " » Password         : $p"
    echo -e " » Quota / Days     : $q / $d Days (Exp: $exp)"
    echo -e "\033[1;35m────────────────────────────────────────────────────────────\033[0m"
    echo -e " \033[1;33m                   NETWORK SERVICE PORTS                   \033[0m"
    echo -e "\033[1;35m────────────────────────────────────────────────────────────\033[0m"
    echo -e " » Dropbear / SSH   : 22, 109, 143"
    echo -e " » SSL / TLS        : 443, 2053, 2083, 8443"
    echo -e " » OpenVPN TCP/UDP  : 1194, 2200"
    echo -e " » SlowDNS (dnstt)  : UDP 5300, 53"
    echo -e " » UDP Custom       : 1-65535"
    echo -e "\033[1;35m────────────────────────────────────────────────────────────\033[0m"
    echo -e " \033[1;33m                    SLOWDNS CREDENTIALS                    \033[0m"
    echo -e "\033[1;35m────────────────────────────────────────────────────────────\033[0m"
    echo -e " » Nameserver (NS)  : $ns_domain"
    echo -e " » Public Key       : $pub_key"
    echo -e "\033[1;35m────────────────────────────────────────────────────────────\033[0m"
    echo -e " \033[1;33m                     OPENVPN LINKS                         \033[0m"
    echo -e "\033[1;35m────────────────────────────────────────────────────────────\033[0m"
    echo -e " » TCP Config       : http://$domain:81/tcp.ovpn"
    echo -e " » UDP Config       : http://$domain:81/udp.ovpn"
    echo -e " » SSL Config       : http://$domain:81/ssl.ovpn"
    echo -e "\033[1;35m────────────────────────────────────────────────────────────\033[0m"
    echo -e " \033[1;33m                 PAYLOAD CONFIGURATIONS                    \033[0m"
    echo -e "\033[1;35m────────────────────────────────────────────────────────────\033[0m"
    echo -e " » Payload WS       :"
    echo -e "   GET / HTTP/1.1[crlf]Host: $domain[crlf]Upgrade: websocket[crlf][crlf]"
    echo -e " » Payload WSS      :"
    echo -e "   GET wss://BUG/ HTTP/1.1[crlf]Host: $domain[crlf]Upgrade: websocket[crlf][crlf]"
    echo -e " » Payload SSH-WS   :"
    echo -e "   GET /sshws HTTP/1.1[crlf]Host: $domain[crlf]Upgrade: websocket[crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf][crlf]"
    echo -e "\033[1;35m────────────────────────────────────────────────────────────\033[0m"
}

generate_xray_ticket() {
    local proto="$1"
    local u="$2"
    local uuid="$3"
    local q="$4"
    local exp="$5"
    
    local ip=$(curl -s ipv4.icanhazip.com || hostname -I | awk '{print $1}')
    local domain=$(cat /etc/xray/domain 2>/dev/null || echo "domain.com")
    local lower_proto=$(echo "$proto" | tr '[:upper:]' '[:lower:]')

    # Automatically register UUID into active Xray configuration
    python3 -c '
import json, sys
proto = sys.argv[1].lower()
uuid = sys.argv[2]
u = sys.argv[3]
cfg_path = "/etc/xray/config.json"
try:
    with open(cfg_path, "r") as f:
        data = json.load(f)
    updated = False
    for inbound in data.get("inbounds", []):
        p = inbound.get("protocol", "").lower()
        if p == proto:
            clients = inbound.setdefault("settings", {}).setdefault("clients", [])
            key = "password" if proto == "trojan" else "id"
            if not any(c.get(key) == uuid for c in clients):
                new_client = {key: uuid, "email": u}
                if proto == "vmess":
                    new_client["alterId"] = 0
                clients.append(new_client)
                updated = True
    if updated:
        with open(cfg_path, "w") as f:
            json.dump(data, f, indent=4)
except Exception as e:
    pass
' "$lower_proto" "$uuid" "$u"
    systemctl restart xray 2>/dev/null || true

    echo -e "\033[1;35m────────────────────────────────────────────────────────────\033[0m"
    echo -e " \033[1;33m🔒 PRIVATE PREMIUM [ XRAY $proto TICKET ] 🔒\033[0m"
    echo -e "\033[1;35m────────────────────────────────────────────────────────────\033[0m"
    echo -e " » Host / IP        : $ip"
    echo -e " » Domain SNI       : $domain"
    echo -e " » Username         : $u"
    echo -e " » Secret / UUID    : $uuid"
    echo -e " » Quota / Exp      : $q (Exp: $exp)"
    echo -e "\033[1;35m────────────────────────────────────────────────────────────\033[0m"
    echo -e " \033[1;33m                     XRAY SHARE LINKS                      \033[0m"
    echo -e "\033[1;35m────────────────────────────────────────────────────────────\033[0m"
    if [ "$lower_proto" == "vmess" ]; then
        local vmess_json_tls="{\"v\":\"2\",\"ps\":\"${u}\",\"add\":\"${domain}\",\"port\":\"443\",\"id\":\"${uuid}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"${domain}\",\"path\":\"/${lower_proto}\",\"tls\":\"tls\",\"sni\":\"${domain}\"}"
        local vmess_json_ntls="{\"v\":\"2\",\"ps\":\"${u}\",\"add\":\"${domain}\",\"port\":\"80\",\"id\":\"${uuid}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"${domain}\",\"path\":\"/${lower_proto}\",\"tls\":\"\"}"
        echo -e " » TLS Link         : vmess://$(echo -n "$vmess_json_tls" | base64 -w 0)"
        echo -e " » Non-TLS Link     : vmess://$(echo -n "$vmess_json_ntls" | base64 -w 0)"
    else
    echo -e " » TLS Link         : ${lower_proto}://${uuid}@${domain}:443?encryption=none&security=tls&type=ws&path=/${lower_proto}&sni=${domain}&host=${domain}#${u}"
    echo -e " » Non-TLS Link     : ${lower_proto}://${uuid}@${domain}:80?encryption=none&security=none&type=ws&path=/${lower_proto}&host=${domain}#${u}"
    fi
    echo -e "\033[1;35m────────────────────────────────────────────────────────────\033[0m"
    echo -e " » Ports            : TLS: 443 | Non-TLS: 80"
    echo -e "\033[1;35m────────────────────────────────────────────────────────────\033[0m"
}
