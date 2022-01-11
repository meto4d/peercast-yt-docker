#FROM alpine:3.15
FROM frolvlad/alpine-glibc:alpine-3.15_glibc-2.33 AS builder
ENV YT_VER=0.4.3 \
	ARCH=x86_64
WORKDIR /
ENV YT_URL="https://github.com/plonk/peercast-yt/archive/refs/tags/v"${YT_VER}".tar.gz" \
	YT_DIR="peercast-yt-"${YT_VER}""

# setup
RUN set -x && \
	# peercast user
	addgroup -g 7144 -S peercast && \
	adduser -S -D -u 7144 -h /home/peercast -s /sbin/nologin -G peercast -g peercast peercast && \
	# check ARCH type
	if [ "${ARCH}" != "$(uname -m | tr A-Z a-z)" ]; then \
		echo "check 'ARCH' value as cpu architexture type"; \
		exit 1; \
	fi; \
	# for building peercast-yt
	apk add --no-cache --virtual .buildtools  make gcc g++ linux-headers rtmpdump-dev binutils-gold ruby ruby-json openssl-dev libexecinfo libexecinfo-dev libunwind libunwind-dev && \
	# for runing peercast-yt
	apk add --no-cache python3 ffmpeg librtmp && \
	# switch user
	su -s /bin/sh - peercast -c " \
		# download YT source
		wget -O - ${YT_URL} | tar zxvf - && \
		# modify source
			## with backtrace
			sed -i -e 's/LDFLAGS = -fuse-ld=gold -pthread -rdynamic/LDFLAGS = -fuse-ld=gold -pthread -rdynamic -lunwind -lexecinfo/' /home/peercast/${YT_DIR}/ui/linux/Makefile; \
			## without backtrace
			#sed -i -e 's/-DADD_BACKTRACE//' /home/peercast/${YT_DIR}/ui/linux/Makefile; \
		# make
		#WORKDIR /root/peercast-yt-${YT_VER}/ui/linux 
		make -C /home/peercast/${YT_DIR}/ui/linux && \
		tar xzf /home/peercast/${YT_DIR}/ui/linux/peercast-yt-linux-${ARCH}.tar.gz -C /home/peercast/ \ 
	" && \
	# mv tarball
	mv /home/peercast/${YT_DIR}/ui/linux/peercast-yt-linux-${ARCH}.tar.gz / && \
	# clean up
	apk del .buildtools && \
	#rm -rf ${WORKDIR} && \
	echo "finish building"

#WORKDIR /peercast-yt
COPY --chmod=660 --chown=peercast:peercast peercast.ini /home/peercast/.config/peercast/
WORKDIR /home/peercast/
USER peercast:peercast
CMD ["peercast-yt/peercast", "-i", ".config/peercast/peercast.ini", "-P", "peercast-yt"]
# ---with-sources image

FROM alpine:3.15.0
ENV YT_VER=0.4.3 \
	ARCH=x86_64
COPY --from=builder /peercast-yt-linux-${ARCH}.tar.gz /
RUN set -x && \
	# peercast user
	addgroup -g 7144 -S peercast && \
	adduser -S -D -u 7144 -h /home/peercast -s /sbin/nologin -G peercast -g peercast peercast && \
	# install run tools
	apk add --no-cache python3 ffmpeg librtmp && \
	## install lib backtrace
	apk add libexecinfo libunwind && \
	# switch user and untar
	su -s /bin/sh - peercast -c \
		"tar xzf /peercast-yt-linux-${ARCH}.tar.gz -C /home/peercast" && \
	# clean up
	rm /peercast-yt-linux-${ARCH}.tar.gz

COPY --chmod=660 --chown=peercast:peercast peercast.ini /home/peercast/.config/peercast/
WORKDIR /home/peercast/
USER peercast:peercast
CMD ["peercast-yt/peercast", "-i", ".config/peercast/peercast.ini", "-P", "peercast-yt"]
