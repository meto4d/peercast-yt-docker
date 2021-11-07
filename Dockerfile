#FROM alpine:3.13.6
FROM frolvlad/alpine-glibc:alpine-3.13_glibc-2.33
ENV YT_VER=0.4.2 \
	ARCH=x86_64 \
	HOME_DIR=/root
WORKDIR ${HOME_DIR}
ENV YT_URL="https://github.com/plonk/peercast-yt/archive/refs/tags/v"${YT_VER}".tar.gz" \
	WORKDIR="./peercast-yt-"${YT_VER}""

#for tools
#RUN apk add --no-cache bash gdb vim

# setup
RUN \
	# for building peercast-yt
	apk add --no-cache make gcc g++ linux-headers rtmpdump-dev binutils-gold ruby ruby-json && \
	# for runing peercast-yt
	apk add --no-cache python3 ffmpeg librtmp openssl-dev libexecinfo libexecinfo-dev && \
	# download YT source
	wget -O - ${YT_URL} | tar zxvf - ; \
	# modify Source
		## not using glibc _GNU_SOURCE 
		if [ ${YT_VER//./} -ge 42 ]; then \
			sed -i -e 's/(_POSIX_C_SOURCE >= 200112L) \&\& ! _GNU_SOURCE/!defined(__GLIBC__) || ( (_POSIX_C_SOURCE >= 200112L) \&\& ! _GNU_SOURCE )/g' ${WORKDIR}/core/unix/strerror.cpp; \
			sed -i -e '1s/^/#include<limits.h>\n/' ${WORKDIR}/core/unix/usys.cpp; \
			sed -i -e 's/-DADD_BACKTRACE//' ${WORKDIR}/ui/linux/Makefile; \
		fi; \
		## bugfix for alpine pthread_mutex_lock
		sed -i -e 's/inData.lock.lock();/\/\/inData.lock.lock();/' ${WORKDIR}/core/common/pcp.h; \
		sed -i -e 's/outData.lock.lock();/\/\/outData.lock.lock();/' ${WORKDIR}/core/common/pcp.h; \
	# make
	#WORKDIR /root/peercast-yt-${YT_VER}/ui/linux 
	make -C ${WORKDIR}/ui/linux && \
	make install -C ${WORKDIR}/ui/linux && \
	# clean up
	apk del --no-cache make gcc g++ linux-headers rtmpdump-dev binutils-gold ruby ruby-json; \
	rm -rf ${WORKDIR}

#WORKDIR /peercast-yt
COPY --chmod=660 peercast.ini ${HOME_DIR}/.config/peercast/

#RUN ./peercast -i peercast.ini -P .
