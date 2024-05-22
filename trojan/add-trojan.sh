NC='\e[0m'
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'
clear
domain=$(cat /sing-box/domain)
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo -e "                  ${WB}Add Trojan Account${NC}                "
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
read -rp "User: " -e user
user_EXISTS=$(grep -w $user /sing-box/config.json | wc -l)
if [[ ${user_EXISTS} == '1' ]]; then
clear
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo -e "                  ${WB}Add Trojan Account${NC}                "
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
echo -e "${YB}A client with the specified name was already created, please choose another name.${NC}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10 
read -n 1 -s -r -p "Press any key to back on menu"
add-trojan
fi
done
uuid=$(cat /proc/sys/kernel/random/uuid | md5sum | cut -c -10)
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#trojan$/a\#& '"$user $exp"'\
},{"name": "'""$user""'", "password": "'""$uuid""'"' /sing-box/config.json
sed -i '/#trojan-grpc$/a\#& '"$user $exp"'\
},{"name": "'""$user""'", "password": "'""$uuid""'"' /sing-box/config.json
trojanlink1="trojan://$uuid@$domain:443?path=/trojan-ws&security=tls&host=$domain&type=ws&sni=$domain#$user"
trojanlink2="trojan://${uuid}@$domain:80?path=/trojan-ws&security=none&host=$domain&type=ws#$user"
trojanlink3="trojan://${uuid}@$domain:443?security=tls&encryption=none&type=grpc&serviceName=trojan-grpc&sni=$domain#$user"
ISP=$(cat /sing-box/org)
CITY=$(cat /sing-box/city)
cat > /var/www/html/trojan/trojan-$user.txt << END
____________________________________________________

           _____ [ sing-box / Trojan ] _____                 
____________________________________________________
Remarks       : $user
Host/IP       : $domain
ISP           : $ISP
City          : $CITY
Port TLS      : 443
Port NTLS     : 80
Port gRPC     : 443
Alt Port TLS  : 2053, 2083, 2087, 2096, 8443
Alt Port NTLS : 8080, 8880, 2052, 2082, 2086, 2095
Password      : $uuid
Network       : Websocket, gRPC
Path          : /trojan-ws
ServiceName   : trojan-grpc
Alpn          : h2, http/1.1
____________________________________________________
Expired On    : $exp
____________________________________________________


____________________________________________________
        _____ [ Trojan WS (CDN) TLS ] _____
____________________________________________________
- name: Trojan-$user
  server: $domain
  port: 443
  type: trojan
  password: $uuid
  network: ws
  sni: $domain
  skip-cert-verify: true
  udp: true
  ws-opts:
    path: /trojan-ws
    headers:
      Host: $domain


____________________________________________________
         _____ [ Trojan gRPC (CDN) ] _____
____________________________________________________
- name: Trojan-$user
  server: $domain
  port: 443
  type: trojan
  password: $uuid
  network: grpc
  sni: $domain
  skip-cert-verify: true
  udp: true
  grpc-opts:
    grpc-service-name: "trojan-grpc"


____________________________________________________
        _____ [ Link sing-box / Trojan ] _____
____________________________________________________
Link TLS  : trojan://$uuid@$domain:443?path=/trojan-ws&security=tls&host=$domain&type=ws&sni=$domain#$user
____________________________________________________
Link NTLS : trojan://${uuid}@$domain:80?path=/trojan-ws&security=none&host=$domain&type=ws#$user
____________________________________________________
Link gRPC : trojan://${uuid}@$domain:443?security=tls&encryption=none&type=grpc&serviceName=trojan-grpc&sni=$domain#$user
____________________________________________________
END
systemctl restart sing-box
clear
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /user/log-trojan-$user.txt
echo -e "━━━━━ [ sing-box / Trojan ] ━━━━━" | tee -a /user/log-trojan-$user.txt
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /user/log-trojan-$user.txt
echo -e "Remarks       : $user" | tee -a /user/log-trojan-$user.txt
echo -e "Host/IP       : $domain" | tee -a /user/log-trojan-$user.txt
echo -e "ISP           : $ISP" | tee -a /user/log-trojan-$user.txt
echo -e "City          : $CITY" | tee -a /user/log-trojan-$user.txt
echo -e "Port TLS      : 443" | tee -a /user/log-trojan-$user.txt
echo -e "Port NTLS     : 80" | tee -a /user/log-trojan-$user.txt
echo -e "Port gRPC     : 443" | tee -a /user/log-trojan-$user.txt
echo -e "Alt Port TLS  : 2053, 2083, 2087, 2096, 8443" | tee -a /user/log-trojan-$user.txt
echo -e "Alt Port NTLS : 8080, 8880, 2052, 2082, 2086, 2095" | tee -a /user/log-trojan-$user.txt
echo -e "Password      : $uuid" | tee -a /user/log-trojan-$user.txt
echo -e "Network       : Websocket, gRPC" | tee -a /user/log-trojan-$user.txt
echo -e "Path          : /trojan-ws" | tee -a /user/log-trojan-$user.txt
echo -e "ServiceName   : trojan-grpc" | tee -a /user/log-trojan-$user.txt
echo -e "Alpn          : h2, http/1.1" | tee -a /user/log-trojan-$user.txt
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /user/log-trojan-$user.txt
echo -e "Link TLS      : $trojanlink1" | tee -a /user/log-trojan-$user.txt
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /user/log-trojan-$user.txt
echo -e "Link NTLS     : $trojanlink2" | tee -a /user/log-trojan-$user.txt
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /user/log-trojan-$user.txt
echo -e "Link gRPC     : $trojanlink3" | tee -a /user/log-trojan-$user.txt
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /user/log-trojan-$user.txt
echo -e "Format Clash  : http://$domain:8000/trojan/trojan-$user.txt" | tee -a /user/log-trojan-$user.txt
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /user/log-trojan-$user.txt
echo -e "Expired On    : $exp" | tee -a /user/log-trojan-$user.txt
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /user/log-trojan-$user.txt
echo " " | tee -a /user/log-trojan-$user.txt
echo " " | tee -a /user/log-trojan-$user.txt
echo " " | tee -a /user/log-trojan-$user.txt
read -n 1 -s -r -p "Press any key to back on menu"
clear
trojan
