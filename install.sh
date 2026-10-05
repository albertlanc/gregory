#!/bin/bash
# ==============================================================================
# SMARTKING V2 (TECHFEEDS ELITE) - ZERO-MISTAKE AUTO-INSTALLER
# OS: Ubuntu 20.04 / 22.04 / 24.04 LTS
# ==============================================================================
clear
echo "======================================================"
echo "    SMARTKING PREMIUM AUTO-INSTALLER (ZERO-CONFLICT)  "
echo "======================================================"
echo ""
read -p " Enter your Main Domain (e.g., vpn.example.com) : " DOMAIN
read -p " Enter your NameServer for SlowDNS (e.g., ns.example.com) : " NS_DOMAIN
echo ""

# 1. CORE DEPENDENCIES (Swapped 'awk' for 'gawk' to prevent fatal crash)
echo "[+] Installing Elite Libraries & Dependencies..."
apt-get update -y && apt-get upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install -y git curl wget unzip python3 python3-pip \
nginx cron uuid-runtime tzdata sed gawk stunnel4 dropbear openvpn easy-rsa socat \
iptables iptables-persistent netfilter-persistent cmake make gcc g++ build-essential \
libsqlite3-dev libssl-dev squid ufw sslh haproxy

# 2. IP FORWARDING
echo "[+] Configuring Kernel IP Forwarding..."
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# 3. TIMEZONE
echo "[+] Syncing Server Timezone to Africa/Lagos..."
timedatectl set-timezone Africa/Lagos

# 4. ACME.SH SSL CERTIFICATES
echo "[+] Generating SSL Certificates for $DOMAIN..."
curl https://get.acme.sh | sh
mkdir -p /etc/xray /etc/stunnel
systemctl stop nginx 2>/dev/null
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
~/.acme.sh/acme.sh --register-account -m admin@$DOMAIN
~/.acme.sh/acme.sh --issue -d $DOMAIN --standalone
~/.acme.sh/acme.sh --installcert -d $DOMAIN --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key
cat /etc/xray/xray.crt /etc/xray/xray.key > /etc/stunnel/stunnel.pem

# 5. SQUID PROXY
echo "[+] Configuring Squid Proxy..."
mkdir -p /etc/squid
cat << INNER_EOF > /etc/squid/squid.conf
http_port 3128
acl localnet src 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16
acl localhost src 127.0.0.1/32
acl SSL_ports port 443
acl Safe_ports port 80 21 443 109 143 1194 2200
http_access allow all
INNER_EOF

# 6. BADVPN UDPGW
echo "[+] Compiling BadVPN (UDP Gateway)..."
cd /root
rm -rf badvpn
git clone https://github.com/ambrop72/badvpn.git
cd badvpn && mkdir build && cd build
cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
make install
for port in 7100 7200 7300; do
cat << INNER_EOF > /etc/systemd/system/badvpn-$port.service
[Unit]
Description=BadVPN UDPGW on port $port
[Service]
ExecStart=/usr/local/bin/badvpn-udpgw --listen-addr 127.0.0.1:$port --max-clients 1000 --max-connections-for-client 10
Restart=always
[Install]
WantedBy=multi-user.target
INNER_EOF
systemctl enable badvpn-$port
done

# 7. SLOWDNS (DNSTT) - FORCED GO 1.21 & HARDCODED PATH FIX
echo "[+] Installing Go 1.21 & Compiling SlowDNS (DNSTT)..."
wget -q https://go.dev/dl/go1.21.6.linux-amd64.tar.gz
rm -rf /usr/local/go
tar -C /usr/local -xzf go1.21.6.linux-amd64.tar.gz
ln -sf /usr/local/go/bin/go /usr/bin/go
rm -f go1.21.6.linux-amd64.tar.gz

cd /root
rm -rf dnstt
git clone https://github.com/OutlineFoundation/dnstt.git
cd dnstt/dnstt-server
go mod tidy
go build -o dns-server

# Deploy binary to all possible paths to satisfy the panel logic
mkdir -p /etc/slowdns
cp dns-server /etc/slowdns/dns-server
cp dns-server /usr/local/bin/dns-server
cp dns-server /usr/local/bin/dnstt-server
chmod +x /etc/slowdns/dns-server /usr/local/bin/dns-server /usr/local/bin/dnstt-server

cd /etc/slowdns
/etc/slowdns/dns-server -gen-key -privkey-file server.key -pubkey-file server.pub
PRIV_KEY=$(cat server.key)
PUB_KEY=$(cat server.pub)

