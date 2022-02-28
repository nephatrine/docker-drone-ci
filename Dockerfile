FROM nephatrine/alpine-s6:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ARG DRONE_VERSION=v2.9.1
ARG DRONE_CLI_VERSION=v1.5.0
ARG DRONE_DOCKER_VERSION=v1.8.0
ARG DRONE_EXEC_VERSION=v1.0.0-beta.9
ARG DRONE_SSH_VERSION=v1.0.1
RUN echo "====== COMPILE DRONE ======" \
 && apk add --no-cache \
  docker \
  git \
  sqlite \
 && apk add --no-cache --virtual .build-drone go \
 && git -C /usr/src clone -b "$DRONE_VERSION" --single-branch --depth=1 https://github.com/harness/drone && cd /usr/src/drone \
 && go install -tags nolimit ./cmd/drone-server \
 && mv /root/go/bin/drone-server /usr/bin/ \
 && git -C /usr/src clone -b "$DRONE_CLI_VERSION" --single-branch --depth=1 https://github.com/harness/drone-cli && cd /usr/src/drone-cli \
 && go install ./... \
 && mv /root/go/bin/drone /usr/bin/ \
 && git -C /usr/src clone -b "$DRONE_DOCKER_VERSION" --single-branch --depth=1 https://github.com/drone-runners/drone-runner-docker \
 && cd /usr/src/drone-runner-docker && go build -o /usr/bin/drone-runner-docker \
 && git -C /usr/src clone -b "$DRONE_EXEC_VERSION" --single-branch --depth=1 https://github.com/drone-runners/drone-runner-exec \
 && cd /usr/src/drone-runner-exec && go build -o /usr/bin/drone-runner-exec \
 && git -C /usr/src clone -b "$DRONE_SSH_VERSION" --single-branch --depth=1 https://github.com/drone-runners/drone-runner-ssh \
 && cd /usr/src/drone-runner-ssh && go build -o /usr/bin/drone-runner-ssh \
 && cd /usr/src && rm -rf /root/go /usr/src/* \
 && apk del --purge .build-drone

COPY override /
EXPOSE 8080/tcp
