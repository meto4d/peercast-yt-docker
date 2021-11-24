# peercast-yt-docker

PeerCast YT の Docker コンテナのForkで、YT標準のUbuntu以外のコンテナです。

主にAlpineコンテナ、CentOS7コンテナをメンテナンスしています。

## Branchについて

Branchで各種ベースコンテナを区切っています。

masterブランチはYTの標準であるUbuntuイメージになっています。

# 利用方法

imageをpullしてdocker runだけで利用することができます。

    $ docker run -p 7144:7144 meto4d/peercast-yt:latest

もし設定ファイルを変更したい場合は、下記のような別途Dockerfileを用意してbuildしてください。(推奨)
もしくは、docker cp/docker execなどで設定ファイルを差し替えてpeercast-ytを再起動させてください。

## 設定ファイルを差し替える場合
Dockerfile例:

    #peercast-yt Dockerfile
    FROM meto4d/peercast-yt:latest
    COPY <用意したpeercast.iniファイル> .config/peercast/

コマンド例:

    $ docker build -t peercast .
    $ docker run -p 7144:7144 peercast



# その他

[Docker hub meto4d/peercast-yt](https://hub.docker.com/repository/docker/meto4d/peercast-yt/)へ各種imageを上げています。

少し設定項目が追加された設定ファイルが導入されています。
- 初期パスワード：peercast
- 登録YP：平成YP, SP, TP, P@YP[^P@YP], 芝, YPv6[^YPv6], イベントYP
- ダイレクト視聴数:1

[^P@YP]:https対応版の場合https,https未対応の場合http
[^YPv6]:IPv6対応したpeercast-ytの場合のみ

alpineイメージのみ、muslを利用しているため、ソースコードを一部変更しています。(peercast-yt ver0.4.2現在)

簡単には以下のコード変更を加えています。
- glibcの機能検知マクロを厳密化
- BACKTRACEを無効化
- 一部マルチスレッド用のlock処理を除去
Dockerfile上でsedにより加筆修正をしているため、詳細はDockerfileを閲覧してください。

なお、このソースコードの変更は、[本家peercast-yt](https://github.com/plonk/peercast-yt/)へ報告済みで、masterへも取り込まれています。
Releasesからソースを参照しているURLをいくつかのコンテナで同一化するため、こちらは利用していません。
0.4.3で改善するかもしれませんね。

