ARG GOLANG_VERSION="1.19.1"

#Get socks5
FROM serjs/go-socks5-proxy:latest as socks5_builder

#Build openconnect
FROM alpine as openconnect_builder
RUN apk add --no-cache build-base vpnc iproute2 autoconf automake intltool \
	gnutls-dev libxml2-dev krb5-dev lz4-dev libproxy-dev linux-headers stoken-dev pcsc-lite-dev oath-toolkit-dev python3-dev \
	libtool git

RUN git clone git://git.infradead.org/users/dwmw2/openconnect.git /openconnect

WORKDIR /openconnect
RUN ./autogen.sh && \
    ./configure --with-gnutls --prefix=/openconnect-install && \
    make install

# Build gotty
FROM golang:$GOLANG_VERSION-alpine as gotty_builder
RUN apk add --no-cache go git build-base
RUN  mkdir -p /tmp/gotty && \
	 GOPATH=/tmp/gotty go install github.com/sorenisanerd/gotty@latest && \
	 mv /tmp/gotty/bin/gotty /usr/local/bin/ && \
	 apk del go git build-base && \
	 rm -rf /tmp/gotty

# Build VPN
FROM alpine

COPY --from=socks5_builder /socks5 /
COPY --from=openconnect_builder /openconnect-install /
COPY --from=gotty_builder /usr/local/bin/gotty /
RUN apk add --no-cache expect gnutls \
    iproute2 \
    krb5-libs \
    libcrypto3 \
    libproxy \
    libssl3 \
    libxml2 \
    lz4-libs \
    musl \
    oath-toolkit-libpskc \
    pcsc-lite-libs \
    stoken \
    vpnc \
    zlib

ADD vpn_interact.sh /
RUN chmod +x /vpn_interact.sh

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
