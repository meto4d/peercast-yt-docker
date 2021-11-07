#FROM alpine:3.13.6
FROM frolvlad/alpine-glibc:alpine-3.13_glibc-2.33
WORKDIR /peercast-yt-source
ENV YT_VER=0.4.2 \
	ARCH=x86_64
ENV YT_URL="https://github.com/plonk/peercast-yt/archive/refs/tags/v"${YT_VER}".tar.gz"

#for tools
RUN apk add --no-cache bash gdb vim

# for building peercast-yt
RUN apk add --no-cache make gcc g++ linux-headers rtmpdump-dev binutils-gold ruby ruby-dev
# libc-dev musl-dev

# for peercast-yt
RUN apk add --no-cache python3 ffmpeg librtmp openssl-dev libexecinfo libexecinfo-dev

# download YT source
RUN wget -O - ${YT_URL} | \
	tar zxvf - 
WORKDIR /peercast-yt-source/peercast-yt-${YT_VER}

# modify Makefile for ruby
RUN sed -i -e "s/RUBYOPT='--disable-gems'//g" ui/Makefile
RUN gem install json

# modify Source
## not using glibc _GNU_SOURCE 
RUN if [ ${YT_VER//./} -ge 42 ]; then \
	sed -i -e 's/(_POSIX_C_SOURCE >= 200112L) && ! _GNU_SOURCE/!defined(__GLIBC__) || ( (_POSIX_C_SOURCE >= 200112L) && ! _GNU_SOURCE )/g' core/unix/strerror.cpp; \
	sed -i -e '1s/^/#include<limits.h>\n/' core/unix/usys.cpp; \
	sed -i -e 's/-DADD_BACKTRACE//' ui/linux/Makefile; \
fi

# temp bugfix
RUN sed -i -e 's/delete cs//g' core/common/channel.cpp

# make
WORKDIR /peercast-yt-source/peercast-yt-${YT_VER}/ui/linux
#RUN make
#WORKDIR /
#RUN tar xvzf /peercast-yt-source/peercast-yt-${YT_VER}/ui/linux/peercast-yt-linux-${ARCH}.tar.gz

WORKDIR /peercast-yt
COPY --chmod=660 peercast.ini .

#RUN ./peercast -i peercast.ini -P .
