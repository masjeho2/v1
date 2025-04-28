NC='\e[0m'
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'
CHATID=$(grep -E "^#bot# " "/etc/bot/.bot.db" | cut -d ' ' -f 3)
KEY=$(grep -E "^#bot# " "/etc/bot/.bot.db" | cut -d ' ' -f 2)
export TIME="10"
export URL="https://api.telegram.org/bot$KEY/sendMessage"
clear
domain=$(cat /etc/sing-box/domain)
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo -e "                  ${WB}Add Vless Account${NC}                 "
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
read -rp "User: " -e user
CLIENT_EXISTS=$(grep -w $user /etc/sing-box/config.json | wc -l)
if [[ ${CLIENT_EXISTS} == '1' ]]; then
clear
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo -e "                  Add Vless Account                 "
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo -e "${YB}A client with the specified name was already created, please choose another name.${NC}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
read -n 1 -s -r -p "Press any key to back on menu"
add-vless
fi
done
# Prompt for UUID or generate a random one if not provided
while true; do
  read -p "Enter UUID (leave blank to generate a random one): " uuid
  if [[ -z "$uuid" ]]; then
    uuid=$(cat /proc/sys/kernel/random/uuid)
  fi
  UUID_EXISTS=$(grep -w $uuid /etc/sing-box/config.json | wc -l)
  if [[ ${UUID_EXISTS} == '0' ]]; then
    break
  else
    echo -e "${YB}The UUID already exists, please enter a new one or leave blank to generate a random one.${NC}"
  fi
done

