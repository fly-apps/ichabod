# this dockerfile is a mangled version of 
# https://hub.docker.com/r/justinribeiro/chrome-headless/

FROM golang:latest

ENV CHROME_DEBUG_PORT=9222
ARG VERSION=87.0.4280.88

# this was LATEST when I wrote the dockerfile; prior to Sep 2020,
# remote CDP over IPv6 was busticated
ARG REVISION=841231

# download fresh chromium, but also install via apt to get the
# 8 bajillion Linux deps it has. weird ordering because my apt
# deps changed a bunch and I don't want to re-download chromium
# every time they do.
RUN apt-get update
RUN apt install -y wget
RUN wget -q -O chrome.zip https://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/${REVISION}/chrome-linux.zip

RUN apt-get install -y \
	unzip \
	dnsutils \
	iproute2 \
	tmux \
	apt-transport-https \
	ca-certificates \
	curl \
	libgbm-dev \
	chromium \
	libxss1 \
	--no-install-recommends 

RUN unzip chrome.zip && \
    rm chrome.zip && \
    ln -sf ${PWD}/chrome-linux/chrome /usr/bin/chromium && \
    ln -sf /usr/bin/chromium /usr/bin/chromium-browser 

RUN GO111MODULE=on go get -u github.com/DarthSim/overmind/v2 &&\
    curl https://releases.hashicorp.com/serf/0.8.2/serf_0.8.2_linux_amd64.zip > serf.zip &&\
    unzip serf.zip &&\
    mv serf /usr/local/bin &&\
    chmod a+x /usr/local/bin/serf

# i'm not actually bothering with any of this and XXX should remove it
RUN groupadd -r chrome && useradd -r -g chrome -G audio,video chrome &&\
    mkdir -p /home/chrome/reports &&\
    chown -R chrome:chrome /home/chrome 

RUN apt-get autoremove wget unzip -y

COPY entrypoint.sh /usr/bin/entrypoint
COPY serfctl.sh /usr/bin/serfctl

ADD Procfile . 

CMD overmind start -r chrome,serf_server -c serf_bringup


