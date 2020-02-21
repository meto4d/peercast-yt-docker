FROM ubuntu:latest
RUN apt-get update
RUN apt-get install -y wget python3 ffmpeg
RUN apt-get clean
RUN rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

WORKDIR /root

RUN wget https://github.com/plonk/peercast-yt/releases/download/v0.3.0/peercast-yt-linux-x86_64.tar.gz
RUN tar xzf peercast-yt-linux-x86_64.tar.gz
RUN rm peercast-yt-linux-x86_64.tar.gz
ADD peercast.ini /root/peercast-yt
ADD run.sh /root
RUN mkdir -p /root/config

CMD ["/root/run.sh"]