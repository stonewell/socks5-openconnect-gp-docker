#!/bin/sh

/socks5 &
/gotty --permit-write --reconnect /run_tmux
