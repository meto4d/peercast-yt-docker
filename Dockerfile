FROM alpine:3.13.6
WORKDIR /root

RUN apk add --no-cache bash make gcc g++
RUN apk add --no-cache python3 ffmpeg librtmp
RUN apk add rtmpdump-dev binutils-gold ruby ruby-dev
RUN gem install json
RUN wget "https://github.com/plonk/peercast-yt/archive/refs/tags/v0.3.1.tar.gz" && \
	tar xzf v0.3.1.tar.gz && \
	rm v0.3.1.tar.gz
RUN sed -i -e "s/RUBYOPT='--disable-gems' .\/generate-html/.\/generate-html/g" peercast-yt-0.3.1/ui/Makefile
WORKDIR /root/peercast-yt-0.3.1/ui/linux
RUN make all

#RUN git clone https://github.com/plonk/peercast-yt.git
#RUN mkdir /lib64 && \
#	ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 && \
#	ln -s /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2

#RUN apk add --no-cache libc6-compat && \
#	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib64 && \
#	ln -s /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2
#
#RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
#    ALPINE_GLIBC_PACKAGE_VERSION="2.34-r0" && \
#    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
#    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
#    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
#    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
#	wget \
#        "https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub" \
#        -O "/etc/apk/keys/sgerrand.rsa.pub" && \
#	wget \
#        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
#        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
#        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
#	apk add --no-cache \
#        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
#        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
#        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
#    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
#    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true && \
#    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
#	apk del glibc-i18n && \
#    \
#    rm "/root/.wget-hsts" && \
#    apk del .build-dependencies && \
#    rm \
#        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
#        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
#        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"
#
#RUN wget https://github.com/plonk/peercast-yt/releases/download/v0.3.1/peercast-yt-linux-x86_64.tar.gz && \
#	tar xzf peercast-yt-linux-x86_64.tar.gz && \
#	rm peercast-yt-linux-x86_64.tar.gz

#RUN mkdir /lib64 && \
#	ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2
#RUN ln -s /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2



#FROM ubuntu:latest
#WORKDIR /root
#RUN apt-get update && \
#	apt-get install -y wget python3 ffmpeg librtmp1 && \
#	wget https://github.com/plonk/peercast-yt/releases/download/v0.3.1/peercast-yt-linux-x86_64.tar.gz && \
#	tar xzf peercast-yt-linux-x86_64.tar.gz && \
#	rm peercast-yt-linux-x86_64.tar.gz && \
#	apt-get purge -y wget && \
#	apt-get clean && \
#	rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
#
#ADD peercast.ini /root/peercast-yt
#ADD run.sh /root
#RUN mkdir -p /root/config
#
#CMD ["/root/run.sh"]
#