# socks5-openconnect-gp-docker
A docker image build for automatically login to GlobalProtect VPN with openconnect and set up a socks5 proxy for host use
## Build
```
docker build . -t my-vpn
```
## Prepare Run
docker automatic vpn login need a env file
```
VPN_USER=<user>
VPN_PWD=<pass>
VPN_GW=<gateway>
VPN_PORTAL=<portal url>
```
## Run
```
docker run --rm -d --cap-add NET_ADMIN --privileged -p 1080:1080 --env-file <env file> my-vpn
```

socks proxy will be running on 1080 port