cat << INNER_EOF > /etc/systemd/system/slowdns.service
[Unit]
Description=SlowDNS DNSTT Server
[Service]
ExecStart=/etc/slowdns/dns-server -udp :5300 -privkey-file /etc/slowdns/server.key $NS_DOMAIN 127.0.0.1:109
Restart=always
[Install]
WantedBy=multi-user.target
INNER_EOF
iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 5300

# 8. DROPBEAR & MULTI-PORT STUNNEL
echo "[+] Configuring Dropbear & Stunnel..."
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=109/g' /etc/default/dropbear
grep -q 'DROPBEAR_EXTRA_ARGS="-p 143"' /etc/default/dropbear || echo 'DROPBEAR_EXTRA_ARGS="-p 143"' >> /etc/default/dropbear

cat << INNER_EOF > /etc/stunnel/stunnel.conf
pid = /var/run/stunnel.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear_2053]
accept = 2053
connect = 127.0.0.1:109
[dropbear_2083]
accept = 2083
connect = 127.0.0.1:109
[dropbear_8443]
accept = 8443
connect = 127.0.0.1:109
[openvpn_ssl]
accept = 992
connect = 127.0.0.1:1194
INNER_EOF
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4

# 9. OPENVPN CONFIG SERVER
echo "[+] Configuring Nginx OpenVPN Port 81 Server..."
mkdir -p /var/www/html/ovpn
cat << 'INNER_EOF' > /etc/nginx/sites-available/ovpn
server {
    listen 81;
    server_name _;
    root /var/www/html/ovpn;
    autoindex on;
}
INNER_EOF
ln -sf /etc/nginx/sites-available/ovpn /etc/nginx/sites-enabled/

# 10. UDP CUSTOM ROUTING
echo "[+] Configuring UDP Custom Routing rules..."
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables-save > /etc/iptables/rules.v4

