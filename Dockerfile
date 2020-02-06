FROM nephatrine/alpine-s6:3.11
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apk add \
   docker \
   git \
   sqlite \
 && rm -rf /var/cache/apk/*

ARG DRONE_VERSION=v1.6.5
ARG DRONE_CLI_VERSION=v1.2.1
ARG DRONE_EXEC_VERSION=v1.0.0-beta.8

RUN echo "====== COMPILE DRONE ======" \
 && apk add --virtual .build-drone build-base go \
 && cd /usr/src \
 && git clone https://github.com/drone/drone && cd drone \
 && git fetch && git fetch --tags \
 && git checkout "$DRONE_VERSION" \
 && go install -tags nolimit ./cmd/drone-server \
 && mv /root/go/bin/drone-server /usr/bin/ \
 && go install ./cmd/drone-agent \
 && mv /root/go/bin/drone-agent /usr/bin/ \
 && cd /usr/src \
 && git clone https://github.com/drone/drone-cli && cd drone-cli \
 && git fetch && git fetch --tags \
 && git checkout "$DRONE_CLI_VERSION" \
 && go install ./... \
 && mv /root/go/bin/drone /usr/bin/ \
 && cd /usr/src \
 && git clone https://github.com/drone-runners/drone-runner-exec && cd drone-runner-exec \
 && git fetch && git fetch --tags \
 && git checkout "$DRONE_EXEC_VERSION" \
 && go build -o /usr/bin/drone-runner-exec \
 && cd /usr/src && rm -rf /root/go /usr/src/* \
 && apk del --purge .build-drone && rm -rf /var/cache/apk/*

EXPOSE 8080/tcp
COPY override /
