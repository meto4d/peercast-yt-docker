FROM ubuntu:20.04 AS builder
ENV YT_VER=0.4.2 \
	ARCH=x86_64
WORKDIR /
ENV YT_URL="https://github.com/plonk/peercast-yt/archive/refs/tags/v"${YT_VER}".tar.gz" \
	WORKDIR="/peercast-yt-"${YT_VER}""
# setup
RUN set -x && \
	# peercast user
	mkdir -p -m 2755 /home/peercast/ && \
	groupadd -g 7144 --system peercast && \
	useradd -u 7144 -d /home/peercast -s /sbin/nologin -G peercast -g peercast peercast && \
	chown peercast:peercast /home/peercast/ && \
	# check ARCH type
	if [ "${ARCH}" != "$(uname -m | tr A-Z a-z)" ]; then \
		echo "check 'ARCH' value as cpu architexture type"; \
		exit 1; \
	fi; \
	# install package
	apt-get -y update && \
	# install build tools
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get -y install make gcc g++ ruby libssl-dev librtmp-dev curl pkg-config && \
	# install run tools
	apt-get -y install python3 ffmpeg librtmp1 && \
	# download
	curl -s -L ${YT_URL} | tar zxvf - && \
	# build
	make -C ${WORKDIR}/ui/linux && \
	tar xzf ${WORKDIR}/ui/linux/peercast-yt-linux-${ARCH}.tar.gz -C /home/peercast/ && \
	# mv tarball
	mv ${WORKDIR}/ui/linux/peercast-yt-linux-${ARCH}.tar.gz / && \
	# clean up
	apt-get -y purge make gcc g++ ruby libssl-dev librtmp-dev curl pkg-config && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*;

COPY --chmod=660 --chown=peercast:peercast peercast.ini /home/peercast/.config/peercast/
WORKDIR /home/peercast
USER peercast:peercast
CMD ["peercast-yt/peercast", "-i", ".config/peercast/peercast.ini", "-P", "peercast-yt"]
# ---with-sources image

FROM ubuntu:20.04
ENV YT_VER=0.4.2 \
	ARCH=x86_64
COPY --from=builder /peercast-yt-linux-${ARCH}.tar.gz /
RUN set -x && \
	# peercast user
	mkdir -p -m 2755 /home/peercast/ && \
	groupadd -g 7144 --system peercast && \
	useradd -u 7144 -d /home/peercast -s /sbin/nologin -G peercast -g peercast peercast && \
	chown peercast:peercast /home/peercast/ && \
	# install run tools
	apt-get -y install python3 ffmpeg librtmp1 && \
	tar xzf /peercast-yt-linux-${ARCH}.tar.gz -C /home/peercast && \
	rm /peercast-yt-linux-${ARCH}.tar.gz; \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*;

USER peercast:peercast
COPY --chmod=660 --chown=peercast:peercast peercast.ini /home/peercast/.config/peercast/
WORKDIR /home/peercast
CMD ["peercast-yt/peercast", "-i", ".config/peercast/peercast.ini", "-P", "peercast-yt"]
