FROM centos:centos7
ENV YT_VER=0.4.2 \
	ARCH=x86_64 \
	HOME_DIR=/root
ENV YT_URL="https://github.com/plonk/peercast-yt/releases/download/v"${YT_VER}"/peercast-yt-linux-"${ARCH}".tar.gz"

# setup
RUN \
	# install package
	yum -y install https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm && \
	yum -y install python3 ffmpeg librtmp && \
	yum clean all; \
	# download
	curl -s -OL ${YT_URL}
	# && \
	#tar xzf "peercast-yt-linux-"${ARCH}".tar.gz" && \
	#rm -f "peercast-yt-linux-"${ARCH}".tar.gz"

ADD peercast.ini ${HOME_DIR}/.config/peercast/
ADD run.sh ${HOME_DIR}

CMD [${HOME_DIR}"/run.sh"]
