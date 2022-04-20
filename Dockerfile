FROM pdr.nephatrine.net/nephatrine/alpine-builder:latest AS builder

ARG DRONE_VERSION=v2.9.1
ARG DRONE_CLI_VERSION=v1.5.0
ARG DRONE_DOCKER_VERSION=v1.8.0
ARG DRONE_EXEC_VERSION=v1.0.0-beta.9
ARG DRONE_SSH_VERSION=v1.0.1

RUN git -C /usr/src clone -b "$DRONE_VERSION" --single-branch --depth=1 https://github.com/harness/drone
RUN git -C /usr/src clone -b "$DRONE_CLI_VERSION" --single-branch --depth=1 https://github.com/harness/drone-cli
RUN git -C /usr/src clone -b "$DRONE_DOCKER_VERSION" --single-branch --depth=1 https://github.com/drone-runners/drone-runner-docker
RUN git -C /usr/src clone -b "$DRONE_EXEC_VERSION" --single-branch --depth=1 https://github.com/drone-runners/drone-runner-exec
RUN git -C /usr/src clone -b "$DRONE_SSH_VERSION" --single-branch --depth=1 https://github.com/drone-runners/drone-runner-ssh

RUN echo "====== COMPILE DRONE ======" \
 && cd /usr/src/drone \
 && go install -tags nolimit ./cmd/drone-server
RUN echo "====== COMPILE DRONE-CLI ======" \
 && cd /usr/src/drone-cli \
 && go install ./...
RUN echo "====== COMPILE DRONE-RUNNERS ======" \
 && cd /usr/src/drone-runner-docker && go build -o /usr/bin/drone-runner-docker \
 && cd /usr/src/drone-runner-exec && go build -o /usr/bin/drone-runner-exec \
 && cd /usr/src/drone-runner-ssh && go build -o /usr/bin/drone-runner-ssh
 
FROM pdr.nephatrine.net/nephatrine/alpine-s6:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apk add --no-cache docker git sqlite

COPY --from=builder \
 /usr/bin/drone-runner-docker \
 /usr/bin/drone-runner-exec \
 /usr/bin/drone-runner-ssh \
 /root/go/bin/drone-server \
 /root/go/bin/drone /usr/bin/
COPY override /

EXPOSE 8080/tcp
