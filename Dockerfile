ARG GOLANG_VERSION="1.19.1"

FROM golang:$GOLANG_VERSION-alpine as builder
RUN apk --no-cache add tzdata git
WORKDIR /go/src/github.com/serjs/socks5

RUN git clone https://github.com/serjs/socks5-server.git .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-s' -o ./socks5

WORKDIR /go/src/github.com/stonewell/vpn-websocketd
RUN git clone https://github.com/stonewell/socks5-openconnect-gp-docker.git .
RUN cd vpn-websocketd && go build -o ./vpn-websocketd

FROM alpine as builder-openconnect
RUN apk add --no-cache build-base vpnc iproute2 autoconf automake intltool \
	gnutls-dev libxml2-dev krb5-dev lz4-dev libproxy-dev linux-headers stoken-dev pcsc-lite-dev oath-toolkit-dev python3-dev \
	libtool git

RUN git clone git://git.infradead.org/users/dwmw2/openconnect.git /openconnect

WORKDIR /openconnect
RUN ./autogen.sh && \
    ./configure --with-gnutls --prefix=/openconnect-install && \
    make install

FROM alpine

COPY --from=builder /go/src/github.com/serjs/socks5/socks5 /
COPY --from=builder /go/src/github.com/stonewell/vpn-websocketd/vpn-websocketd/vpn-websocketd /
COPY --from=builder /go/src/github.com/stonewell/vpn-websocketd/vpn-websocketd/index.html /
COPY --from=builder-openconnect /openconnect-install /
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

ADD vpn.sh /
RUN chmod +x /vpn.sh

ADD vpn_interact.sh /
RUN chmod +x /vpn_interact.sh

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
