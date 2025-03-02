#!/bin/bash

# Pastikan TERM diatur untuk mencegah error
export TERM=xterm

# Mendapatkan tanggal sekarang
now=$(date +"%Y-%m-%d")

# Fungsi untuk memproses data berdasarkan karakter prefix
process_data() {
    local prefix="$1"
    local path="$2"

    # Ambil daftar pengguna berdasarkan prefix
    data=($(grep "^$prefix" /etc/sing-box/config.json | cut -d ' ' -f 2 | sort | uniq))

    # Proses setiap pengguna
    for user in "${data[@]}"; do
        exp=$(grep -w "^$prefix $user" "/etc/sing-box/config.json" | cut -d ' ' -f 3 | sort | uniq)
        d1=$(date -d "$exp" +%s)
        d2=$(date -d "$now" +%s)
        exp2=$(((d1 - d2) / 86400))

        # Hapus data jika sudah kadaluarsa
        if [[ "$exp2" -le 0 ]]; then
            sed -i "/^$prefix $user $exp/,/^},{/d" /etc/sing-box/config.json
            rm -f /var/www/html/$path/$path-$user.txt
            rm -f /user/log-$path-$user.txt
            rm -f /var/www/html/$path/$path-$user-tls.png
            rm -f /var/www/html/$path/$path-$user-ntls.png
            rm -f /var/www/html/$path/$path-$user-grpc.png
            rm -f /var/www/html/$path/$path-$user-iflix.png
            rm -f /var/www/html/$path/$path-$user-video.png
            rm -rf /var/www/html/$path/$path-$user-opok.png


        fi
    done
}

# Jalankan fungsi untuk setiap tipe pengguna
process_data "#@" "vmess"
process_data "#=" "vless"
process_data "#&" "trojan"
process_data "#!" "shadowsocks"
process_data "#%" "shadowsocks2022"
process_data "#÷" "socks5"
process_data "#&@" "allsing-box"

# Restart layanan sing-box
systemctl restart sing-box
systemctl daemon-reload