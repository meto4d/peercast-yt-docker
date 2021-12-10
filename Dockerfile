#FROM alpine:3.13.6
FROM frolvlad/alpine-glibc:alpine-3.13_glibc-2.33 AS builder
ENV YT_VER=0.3.8 \
	ARCH=x86_64
WORKDIR /
ENV YT_URL="https://github.com/plonk/peercast-yt/archive/refs/tags/v"${YT_VER}".tar.gz" \
	YT_DIR="peercast-yt-"${YT_VER}""

# setup
RUN set -x && \
	addgroup -g 7144 -S peercast && \
	adduser -S -D -u 7144 -h /home/peercast -s /sbin/nologin -G peercast -g peercast peercast && \
	if [ "${ARCH}" != "$(uname -m | tr A-Z a-z)" ]; then \
		echo "check 'ARCH' value as cpu architexture type"; \
		exit 1; \
	fi; \
	# for building peercast-yt
	apk add --no-cache --virtual .buildtools  make gcc g++ linux-headers rtmpdump-dev binutils-gold ruby ruby-json openssl-dev libexecinfo libexecinfo-dev && \
	# for runing peercast-yt
	apk add --no-cache python3 ffmpeg librtmp && \
	# switch user
	su -s /bin/sh - peercast -c " \
		# download YT source
		wget -O - ${YT_URL} | tar zxvf - -C /home/peercast/ && \
		# modify source
			## not using glibc _GNU_SOURCE 
			if [ ${YT_VER//./} -eq 42 ]; then \
				sed -i -e 's/(_POSIX_C_SOURCE >= 200112L) \&\& ! _GNU_SOURCE/!defined(__GLIBC__) || ( (_POSIX_C_SOURCE >= 200112L) \&\& ! _GNU_SOURCE )/g' /home/peercast/${YT_DIR}/core/unix/strerror.cpp; \
			fi; \
			if [ ${YT_VER//./} -ge 37 ] && [ ${YT_VER//./} -le 42 ]; then \
				sed -i -e '1s/^/#include<limits.h>\n/' /home/peercast/${YT_DIR}/core/unix/usys.cpp; \
				sed -i -e 's/-DADD_BACKTRACE//' /home/peercast/${YT_DIR}/ui/linux/Makefile; \
			fi; \
			## bugfix for alpine pthread_mutex_lock
			sed -i -e 's/inData.lock.lock();/\/\/inData.lock.lock();/' /home/peercast/${YT_DIR}/core/common/pcp.h; \
			sed -i -e 's/outData.lock.lock();/\/\/outData.lock.lock();/' /home/peercast/${YT_DIR}/core/common/pcp.h; \
		# make
		#WORKDIR /root/peercast-yt-${YT_VER}/ui/linux 
		make -C /home/peercast/${YT_DIR}/ui/linux && \
		tar xzf /home/peercast/${YT_DIR}/ui/linux/peercast-yt-linux-${ARCH}.tar.gz -C /home/peercast/ \
	" && \
## make installの廃止 - build用イメージ対応のため
##	if [ ${YT_VER//./} -lt 37 ]; then \
##		tar xzf ${WORKDIR}/ui/linux/peercast-yt-linux-${ARCH}.tar.gz -C /home/peercast/ && \
##	else \
##		make install -C ${WORKDIR}/ui/linux && \
##	fi; \
	# mv tarball
	mv /home/peercast/${YT_DIR}/ui/linux/peercast-yt-linux-${ARCH}.tar.gz / && \
	# clean up
	apk del .buildtools && \
	#rm -rf ${WORKDIR} && \
	echo "finish building"

#WORKDIR /peercast-yt
COPY --chmod=660 --chown=peercast:peercast peercast.ini /home/peercast/.config/peercast/
WORKDIR /home/peercast
USER peercast:peercast
CMD ["peercast-yt/peercast", "-i", ".config/peercast/peercast.ini", "-P", "peercast-yt"]
# ---with-sources image

FROM alpine:3.13.6
ENV YT_VER=0.3.8 \
	ARCH=x86_64
COPY --from=builder /peercast-yt-linux-${ARCH}.tar.gz /
RUN set -x && \
	# peercast user
	addgroup -g 7144 -S peercast && \
	adduser -S -D -u 7144 -h /home/peercast -s /sbin/nologin -G peercast -g peercast peercast && \
	# install run tools
	apk add --no-cache python3 ffmpeg librtmp && \
	# switch user and untar
	su -s /bin/sh - peercast -c \
		"tar xzf /peercast-yt-linux-${ARCH}.tar.gz -C /home/peercast" && \
	# clean up
	rm /peercast-yt-linux-${ARCH}.tar.gz

USER peercast:peercast
COPY --chmod=660 --chown=peercast:peercast peercast.ini /home/peercast/.config/peercast/
WORKDIR /home/peercast
CMD ["peercast-yt/peercast", "-i", ".config/peercast/peercast.ini", "-P", "peercast-yt"]
