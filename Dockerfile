FROM nephatrine/alpine-s6:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apk add \
   docker \
   git \
   sqlite \
 && rm -rf /var/cache/apk/*

ARG DRONE_VERSION=v1.10.1
ARG DRONE_CLI_VERSION=v1.2.4
ARG DRONE_DOCKER_VERSION=v1.6.3
ARG DRONE_EXEC_VERSION=v1.0.0-beta.9

RUN echo "====== COMPILE DRONE ======" \
 && apk add --virtual .build-drone build-base go \
 && git -C /usr/src clone -b "$DRONE_VERSION" --single-branch --depth=1 https://github.com/drone/drone && cd /usr/src/drone \
 && go install -tags nolimit ./cmd/drone-server \
 && mv /root/go/bin/drone-server /usr/bin/ \
 && go install ./cmd/drone-agent \
 && mv /root/go/bin/drone-agent /usr/bin/ \
 && git -C /usr/src clone -b "$DRONE_CLI_VERSION" --single-branch --depth=1 https://github.com/drone/drone-cli && cd /usr/src/drone-cli \
 && go install ./... \
 && mv /root/go/bin/drone /usr/bin/ \
 && git -C /usr/src clone -b "$DRONE_DOCKER_VERSION" --single-branch --depth=1 https://github.com/drone-runners/drone-runner-docker && cd /usr/src/drone-runner-docker \
 && go build -o /usr/bin/drone-runner-docker \
 && git -C /usr/src clone -b "$DRONE_EXEC_VERSION" --single-branch --depth=1 https://github.com/drone-runners/drone-runner-exec && cd /usr/src/drone-runner-exec \
 && go build -o /usr/bin/drone-runner-exec \
 && cd /usr/src && rm -rf /root/go /usr/src/* \
 && apk del --purge .build-drone && rm -rf /var/cache/apk/*

COPY override /

EXPOSE 8080/tcp