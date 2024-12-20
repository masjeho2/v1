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
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10
echo -e "               ${WB}━━━━━ [ Vless Menu ] ━━━━━${NC}               "
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10
echo -e ""
echo -e " ${MB}[1]${NC} ${YB}Create Account Vless${NC} "
echo -e " ${MB}[2]${NC} ${YB}Trial Account Vless${NC} "
echo -e " ${MB}[3]${NC} ${YB}Extend Account Vless${NC} "
echo -e " ${MB}[4]${NC} ${YB}Delete Account Vless${NC} "
echo -e " ${MB}[5]${NC} ${YB}Check User Login${NC} "
echo -e ""
echo -e " ${MB}[0]${NC} ${YB}Back To Menu${NC}"
echo -e ""
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | lolcat -a -d 10
echo -e ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in
    1)
        clear
        screen -dmS add-vless add-vless
        echo -e "add-vless is running in the background."
        exit
        ;;
    2)
        clear
        screen -dmS trialvless trialvless
        echo -e "trialvless is running in the background."
        exit
        ;;
    3)
        clear
        screen -dmS extend-vless extend-vless
        echo -e "extend-vless is running in the background."
        exit
        ;;
    4)
        clear
        screen -dmS del-vless del-vless
        echo -e "del-vless is running in the background."
        exit
        ;;
    5)
        clear
        screen -dmS cek-vless cek-vless
        echo -e "cek-vless is running in the background."
        exit
        ;;
    0)
        clear
        menu
        exit
        ;;
    x)
        exit
        ;;
    *)
        echo -e "salah tekan "
        sleep 1
        vless
        ;;
esac

