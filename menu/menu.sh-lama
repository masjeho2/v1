NC='\e[0m'
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'
singbox_service=$(systemctl status sing-box | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
nginx_service=$(systemctl status nginx | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $singbox_service == "running" ]]; then
status_singbox="${GB}[ ON ]${NC}"
else
status_singbox="${RB}[ OFF ]${NC}"
fi
if [[ $nginx_service == "running" ]]; then
status_nginx="${GB}[ ON ]${NC}"
else
status_nginx="${RB}[ OFF ]${NC}"
fi
dtoday="$(vnstat | grep today | awk '{print $2" "substr ($3, 1, 3)}')"
utoday="$(vnstat | grep today | awk '{print $5" "substr ($6, 1, 3)}')"
ttoday="$(vnstat | grep today | awk '{print $8" "substr ($9, 1, 3)}')"
dmon="$(vnstat -m | grep `date +%G-%m` | awk '{print $2" "substr ($3, 1 ,3)}')"
umon="$(vnstat -m | grep `date +%G-%m` | awk '{print $5" "substr ($6, 1 ,3)}')"
tmon="$(vnstat -m | grep `date +%G-%m` | awk '{print $8" "substr ($9, 1 ,3)}')"
domain=$(cat /etc/sing-box/domain)
ISP=$(cat /etc/sing-box/org)
CITY=$(cat /etc/sing-box/city)
WKT=$(cat /etc/sing-box/timezone)
DATE=$(date -R | cut -d " " -f -4)
MYIP=$(curl -sS ipv4.icanhazip.com)
clear
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo -e ""
echo -e "       ${WB}━━━━━ [ PREMIUM sing-box ] ━━━━━${NC}       "
echo -e ""
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo -e " ${YB}Service Provider${NC} ${WB}: $ISP"
echo -e " ${YB}Timezone${NC}         ${WB}: $WKT${NC}"
echo -e " ${YB}City${NC}             ${WB}: $CITY${NC}"
echo -e " ${YB}Date${NC}             ${WB}: $DATE${NC}"
echo -e " ${YB}Domain${NC}           ${WB}: $domain${NC}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo -e "     ${WB}NGINX STATUS :${NC} $status_nginx    ${WB}sing-box STATUS :${NC} $status_singbox   "
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo -e "          ${WB}━━━━━ [ Bandwidth Monitoring ] ━━━━━${NC}" 
echo -e ""
echo -e "   ${GB}Today ($DATE)     Monthly ($(date +%B/%Y))${NC}  "
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10
echo -e "    ${GB}↓↓ Down: $dtoday          ↓↓ Down: $dmon${NC}   "
echo -e "    ${GB}↑↑ Up  : $utoday          ↑↑ Up  : $umon${NC}   "
echo -e "    ${GB}≈ Total: $ttoday          ≈ Total: $tmon${NC}   "
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo -e "                ${WB}━━━━━ [ sing-box Menu ] ━━━━━${NC}               "
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo -e " ${MB}[1]${NC} ${YB}Vmess Menu${NC}            ${MB}[4]${NC} ${YB}Socks5 Menu${NC}"
echo -e " ${MB}[2]${NC} ${YB}Vless Menu${NC}            ${MB}[5]${NC} ${YB}All sing-box Menu${NC}"
echo -e " ${MB}[3]${NC} ${YB}Trojan Menu${NC}           ${MB}[6]${NC} ${YB}Cert Acme.sh${NC}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo -e "                 ${WB}━━━━━ [ Utility ] ━━━━━${NC}                "
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo -e " ${MB}[7]${NC} ${YB}Log Create Account${NC}    ${MB}[10]${NC} ${YB}About Script${NC}"
echo -e " ${MB}[8]${NC} ${YB}Speedtest${NC}             ${MB}[11]${NC} ${YB}Update Menu${NC}"
echo -e " ${MB}[9]${NC} ${YB}Change Domain${NC}         ${MB}[12]${NC} ${YB}Update Core${NC}"
echo -e " ${MB}[x]${NC} ${YB}Exit${NC}                  ${MB}[13]${NC} ${YB}Add Bot notif${NC}"
echo -e " ${MB}[14]${NC} ${YB}bekup${NC}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo -e ""
echo -e " ${WB}Press [ ctrl + c ] or Input x To Exit Script${NC}"
echo -e ""
read -p " Select Menu :  "  opt
echo -e ""
case $opt in
1) clear ; vmess ;;
2) clear ; vless ;;
3) clear ; trojan ;;
4) clear ; socks ;;
5) clear ; allsing-box ;;
7) clear ; log-create ;;
8) clear ; speedtest ;;
9) clear ; dns ;;
6) clear ; certsing-box ;;
10) clear ; about ;;
12) clear ; bash <(curl -fsSL https://sing-box.app/deb-install.sh) ;;
11) clear ; bash <(curl -fsSL https://raw.githubusercontent.com/masjeho2/v1/sing-box/update.sh) ;;
13) clear ; bash <(curl -fsSL https://raw.githubusercontent.com/masjeho2/v1/sing-box/bot/add-bot.sh) ;;
14) clear ; bash <(curl -fsSL https://raw.githubusercontent.com/masjeho2/v1/sing-box/other/bekup.sh) ;;
x) exit ;;
*) echo -e "salah input" ; sleep 0.5 ; menu ;;
esac
