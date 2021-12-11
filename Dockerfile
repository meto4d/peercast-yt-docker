FROM centos:centos7 AS builder
ENV YT_VER=0.4.2 \
	ARCH=x86_64
WORKDIR /
ENV YT_URL="https://github.com/plonk/peercast-yt/archive/refs/tags/v"${YT_VER}".tar.gz" \
	YT_DIR="peercast-yt-"${YT_VER}""
# setup
RUN set -x && \
	# peercast user
	groupadd -g 7144 --system peercast && \
	useradd -u 7144 -m -d /home/peercast -s /sbin/nologin -G peercast -g peercast peercast && \
	# check ARCH type
	if [ "${ARCH}" != "$(uname -m | tr A-Z a-z)" ]; then \
		echo "check 'ARCH' value as cpu architexture type"; \
		exit 1; \
	fi; \
	# install package
	yum -y update && \
	# install build tools
	yum -y install make ruby openssl-devel centos-release-scl && \
	#install devtoolset-7 && \
	yum -y install devtoolset-7-gcc devtoolset-7-gcc-c++ && \
	# install run tools
	yum -y install https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm && \
	yum -y install python3 ffmpeg librtmp librtmp-devel && \
	# switch user
	su -s /bin/sh - peercast -c " \
		# download
		curl -s -L ${YT_URL} | tar zxvf - && \
		# build
		source scl_source enable devtoolset-7 && \
		make -C /home/peercast/${YT_DIR}/ui/linux && \
		tar xzf /home/peercast/${YT_DIR}/ui/linux/peercast-yt-linux-${ARCH}.tar.gz -C /home/peercast/ \
	" && \
	# mv tarball
	mv /home/peercast/${YT_DIR}/ui/linux/peercast-yt-linux-${ARCH}.tar.gz / && \
	# clean up
	yum -y erase devtoolset-7-gcc devtoolset-7-gcc-c++ make ruby openssl-devel centos-release-scl librtmp-devel && \
	yum clean all;

COPY --chmod=660 --chown=peercast:peercast peercast.ini /home/peercast/.config/peercast/
WORKDIR /home/peercast
USER peercast:peercast
CMD ["peercast-yt/peercast", "-i", ".config/peercast/peercast.ini", "-P", "peercast-yt"]
# ---with-sources image

FROM centos:centos7
ENV YT_VER=0.4.2 \
	ARCH=x86_64
COPY --from=builder /peercast-yt-linux-${ARCH}.tar.gz /
RUN set -x && \
	# peercast user
	groupadd -g 7144 --system peercast && \
	useradd -u 7144 -m -d /home/peercast -s /sbin/nologin -G peercast -g peercast peercast && \
	# install run tools
	yum -y install https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm && \
	yum -y install python3 ffmpeg librtmp && \
	# switch user and untar
	su -s /bin/sh - peercast -c \
		"tar xzf /peercast-yt-linux-${ARCH}.tar.gz -C /home/peercast" && \
	# clean up
	rm /peercast-yt-linux-${ARCH}.tar.gz; \
	yum clean all;

COPY --chmod=660 --chown=peercast:peercast peercast.ini /home/peercast/.config/peercast/
WORKDIR /home/peercast/
USER peercast:peercast
CMD ["peercast-yt/peercast", "-i", ".config/peercast/peercast.ini", "-P", "peercast-yt"]
