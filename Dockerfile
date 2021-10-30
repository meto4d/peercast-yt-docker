FROM centos:centos7
RUN yum -y install python3
RUN yum -y install https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
RUN yum -y install ffmpeg librtmp && \
	yum clean all
RUN curl -OL https://github.com/plonk/peercast-yt/releases/download/v0.3.1/peercast-yt-linux-x86_64.tar.gz && \
	tar xzf peercast-yt-linux-x86_64.tar.gz && \
	rm -f peercast-yt-linux-x86_64.tar.gz

ADD peercast.ini /root/peercast-yt
ADD run.sh /root
RUN mkdir -p /root/config

CMD ["/root/run.sh"]
