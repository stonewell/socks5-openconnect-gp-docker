#!/bin/sh

/socks5 &
/gotty --permit-write --reconnect /vpn_interact.sh
