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
mkdir /backup > /dev/null 2>&1
mkdir /user > /dev/null 2>&1
mkdir /tmp > /dev/null 2>&1
clear
vnstat --remove -i eth1 --force
clear
rm /usr/local/etc/sing-box/city > /dev/null 2>&1
rm /usr/local/etc/sing-box/org > /dev/null 2>&1
rm /usr/local/etc/sing-box/timezone > /dev/null 2>&1
bash <(curl -Ls https://raw.githubusercontent.com/masjeho2/sing-box-yes/master/install.sh) install
cp /usr/local/bin/sing-box /backup/sing-box.official.backup
curl -s ipinfo.io/city >> /usr/local/etc/sing-box/city
curl -s ipinfo.io/org | cut -d " " -f 2-10 >> /usr/local/etc/sing-box/org
curl -s ipinfo.io/timezone >> /usr/local/etc/sing-box/timezone
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
touch /usr/local/etc/sing-box/domain
echo -e "${YB}Input Domain${NC} "
echo " "
read -rp "Input your domain : " -e dns
if [ -z $dns ]; then
echo -e "Nothing input for domain!"
else
echo "$dns" > /usr/local/etc/sing-box/domain
echo "DNS=$dns" > /var/lib/dnsvps.conf
fi
clear
systemctl stop nginx
domain=$(cat /usr/local/etc/sing-box/domain)
curl https://get.acme.sh | sh
source ~/.bashrc
cd .acme.sh
bash acme.sh --issue -d $domain --server letsencrypt --keylength ec-256 --fullchain-file /usr/local/etc/sing-box/fullchain.crt --key-file /usr/local/etc/sing-box/private.key --standalone --force
clear
echo -e "${GB}[ INFO ]${NC} ${YB}Setup Nginx & sing-box Conf${NC}"
echo "UQ3w2q98BItd3DPgyctdoJw4cqQFmY59ppiDQdqMKbw=" > /usr/local/etc/sing-box/serverpsk
#wget -q -O /usr/local/etc/sing-box/config.json https://raw.githubusercontent.com/masjeho2/conf/main/config.json
wget -q -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/masjeho2/conf/main/nginx.conf
wget -q -O /etc/nginx/conf.d/sing-box.conf https://raw.githubusercontent.com/masjeho2/conf/main/sing-box.conf
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
cd /usr/bin
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Main Menu${NC}"
wget -q -O menu "https://raw.githubusercontent.com/masjeho2/v1/sing-box/menu/menu.sh"
wget -q -O vmess "https://raw.githubusercontent.com/masjeho2/v1/sing-box/menu/vmess.sh"
wget -q -O vless "https://raw.githubusercontent.com/masjeho2/v1/sing-box/menu/vless.sh"
wget -q -O trojan "https://raw.githubusercontent.com/masjeho2/v1/sing-box/menu/trojan.sh"
wget -q -O shadowsocks "https://raw.githubusercontent.com/masjeho2/v1/sing-box/menu/shadowsocks.sh"
wget -q -O shadowsocks2022 "https://raw.githubusercontent.com/masjeho2/v1/sing-box/menu/shadowsocks2022.sh"
wget -q -O socks "https://raw.githubusercontent.com/masjeho2/v1/sing-box/menu/socks.sh"
wget -q -O allsing-box "https://raw.githubusercontent.com/masjeho2/v1/sing-box/menu/allsing-box.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Vmess${NC}"
wget -q -O add-vmess "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vmess/add-vmess.sh"
wget -q -O del-vmess "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vmess/del-vmess.sh"
wget -q -O extend-vmess "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vmess/extend-vmess.sh"
wget -q -O trialvmess "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vmess/trialvmess.sh"
wget -q -O cek-vmess "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vmess/cek-vmess.sh" 
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Vless${NC}"
wget -q -O add-vless "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vless/add-vless.sh"
wget -q -O del-vless "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vless/del-vless.sh"
wget -q -O extend-vless "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vless/extend-vless.sh"
wget -q -O trialvless "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vless/trialvless.sh"
wget -q -O cek-vless "https://raw.githubusercontent.com/masjeho2/v1/sing-box/vless/cek-vless.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Trojan${NC}"
wget -q -O add-trojan "https://raw.githubusercontent.com/masjeho2/v1/sing-box/trojan/add-trojan.sh"
wget -q -O del-trojan "https://raw.githubusercontent.com/masjeho2/v1/sing-box/trojan/del-trojan.sh"
wget -q -O extend-trojan "https://raw.githubusercontent.com/masjeho2/v1/sing-box/trojan/extend-trojan.sh"
wget -q -O trialtrojan "https://raw.githubusercontent.com/masjeho2/v1/sing-box/trojan/trialtrojan.sh"
wget -q -O cek-trojan "https://raw.githubusercontent.com/masjeho2/v1/sing-box/trojan/cek-trojan.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Socks5${NC}"
wget -q -O add-socks "https://raw.githubusercontent.com/masjeho2/v1/sing-box/socks/add-socks.sh"
wget -q -O del-socks "https://raw.githubusercontent.com/masjeho2/v1/sing-box/socks/del-socks.sh"
wget -q -O extend-socks "https://raw.githubusercontent.com/masjeho2/v1/sing-box/socks/extend-socks.sh"
wget -q -O trialsocks "https://raw.githubusercontent.com/masjeho2/v1/sing-box/socks/trialsocks.sh"
wget -q -O cek-socks "https://raw.githubusercontent.com/masjeho2/v1/sing-box/socks/cek-socks.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu All sing-box${NC}"
wget -q -O add-sing-box "https://raw.githubusercontent.com/masjeho2/v1/sing-box/allsing-box/add-sing-box.sh"
wget -q -O del-sing-box "https://raw.githubusercontent.com/masjeho2/v1/sing-box/allsing-box/del-sing-box.sh"
wget -q -O extend-sing-box "https://raw.githubusercontent.com/masjeho2/v1/sing-box/allsing-box/extend-sing-box.sh"
wget -q -O trialsing-box "https://raw.githubusercontent.com/masjeho2/v1/sing-box/allsing-box/trialsing-box.sh"
wget -q -O cek-sing-box "https://raw.githubusercontent.com/masjeho2/v1/sing-box/allsing-box/cek-sing-box.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Log${NC}"
wget -q -O log-create "https://raw.githubusercontent.com/masjeho2/v1/sing-box/log/log-create.sh"
wget -q -O log-vmess "https://raw.githubusercontent.com/masjeho2/v1/sing-box/log/log-vmess.sh"
wget -q -O log-vless "https://raw.githubusercontent.com/masjeho2/v1/sing-box/log/log-vless.sh"
wget -q -O log-trojan "https://raw.githubusercontent.com/masjeho2/v1/sing-box/log/log-trojan.sh"
wget -q -O log-ss "https://raw.githubusercontent.com/masjeho2/v1/sing-box/log/log-ss.sh"
wget -q -O log-ss2022 "https://raw.githubusercontent.com/masjeho2/v1/sing-box/log/log-ss2022.sh"
wget -q -O log-socks "https://raw.githubusercontent.com/masjeho2/v1/sing-box/log/log-socks.sh"
wget -q -O log-allsing-box "https://raw.githubusercontent.com/masjeho2/v1/sing-box/log/log-allsing-box.sh"
sleep 0.5
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Other Menu${NC}"
wget -q -O xp "https://raw.githubusercontent.com/masjeho2/v1/sing-box/other/xp.sh"
wget -q -O dns "https://raw.githubusercontent.com/masjeho2/v1/sing-box/other/dns.sh"
wget -q -O certsing-box "https://raw.githubusercontent.com/masjeho2/v1/sing-box/other/certsing-box.sh"
wget -q -O sing-boxmod "https://raw.githubusercontent.com/masjeho2/v1/sing-box/other/sing-boxmod.sh"
wget -q -O sing-boxofficial "https://raw.githubusercontent.com/masjeho2/v1/sing-box/other/sing-boxofficial.sh"
wget -q -O about "https://raw.githubusercontent.com/masjeho2/v1/sing-box/other/about.sh"
wget -q -O clear-log "https://raw.githubusercontent.com/masjeho2/v1/sing-box/other/clear-log.sh"
echo -e "${GB}[ INFO ]${NC} ${YB}Download All Menu Done${NC}"
sleep 2
chmod +x add-vmess
chmod +x del-vmess
chmod +x extend-vmess
chmod +x trialvmess
chmod +x cek-vmess
chmod +x add-vless
chmod +x del-vless
chmod +x extend-vless
chmod +x trialvless
chmod +x cek-vless
chmod +x add-trojan
chmod +x del-trojan
chmod +x extend-trojan
chmod +x trialtrojan
chmod +x cek-trojan
chmod +x add-ss
chmod +x del-ss
chmod +x extend-ss
chmod +x trialss
chmod +x cek-ss
chmod +x add-ss2022
chmod +x del-ss2022
chmod +x extend-ss2022
chmod +x trialss2022
chmod +x cek-ss2022
chmod +x add-socks
chmod +x del-socks
chmod +x extend-socks
chmod +x trialsocks
chmod +x cek-socks
chmod +x add-sing-box
chmod +x del-sing-box
chmod +x extend-sing-box
chmod +x trialsing-box
chmod +x cek-sing-box
chmod +x log-create
chmod +x log-vmess
chmod +x log-vless
chmod +x log-trojan
chmod +x log-ss
chmod +x log-ss2022
chmod +x log-socks
chmod +x log-allsing-box
chmod +x menu
chmod +x vmess
chmod +x vless
chmod +x trojan
chmod +x shadowsocks
chmod +x shadowsocks2022
chmod +x socks
chmod +x allsing-box
chmod +x xp
chmod +x dns
chmod +x certsing-box
chmod +x sing-boxmod
chmod +x sing-boxofficial
chmod +x about
chmod +x clear-log
cd
echo "0 0 * * * root xp" >> /etc/crontab
echo "*/5 * * * * root clear-log" >> /etc/crontab
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
