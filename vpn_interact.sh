#!/usr/bin/expect
set timeout -1

proc handle_challenge_code {} {
	expect -gl "Challenge: ";
	interact {
		"\n" {
			send -- "\r";
			return
		}
	}
}

proc handle_challenge {} {
	interact {
		"1\n" {
			send -- "1\r";
			handle_challenge_code
			return
		}
		"2\n" {
			send -- "2\r"";
			return
		}
		"3\n" {
			send -- "3\r"";
			handle_challenge_code
			return
		}
		"0\n" {
			send -- "0\r"";
			exit
		}
	}
}

spawn openconnect --protocol=gp "$env(VPN_PORTAL)" --csd-user=nobody --csd-wrapper=/libexec/openconnect/hipreport.sh

expect -gl "Username: "
send -- "$env(VPN_USER)\r"
expect -gl "Password: "
send -- "$env(VPN_PWD)\r"
expect -gl "Challenge: "
handle_challenge
expect -gl "GATEWAY: *:"
send -- "$env(VPN_GW)\r"
expect -gl "Password: "
send -- "$env(VPN_PWD)\r"
expect -gl "Challenge: "
handle_challenge

expect eof
