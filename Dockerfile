FROM alpine:3.11.2

ENV TZ=Asia/Shanghai
ENV SS_LIBEV_VERSION=3.3.3
ENV KCP_VERSION=20200103

RUN apk upgrade --no-cache && \
  apk add --no-cache bash tzdata libsodium privoxy && \
  apk add --no-cache --virtual .build-deps autoconf build-base curl libev-dev libtool linux-headers udns-dev libsodium-dev mbedtls-dev pcre-dev tar udns-dev && \
  curl -sSLO https://github.com/shadowsocks/shadowsocks-libev/releases/download/v$SS_LIBEV_VERSION/shadowsocks-libev-$SS_LIBEV_VERSION.tar.gz && \
  tar -zxf shadowsocks-libev-$SS_LIBEV_VERSION.tar.gz && \
  cd shadowsocks-libev-$SS_LIBEV_VERSION && \
  ./configure --prefix=/usr --disable-documentation && \
  make install && \
  cd ../ && \
  curl -sSLO https://github.com/xtaci/kcptun/releases/download/v$KCP_VERSION/kcptun-linux-amd64-$KCP_VERSION.tar.gz && \
  tar -zxf kcptun-linux-amd64-$KCP_VERSION.tar.gz && \
  mv server_linux_amd64 /usr/bin/kcptun && \
  mv client_linux_amd64 /usr/bin/kcptun-client && \
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  echo "Asia/Shanghai" > /etc/timezone && \
  runDeps="$( scanelf --needed --nobanner /usr/bin/ss-* | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | xargs -r apk info --installed | sort -u )" && \
  apk add --no-cache --virtual .run-deps $runDeps && \
  apk del .build-deps && \
  rm -rf client_linux_amd64 kcptun-linux-amd64-$KCP_VERSION.tar.gz shadowsocks-libev-$SS_LIBEV_VERSION.tar.gz shadowsocks-libev-$SS_LIBEV_VERSION /var/cache/apk/* && \
  chown privoxy.privoxy /etc/privoxy/*

ADD entrypoint.sh /entrypoint.sh
ADD privoxy.conf /etc/privoxy/config

ENTRYPOINT ["/entrypoint.sh"]
