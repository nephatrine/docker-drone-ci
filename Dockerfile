FROM nephatrine/nxbuilder:golang AS builder

ARG DRONE_VERSION=v2.16.0
ARG DRONE_CLI_VERSION=v1.7.0
ARG DRONE_DOCKER_VERSION=v1.8.3
ARG DRONE_EXEC_VERSION=v1.0.0-beta.10
ARG DRONE_SSH_VERSION=v1.0.1

RUN git -C ${HOME} clone -b "$DRONE_VERSION" --single-branch --depth=1 https://github.com/harness/drone
RUN git -C ${HOME} clone -b "$DRONE_CLI_VERSION" --single-branch --depth=1 https://github.com/harness/drone-cli
RUN git -C ${HOME} clone -b "$DRONE_DOCKER_VERSION" --single-branch --depth=1 https://github.com/drone-runners/drone-runner-docker
RUN git -C ${HOME} clone -b "$DRONE_EXEC_VERSION" --single-branch --depth=1 https://github.com/drone-runners/drone-runner-exec
RUN git -C ${HOME} clone -b "$DRONE_SSH_VERSION" --single-branch --depth=1 https://github.com/drone-runners/drone-runner-ssh

RUN echo "====== COMPILE DRONE ======" \
 && cd ${HOME}/drone \
 && go install -tags nolimit ./cmd/drone-server
RUN echo "====== COMPILE DRONE-CLI ======" \
 && cd ${HOME}/drone-cli \
 && go install ./...
RUN echo "====== COMPILE DRONE-RUNNERS ======" \
 && cd ${HOME}/drone-runner-docker && go build -o /go/bin/drone-runner-docker \
 && cd ${HOME}/drone-runner-exec && go build -o /go/bin/drone-runner-exec \
 && cd ${HOME}/drone-runner-ssh && go build -o /go/bin/drone-runner-ssh

FROM nephatrine/alpine-s6:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apk add --no-cache docker git git-lfs sqlite

COPY --from=builder \
 /go/bin/drone-runner-docker \
 /go/bin/drone-runner-exec \
 /go/bin/drone-runner-ssh \
 /go/bin/drone-server \
 /go/bin/drone /usr/bin/
COPY override /

EXPOSE 8080/tcp
