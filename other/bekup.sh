#!/bin/bash

# Mendapatkan domain dari file /usr/local/etc/xray/domain
domain=$(cat /usr/local/etc/xray/domain)

# Mendapatkan chat ID dari file .bot.db
CHATID=$(grep -E "^#bot# " "/etc/bot/.bot.db" | cut -d ' ' -f 3)
KEY="7175139538:AAEVAER74yWldaNyMA9euH2gg4IiJ3f09AM"
WKT="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
URL_FILE="https://api.telegram.org/bot$KEY/sendDocument"
DATE_EXEC="$(date "+%d %b %Y %H:%M")"

# Pesan yang akan dikirimkan ke Telegram
kirimtele=$(cat <<EOF
$domain
$DATE_EXEC
EOF
)

# Membuat backup dari config.json
backup_dir="/usr/local/etc/xray/backup"
mkdir -p "$backup_dir"
backup_file="$backup_dir/config_${domain}_$(date "+%Y%m%d%H%M%S" | tr -d ':').json"
cp /usr/local/etc/xray/config.json "$backup_file"

# Mengirimkan pesan ke Telegram
TEXT="vps $kirimtele"
curl -s --max-time "$WKT" -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" "$URL" >/dev/null

# Mengirimkan file backup ke Telegram
response=$(curl -s -o /dev/null -w "%{http_code}" -F "chat_id=$CHATID" -F "document=@$backup_file" "$URL_FILE")

# Memeriksa apakah pengiriman file berhasil dan menghapus file lokal jika berhasil
if [ "$response" -eq 200 ]; then
    rm -f "$backup_file"
fi
