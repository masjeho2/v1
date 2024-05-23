domain=$(cat /etc/sing-box/domain)
CHATID="1658354197"
KEY="6860001875:AAEezcndU20DatRjLEhWnUYT9mP2ZVx9dkQ"
WKT="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
DATE_EXEC="$(date "+%d %b %Y %H:%M")"
tomem="$(free | awk '{print $2}' | head -2 | tail -n 1 )"
usmem="$(free | awk '{print $3}' | head -2 | tail -n 1 )"
cpu1="$(mpstat | awk '{print $4}' | head -4 |tail -n 1)"
cpu2="$(mpstat | awk '{print $6}' | head -4 |tail -n 1)"

persenmemori="$(echo "$usmem*100/$tomem" | bc)"
#persencpu=
persencpu="$(echo "scale=2; $cpu1+$cpu2" | bc)"
kirimtele=`cat<<EOF
$domain
$DATE_EXEC
RAM = $persenmemori%
CPU = $persencpu%

EOF`
if [ $persenmemori -gt 60 ]
then
    service nginx restart
    service sing-box restart
    pkill -f 'menu'
fi
TEXT="vps2 $kirimtele"
curl -s --max-time $WKT -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