# 11. HAPROXY & XRAY CORE WITH MASTER VLESS FALLBACKS
echo "[+] Installing Xray Core & Hysteria 2..."
bash <(curl -fsSL https://app.hysteria.network/get.sh)
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

echo -e "[*] Configuring HAProxy Multiplexer..."
cat << 'EOF' > /etc/haproxy/haproxy.cfg
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    user haproxy
    group haproxy
    daemon
    maxconn 65535

defaults
    log     global
    mode    tcp
    option  tcplog
    option  dontlognull
    retries 3
    timeout queue 1m
    timeout connect 10s
    timeout client 30m
    timeout server 30m

# PORT 443: TLS / SECURE TRAFFIC MULTIPLEXER
frontend port_443_in
    bind *:443
    mode tcp
    option tcplog
    default_backend xray_tls_backend

# PORT 80: NON-TLS / HTTP TRAFFIC MULTIPLEXER
frontend port_80_in
    bind *:80
    mode tcp
    option tcplog
    default_backend xray_nontls_backend

# BACKENDS (LOCAL XRAY SERVICE PORTS)
backend xray_tls_backend
    mode tcp
    balance source
    server xray_tls 127.0.0.1:4433 check

backend xray_nontls_backend
    mode tcp
    balance source
    server xray_nontls 127.0.0.1:8080 check
EOF

echo -e "[*] Configuring Master VLESS Fallback Xray Template..."
mkdir -p /usr/local/etc/xray/
mkdir -p /etc/xray/

cat << 'EOF' > /usr/local/etc/xray/config.json
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 4433,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {
        "clients": [
          { "id": "2b92642a-a92d-45fc-9a1b-36f663045610", "email": "dummy" }
        ],
        "decryption": "none",
        "fallbacks": [
          { "path": "/trojan", "dest": 8083 },
          { "path": "/vless", "dest": 8082 },
          { "path": "/vmess", "dest": 8081 }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            { "certificateFile": "/etc/xray/xray.crt", "keyFile": "/etc/xray/xray.key" }
          ]
        }
      }
    },
    {
      "port": 8080,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {
        "clients": [
          { "id": "2b92642a-a92d-45fc-9a1b-36f663045610", "email": "dummy" }
        ],
        "decryption": "none",
        "fallbacks": [
          { "path": "/trojan", "dest": 8083 },
          { "path": "/vless", "dest": 8082 },
          { "path": "/vmess", "dest": 8081 }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "none"
      }
    },
    {
      "port": 8082,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {
        "clients": [
          { "id": "2b92642a-a92d-45fc-9a1b-36f663045610", "email": "dummy" }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": { "path": "/vless" }
      }
    },
    {
      "port": 8081,
      "listen": "127.0.0.1",
      "protocol": "vmess",
      "settings": {
        "clients": [
          { "id": "2b92642a-a92d-45fc-9a1b-36f663045610", "alterId": 0, "email": "dummy" }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": { "path": "/vmess" }
      }
    },
    {
      "port": 8083,
      "listen": "127.0.0.1",
      "protocol": "trojan",
      "settings": {
        "clients": [
          { "password": "dummy-password", "email": "dummy" }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": { "path": "/trojan" }
      }
    }
  ],
  "outbounds": [
    { "protocol": "freedom" }
  ]
}
EOF

echo -e "[*] Linking Xray Config to SmartKing Panel..."
rm -f /etc/xray/config.json
ln -s /usr/local/etc/xray/config.json /etc/xray/config.json

# 12. DEPLOY REPOSITORY FILES (INCLUDES ACCOUNT TRACKING & MENU LINKS)
echo "[+] Deploying SmartKing Panel Files..."
REPO_DIR=$(pwd)
if [ -f "$REPO_DIR/config/nginx-default.conf" ]; then
    cp -f $REPO_DIR/config/nginx-default.conf /etc/nginx/sites-available/default
fi

# We don't overwrite config.json here anymore since HAProxy/Xray generation handles it natively.
# if [ -f "$REPO_DIR/config/xray-config.json" ]; then
#     cp -f $REPO_DIR/config/xray-config.json /etc/xray/config.json
# fi

sed -i "s/example.com/$DOMAIN/g" /etc/nginx/sites-available/default 2>/dev/null || true

# Generate missing tracking databases to prevent header UI errors
mkdir -p /etc/smartking/menus /var/log/smartking
touch /etc/smartking/vless-accounts.txt \
      /etc/smartking/vmess-accounts.txt \
      /etc/smartking/trojan-accounts.txt \
      /etc/smartking/shadowsocks-accounts.txt \
      /etc/smartking/ssh-accounts.txt

if [ -d "$REPO_DIR/smartking" ]; then
    cp -f $REPO_DIR/smartking/account_templates.sh /etc/smartking/ 2>/dev/null || true
    cp -f $REPO_DIR/smartking/menus/*.sh /etc/smartking/menus/ 2>/dev/null || true
fi

# Automatically inject the template library into ALL menus so functions always load
for menu in /etc/smartking/menus/*.sh; do
    grep -q "account_templates.sh" "$menu" || sed -i '2i source /etc/smartking/account_templates.sh 2>/dev/null' "$menu"
done

chmod +x /etc/smartking/account_templates.sh /etc/smartking/menus/*.sh 2>/dev/null || true

MAIN_SCRIPT=$(find /etc/smartking/menus/ -type f -name "*.sh" | grep -E "service|main|menu" | head -n 1)
if [ -n "$MAIN_SCRIPT" ]; then
    ln -sf "$MAIN_SCRIPT" /usr/local/bin/menu
else
    ln -sf /etc/smartking/menus/menu.sh /usr/local/bin/menu
fi
chmod +x /usr/local/bin/menu

# 13. AUTO-KILL EXPIRY DAEMON
if [ -f "$REPO_DIR/bin/smartking-expiry" ]; then
    cp -f $REPO_DIR/bin/smartking-expiry /usr/local/bin/smartking-expiry
    chmod +x /usr/local/bin/smartking-expiry
fi
(crontab -l 2>/dev/null | grep -v "smartking-expiry"; echo "* * * * * /usr/local/bin/smartking-expiry") | crontab -

# 14. START ALL SERVICES
echo "[+] Starting all Elite Services..."
systemctl daemon-reload
systemctl enable haproxy nginx xray stunnel4 dropbear openvpn hysteria-server slowdns squid badvpn-7100 badvpn-7200 badvpn-7300 netfilter-persistent cron
systemctl restart haproxy nginx xray stunnel4 dropbear slowdns squid badvpn-7100 badvpn-7200 badvpn-7300 netfilter-persistent cron

clear
echo "======================================================"
echo "    ELITE INSTALLATION COMPLETELY SUCCESSFUL!"
echo "======================================================"
echo " Domain Configured    : $DOMAIN"
echo " OVPN Config Server   : http://$DOMAIN:81"
echo " SSL/Stunnel Ports    : 2053, 2083, 8443"
echo " Squid Proxy Port     : 3128"
echo " Dropbear SSH         : 22, 109, 143"
echo " SlowDNS PubKey       : $PUB_KEY"
echo "======================================================"
echo " Type 'menu' to access the SmartKing Panel."
