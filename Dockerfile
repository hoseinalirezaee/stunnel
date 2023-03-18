FROM ubuntu:22.04 AS builder

ARG VERSION=5.69

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /temp

WORKDIR /the/workdir/path

RUN wget https://www.stunnel.org/downloads/stunnel-${VERSION}.tar.gz && \
    tar -xf stunnel-${VERSION}.tar.gz && \
    cd stunnel-${VERSION} && \
    ./configure --prefix=/home/stunnel \
                --disable-systemd && \
    make && make install

FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN set -x \
    && addgroup --system stunnel \
    && adduser --system --ingroup stunnel --disabled-login stunnel

COPY --from=builder /home/stunnel /home/stunnel

USER stunnel:stunnel

ENTRYPOINT [ "/home/stunnel/bin/stunnel" ]
CMD [ "/home/stunnel/etc/stunnel.conf" ]
