#!/usr/bin/expect
set timeout -1

spawn openconnect --protocol=gp "$env(VPN_PORTAL)" --csd-user=nobody --csd-wrapper=/libexec/openconnect/hipreport.sh

expect -gl "Username: "
send -- "$env(VPN_USER)\r"
expect -gl "Password: "
send -- "$env(VPN_PWD)\r"
interact