read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vless$/a\#= '"$user $exp"'\
},{"name": "'""$user""'", "uuid": "'""$uuid""'"' /etc/sing-box/config.json
sed -i '/#vless-grpc$/a\#= '"$user $exp"'\
},{"name": "'""$user""'", "uuid": "'""$uuid""'"' /etc/sing-box/config.json
vlesslink1="vless://$uuid@$domain:443?path=/vless-ws&security=tls&encryption=none&host=$domain&type=ws&sni=$domain#$user"
vlesslink2="vless://$uuid@$domain:80?path=/vless-ws&security=none&encryption=none&host=$domain&type=ws#$user"
vlesslink3="vless://$uuid@$domain:443?security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=$domain#$user"
vlesslink4="vless://$uuid@$domain:443?path=/vless-ws&security=tls&encryption=none&host=$domain&type=ws&sni=access.iflix.com#$user"
vlesslink5="vless://$uuid@$domain:443?path=/vless-ws&security=tls&encryption=none&host=$domain&type=ws&sni=static-web.prod.vidiocdn.com#$user"
vlesslink6="vless://$uuid@$domain:443?path=/vless-ws&security=tls&encryption=none&host=$domain&type=ws&sni=edge-ig-mqtt-p4-shv-01-gua1.facebook.com#$user"
vlesslink7="vless://$uuid@$domain:443?path=/vless-ws&security=tls&encryption=none&host=$domain&type=ws&sni=z-p15.www.instagram.com#$user"
vlesslink8="vless://$uuid@ava.game.naver.com:443?path=/vless-ws&security=tls&encryption=none&host=ava.game.naver.com.$domain&type=ws&sni=ava.game.naver.com.$domain#$user"

ISP=$(cat /etc/sing-box/org)
CITY=$(cat /etc/sing-box/city)
cat > /var/www/html/vless/vless-$user.txt << END
____________________________________________________

           _____ [ sing-box / Vless ] _____                 
____________________________________________________
Remarks       : $user
Domain        : $domain
ISP           : $ISP
City          : $CITY
Port TLS      : 443
Port NTLS     : 80
Port gRPC     : 443
Alt Port TLS  : 2053, 2083, 2087, 2096, 8443
Alt Port NTLS : 8080, 8880, 2052, 2082, 2086, 2095
id            : $uuid
Encryption    : none
Network       : Websocket, gRPC
Path          : /vless-ws
ServiceName   : vless-grpc
Alpn          : h2, http/1.1
____________________________________________________
Expired On    : $exp
____________________________________________________


____________________________________________________
         _____ [ Vless WS (CDN) TLS ] _____                 
____________________________________________________
- name: Vless-$user
  type: vless
  server: $domain
  port: 443
  uuid: $uuid
  cipher: auto
  udp: true
  tls: true
  skip-cert-verify: true
  servername: $domain
  network: ws
  ws-opts:
    path: /vless-ws
    headers:
      Host: $domain


____________________________________________________
           _____ [ Vless WS (CDN) ] _____
____________________________________________________
- name: Vless-$user
  type: vless
  server: $domain
  port: 80
  uuid: $uuid
  cipher: auto
  udp: true
  tls: false
  skip-cert-verify: false
  network: ws
  ws-opts:
    path: /vless-ws
    headers:
      Host: $domain


____________________________________________________
          _____ [ Vless gRPC (CDN) ] _____
____________________________________________________
- name: Vless-$user
  server: $domain
  port: 443
  type: vless
  uuid: $uuid
  cipher: auto
  network: grpc
  tls: true
  servername: $domain
  skip-cert-verify: true
  grpc-opts:
  grpc-service-name: "vless-grpc"


____________________________________________________
             _____ [ Link Vless ] _____
____________________________________________________
Link TL   : vless://$uuid@$domain:443?path=/vless-ws&security=tls&encryption=none&host=$domain&type=ws&sni=$domain#$user
____________________________________________________
Link TL   : vless://$uuid@$domain:443?path=/vless-ws&security=tls&encryption=none&host=$domain&type=ws&sni=access.iflix.com#$user
____________________________________________________
Link TL   : vless://$uuid@$domain:443?path=/vless-ws&security=tls&encryption=none&host=$domain&type=ws&sni=static-web.prod.vidiocdn.com#$user
____________________________________________________
Link NTLS : vless://$uuid@$domain:80?path=/vless-ws&security=none&encryption=none&host=$domain&type=ws#$user
____________________________________________________
Link gRPC : vless://$uuid@$domain:443?security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=$domain#$user
____________________________________________________
END


clear
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /user/log-vless-$user.txt
echo -e "━━━━━ [ sing-box / Vless ] ━━━━━" | tee -a /user/log-vless-$user.txt
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /user/log-vless-$user.txt
echo -e "Remarks       : $user" | tee -a /user/log-vless-$user.txt
echo -e "Domain        : $domain" | tee -a /user/log-vless-$user.txt
echo -e "ISP           : $ISP" | tee -a /user/log-vless-$user.txt
echo -e "City          : $CITY" | tee -a /user/log-vless-$user.txt
echo -e "Port TLS      : 443" | tee -a /user/log-vless-$user.txt
echo -e "Port NTLS     : 80" | tee -a /user/log-vless-$user.txt
echo -e "Port gRPC     : 443" | tee -a /user/log-vless-$user.txt
echo -e "Alt Port TLS  : 2053, 2083, 2087, 2096, 8443" | tee -a /user/log-vless-$user.txt
echo -e "Alt Port NTLS : 8080, 8880, 2052, 2082, 2086, 2095" | tee -a /user/log-vless-$user.txt
echo -e "id            : $uuid" | tee -a /user/log-vless-$user.txt
echo -e "Encryption    : none" | tee -a /user/log-vless-$user.txt
echo -e "Network       : Websocket, gRPC" | tee -a /user/log-vless-$user.txt
echo -e "Path          : /vless" | tee -a /user/log-vless-$user.txt
echo -e "ServiceName   : vless-grpc" | tee -a /user/log-vless-$user.txt
echo -e "Alpn          : h2, http/1.1" | tee -a /user/log-vless-$user.txt
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /user/log-vless-$user.txt
echo -e "Link TLS      : $vlesslink1" | tee -a /user/log-vless-$user.txt
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /user/log-vless-$user.txt
echo -e "Link TLS iflix: $vlesslink4" | tee -a /user/log-vless-$user.txt
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /user/log-vless-$user.txt
echo -e "Link TLS video: $vlesslink5" | tee -a /user/log-vless-$user.txt
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /user/log-vless-$user.txt
echo -e "Link NTLS     : $vlesslink2" | tee -a /user/log-vless-$user.txt
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /user/log-vless-$user.txt
echo -e "Link gRPC     : $vlesslink3" | tee -a /user/log-vless-$user.txt
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /user/log-vless-$user.txt
echo -e "Format Clash  : http://$domain:8000/vless/vless-$user.txt" | tee -a /user/log-vless-$user.txt
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /user/log-vless-$user.txt
echo -e "Expired On    : $exp" | tee -a /user/log-vless-$user.txt
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /user/log-vless-$user.txt
echo " " | tee -a /user/log-vless-$user.txt
echo " " | tee -a /user/log-vless-$user.txt
echo " " | tee -a /user/log-vless-$user.txt
isi=$(cat /user/log-vless-$user.txt | jq -sRr @uri)
CHATID="$CHATID"
KEY="$KEY"
TIME="$TIME"
URL="$URL"
TEXT="$isi"
curl -s --max-time $TIME -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
# Generate QR code for each link
qrencode -o /var/www/html/vless/vless-$user-tls.png "$vlesslink1" >/dev/null 2>&1
qrencode -o /var/www/html/vless/vless-$user-ntls.png "$vlesslink2" >/dev/null 2>&1
qrencode -o /var/www/html/vless/vless-$user-grpc.png "$vlesslink3" >/dev/null 2>&1
qrencode -o /var/www/html/vless/vless-$user-iflix.png "$vlesslink4" >/dev/null 2>&1
qrencode -o /var/www/html/vless/vless-$user-video.png "$vlesslink5" >/dev/null 2>&1
qrencode -o /var/www/html/vless/vless-$user-facebook.png "$vlesslink6" >/dev/null 2>&1
qrencode -o /var/www/html/vless/vless-$user-instagram.png "$vlesslink7" >/dev/null 2>&1
qrencode -o /var/www/html/vless/vless-$user-wa.png "$vlesslink8" >/dev/null 2>&1



# Send QR codes to Telegram
curl -s -X POST "https://api.telegram.org/bot$KEY/sendPhoto" -F chat_id="$CHATID" -F photo="@/var/www/html/vless/vless-$user-tls.png" -F caption="Link TLS: $vlesslink1" >/dev/null 2>&1
curl -s -X POST "https://api.telegram.org/bot$KEY/sendPhoto" -F chat_id="$CHATID" -F photo="@/var/www/html/vless/vless-$user-ntls.png" -F caption="Link NTLS: $vlesslink2" >/dev/null 2>&1
curl -s -X POST "https://api.telegram.org/bot$KEY/sendPhoto" -F chat_id="$CHATID" -F photo="@/var/www/html/vless/vless-$user-grpc.png" -F caption="Link gRPC: $vlesslink3" >/dev/null 2>&1
curl -s -X POST "https://api.telegram.org/bot$KEY/sendPhoto" -F chat_id="$CHATID" -F photo="@/var/www/html/vless/vless-$user-iflix.png" -F caption="Link TLS iflix: $vlesslink4" >/dev/null 2>&1
curl -s -X POST "https://api.telegram.org/bot$KEY/sendPhoto" -F chat_id="$CHATID" -F photo="@/var/www/html/vless/vless-$user-video.png" -F caption="Link TLS video: $vlesslink5" >/dev/null 2>&1
curl -s -X POST "https://api.telegram.org/bot$KEY/sendPhoto" -F chat_id="$CHATID" -F photo="@/var/www/html/vless/vless-$user-facebook.png" -F caption="Link TLS facebook: $vlesslink6" >/dev/null 2>&1
curl -s -X POST "https://api.telegram.org/bot$KEY/sendPhoto" -F chat_id="$CHATID" -F photo="@/var/www/html/vless/vless-$user-instagram.png" -F caption="Link TLS instagram: $vlesslink7" >/dev/null 2>&1
curl -s -X POST "https://api.telegram.org/bot$KEY/sendPhoto" -F chat_id="$CHATID" -F photo="@/var/www/html/vless/vless-$user-wa.png" -F caption="Link TLS wa: $vlesslink8" >/dev/null 2>&1


sleep 2
systemctl restart sing-box
read -n 1 -s -r -p "Press any key to back on menu"
clear
vless
