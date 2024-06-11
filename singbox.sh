rm -rf sing-box
clear
NC='\e[0m'
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'
secs_to_human() {
echo -e "${WB}Installation time : $(( ${1} / 3600 )) hours $(( (${1} / 60) % 60 )) minute's $(( ${1} % 60 )) seconds${NC}"
}
start=$(date +%s)
GIHUB_REPO=raw.githubusercontent.com/masjeho2/conf
apt update -y
apt full-upgrade -y
apt dist-upgrade -y
apt install socat curl screen cron screenfetch netfilter-persistent vnstat lsof fail2ban -y
apt install sysstat -y
apt install jq -y

mkdir /backup > /dev/null 2>&1
mkdir /user > /dev/null 2>&1
mkdir /tmp > /dev/null 2>&1
clear
vnstat --remove -i eth1 --force
clear
rm /etc/sing-box/city > /dev/null 2>&1
rm /etc/sing-box/org > /dev/null 2>&1
rm /etc/sing-box/timezone > /dev/null 2>&1
bash <(curl -fsSL https://sing-box.app/deb-install.sh)
curl -s ipinfo.io/city >> /etc/sing-box/city
curl -s ipinfo.io/org | cut -d " " -f 2-10 >> /etc/sing-box/org
curl -s ipinfo.io/timezone >> /etc/sing-box/timezone
clear
sleep 1
cd
clear
sudo apt-get install lolcat -y
clear
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest
clear
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
apt install nginx -y
rm /var/www/html/*.html
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
mkdir -p /var/www/html/vmess
mkdir -p /var/www/html/vless
mkdir -p /var/www/html/trojan
mkdir -p /var/www/html/shadowsocks
mkdir -p /var/www/html/shadowsocks2022
mkdir -p /var/www/html/socks5
mkdir -p /var/www/html/allsing-box
mkdir -p /var/log/sing-box
systemctl restart nginx
clear
touch /etc/sing-box/domain
echo -e "${YB}Input Domain${NC} "
echo " "
read -rp "Input your domain : " -e dns
if [ -z $dns ]; then
echo -e "Nothing input for domain!"
else
echo "$dns" > /etc/sing-box/domain
echo "DNS=$dns" > /var/lib/dnsvps.conf
fi
clear
systemctl stop nginx
domain=$(cat /etc/sing-box/domain)
curl https://get.acme.sh | sh
source ~/.bashrc
cd .acme.sh
bash acme.sh --issue -d $domain --server letsencrypt --keylength ec-256 --fullchain-file /etc/sing-box/fullchain.crt --key-file /etc/sing-box/private.key --standalone --force
clear
echo -e "${GB}[ INFO ]${NC} ${YB}Setup Nginx & sing-box Conf${NC}"
echo "UQ3w2q98BItd3DPgyctdoJw4cqQFmY59ppiDQdqMKbw=" > /etc/sing-box/serverpsk
wget -q -O /etc/sing-box/config.json https://raw.githubusercontent.com/masjeho2/conf/main/singbox-config.json
wget -q -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/masjeho2/conf/main/nginx.conf
wget -q -O /etc/nginx/conf.d/sing-box.conf https://raw.githubusercontent.com/masjeho2/conf/main/sing-box.conf
wget -q -O /var/www/html/robots.txt https://raw.githubusercontent.com/masjeho2/conf/main/robots.txt
systemctl restart nginx
systemctl restart sing-box
echo -e "${GB}[ INFO ]${NC} ${YB}Setup Done${NC}"
sleep 2
clear
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload
echo "* soft nofile 1000000" >> /etc/security/limits.conf
echo "* hard nofile 1000000" >> /etc/security/limits.conf
echo "* soft nproc 1000000" >> /etc/security/limits.conf
echo "* hard nproc 1000000" >> /etc/security/limits.conf
echo "session required pam_limits.so" >> /etc/pam.d/common-session
echo "session required pam_limits.so" >> /etc/pam.d/common-session-noninteractive
ulimit -n 1000000
ulimit -u 100000
mkdir -p /etc/systemd/system/nginx.service.d/
cat > /etc/systemd/system/nginx.service.d/override.conf << END
[Service]
LimitNOFILE=1000000
END
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sed -i '/fs.file-max/d' /etc/sysctl.conf
sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
echo "fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
systemctl daemon-reload
systemctl restart nginx
cd /usr/bin
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Main Menu${NC}"
wget -q -O /usr/bin/menu "https://raw.githubusercontent.com/masjeho2/v1/sing-box/menu/menu.sh"
wget -q -O /usr/bin/vmess "https://raw.githubusercontent.com/masjeho2/v1/sing-box/menu/vmess.sh"
wget -q -O /usr/bin/vless "https://raw.githubusercontent.com/masjeho2/v1/sing-box/menu/vless.sh"
wget -q -O /usr/bin/trojan "https://raw.githubusercontent.com/masjeho2/v1/sing-box/menu/trojan.sh"
wget -q -O /usr/bin/socks "https://raw.githubusercontent.com/masjeho2/v1/sing-box/menu/socks.sh"
wget -q -O /usr/bin/allsing-box "https://raw.githubusercontent.com/masjeho2/v1/sing-box/menu/allsing-box.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Vmess${NC}"
wget -q -O /usr/bin/add-vmess "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vmess/add-vmess.sh"
wget -q -O /usr/bin/del-vmess "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vmess/del-vmess.sh"
wget -q -O /usr/bin/extend-vmess "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vmess/extend-vmess.sh"
wget -q -O /usr/bin/trialvmess "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vmess/trialvmess.sh"
wget -q -O /usr/bin/cek-vmess "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vmess/cek-vmess.sh" 
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Vless${NC}"
wget -q -O /usr/bin/add-vless "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vless/add-vless.sh"
wget -q -O /usr/bin/del-vless "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vless/del-vless.sh"
wget -q -O /usr/bin/extend-vless "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vless/extend-vless.sh"
wget -q -O /usr/bin/trialvless "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vless/trialvless.sh"
wget -q -O /usr/bin/cek-vless "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vless/cek-vless.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Trojan${NC}"
wget -q -O /usr/bin/add-trojan "https://raw.githubusercontent.com/masjeho2/v1/sing-box/trojan/add-trojan.sh"
wget -q -O /usr/bin/del-trojan "https://raw.githubusercontent.com/masjeho2/v1/sing-box/trojan/del-trojan.sh"
wget -q -O /usr/bin/extend-trojan "https://raw.githubusercontent.com/masjeho2/v1/sing-box/trojan/extend-trojan.sh"
wget -q -O /usr/bin/trialtrojan "https://raw.githubusercontent.com/masjeho2/v1/sing-box/trojan/trialtrojan.sh"
wget -q -O /usr/bin/cek-trojan "https://raw.githubusercontent.com/masjeho2/v1/sing-box/trojan/cek-trojan.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Socks5${NC}"
wget -q -O /usr/bin/add-socks "https://raw.githubusercontent.com/masjeho2/v1/sing-box/socks/add-socks.sh"
wget -q -O /usr/bin/del-socks "https://raw.githubusercontent.com/masjeho2/v1/sing-box/socks/del-socks.sh"
wget -q -O /usr/bin/extend-socks "https://raw.githubusercontent.com/masjeho2/v1/sing-box/socks/extend-socks.sh"
wget -q -O /usr/bin/trialsocks "https://raw.githubusercontent.com/masjeho2/v1/sing-box/socks/trialsocks.sh"
wget -q -O /usr/bin/cek-socks "https://raw.githubusercontent.com/masjeho2/v1/sing-box/socks/cek-socks.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu All sing-box${NC}"
wget -q -O /usr/bin/add-sing-box "https://raw.githubusercontent.com/masjeho2/v1/sing-box/allsing-box/add-sing-box.sh"
wget -q -O /usr/bin/del-sing-box "https://raw.githubusercontent.com/masjeho2/v1/sing-box/allsing-box/del-sing-box.sh"
wget -q -O /usr/bin/extend-sing-box "https://raw.githubusercontent.com/masjeho2/v1/sing-box/allsing-box/extend-sing-box.sh"
wget -q -O /usr/bin/trialsing-box "https://raw.githubusercontent.com/masjeho2/v1/sing-box/allsing-box/trialsing-box.sh"
wget -q -O /usr/bin/cek-sing-box "https://raw.githubusercontent.com/masjeho2/v1/sing-box/allsing-box/cek-sing-box.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Log${NC}"
wget -q -O /usr/bin/log-create "https://raw.githubusercontent.com/masjeho2/v1/sing-box/log/log-create.sh"
wget -q -O /usr/bin/log-vmess "https://raw.githubusercontent.com/masjeho2/v1/sing-box/log/log-vmess.sh"
wget -q -O /usr/bin/log-vless "https://raw.githubusercontent.com/masjeho2/v1/sing-box/log/log-vless.sh"
wget -q -O /usr/bin/log-trojan "https://raw.githubusercontent.com/masjeho2/v1/sing-box/log/log-trojan.sh"
wget -q -O /usr/bin/log-socks "https://raw.githubusercontent.com/masjeho2/v1/sing-box/log/log-socks.sh"
wget -q -O /usr/bin/log-allsing-box "https://raw.githubusercontent.com/masjeho2/v1/sing-box/log/log-allsing-box.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Other Menu${NC}"
wget -q -O /usr/bin/xp "https://raw.githubusercontent.com/masjeho2/v1/sing-box/other/xp.sh"
wget -q -O /usr/bin/dns "https://raw.githubusercontent.com/masjeho2/v1/sing-box/other/dns.sh"
wget -q -O /usr/bin/certsing-box "https://raw.githubusercontent.com/masjeho2/v1/sing-box/other/certsing-box.sh"
wget -q -O /usr/bin/about "https://raw.githubusercontent.com/masjeho2/v1/sing-box/other/about.sh"
wget -q -O /usr/bin/clear-log "https://raw.githubusercontent.com/masjeho2/v1/sing-box/other/clear-log.sh"
wget -q -O /usr/bin/infocpu "https://raw.githubusercontent.com/masjeho2/v1/sing-box/other/infocpu.sh"
echo -e "${GB}[ INFO ]${NC} ${YB}Download All Menu Done${NC}"
sleep 2
chmod +x /usr/bin/add-vmess
chmod +x /usr/bin/del-vmess
chmod +x /usr/bin/extend-vmess
chmod +x /usr/bin/trialvmess
chmod +x /usr/bin/cek-vmess
chmod +x /usr/bin/add-vless
chmod +x /usr/bin/del-vless
chmod +x /usr/bin/extend-vless
chmod +x /usr/bin/trialvless
chmod +x /usr/bin/cek-vless
chmod +x /usr/bin/add-trojan
chmod +x /usr/bin/del-trojan
chmod +x /usr/bin/extend-trojan
chmod +x /usr/bin/trialtrojan
chmod +x /usr/bin/cek-trojan
chmod +x /usr/bin/add-socks
chmod +x /usr/bin/del-socks
chmod +x /usr/bin/extend-socks
chmod +x /usr/bin/trialsocks
chmod +x /usr/bin/cek-socks
chmod +x /usr/bin/add-sing-box
chmod +x /usr/bin/del-sing-box
chmod +x /usr/bin/extend-sing-box
chmod +x /usr/bin/trialsing-box
chmod +x /usr/bin/cek-sing-box
chmod +x /usr/bin/log-create
chmod +x /usr/bin/log-vmess
chmod +x /usr/bin/log-vless
chmod +x /usr/bin/log-trojan
chmod +x /usr/bin/log-socks
chmod +x /usr/bin/log-allsing-box
chmod +x /usr/bin/menu
chmod +x /usr/bin/vmess
chmod +x /usr/bin/vless
chmod +x /usr/bin/trojan
chmod +x /usr/bin/socks
chmod +x /usr/bin/allsing-box
chmod +x /usr/bin/xp
chmod +x /usr/bin/dns
chmod +x /usr/bin/certsing-box
chmod +x /usr/bin/sing-boxmod
chmod +x /usr/bin/sing-boxofficial
chmod +x /usr/bin/about
chmod +x /usr/bin/clear-log
chmod +x /usr/bin/infocpu
clear
echo "0 0 * * * root xp" >> /etc/crontab
echo "*/5 * * * * root clear-log" >> /etc/crontab
echo "*/5 * * * * root infocpu" >> /etc/crontab
echo "0 0 */7 * * root curl -L -o /etc/sing-box/geoip.db https://github.com/malikshi/sing-box-geo/releases/latest/download/geoip.db && curl -L -o /etc/sing-box/geosite.db https://github.com/malikshi/sing-box-geo/releases/latest/download/geosite.db && systemctl restart sing-box" >> /etc/crontab
systemctl restart cron
cat > /root/.profile << END
if [ "$BASH" ]; then
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi
fi
mesg n || true
clear
menu
END
chmod 644 /root/.profile
clear
echo ""
echo ""
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10   
echo ""
echo -e "                ${WB}PREMIUM SCRIPT${NC}"
echo ""
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo -e "  ${WB}»»» Protocol Service «««  |  »»» Network Protocol «««${NC}  "
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo -e "  ${YB}- Vless${NC}                   ${WB}|${NC}  ${YB}- Websocket (CDN) non TLS${NC}"
echo -e "  ${YB}- Vmess${NC}                   ${WB}|${NC}  ${YB}- Websocket (CDN) TLS${NC}"
echo -e "  ${YB}- Trojan${NC}                  ${WB}|${NC}  ${YB}- gRPC (CDN) TLS${NC}"
echo -e "  ${YB}- Socks5${NC}                  ${WB}|${NC}"
echo -e "  ${YB}- Shadowsocks${NC}             ${WB}|${NC}"
echo -e "  ${YB}- Shadowsocks 2022${NC}        ${WB}|${NC}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo -e "               ${WB}»»» Network Port Service «««${NC}             "
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo -e "  ${YB}- HTTPS : 443, 2053, 2083, 2087, 2096, 8443${NC}"
echo -e "  ${YB}- HTTP  : 80, 8080, 8880, 2052, 2082, 2086, 2095${NC}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo ""
rm -f singbox.sh
secs_to_human "$(($(date +%s) - ${start}))"
echo -e "${YB}[ WARNING ] reboot now ? (Y/N)${NC} "
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
exit 0
else
reboot
fi
