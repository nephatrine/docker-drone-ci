FROM nephatrine/nxbuilder:golang AS builder

ARG DRONE_VERSION=v2.16.0
ARG DRONE_CLI_VERSION=v1.7.0
ARG DRONE_EXEC_VERSION=v1.0.0-beta.10

RUN git -C /root clone -b "$DRONE_VERSION" --single-branch --depth=1 https://github.com/harness/drone
RUN git -C /root clone -b "$DRONE_CLI_VERSION" --single-branch --depth=1 https://github.com/harness/drone-cli
RUN git -C /root clone -b "$DRONE_EXEC_VERSION" --single-branch --depth=1 https://github.com/drone-runners/drone-runner-exec

RUN echo "====== COMPILE DRONE ======" \
 && cd /root/drone \
 && go install -tags nolimit ./cmd/drone-server
RUN echo "====== COMPILE DRONE-CLI ======" \
 && cd /root/drone-cli \
 && go install ./...
RUN echo "====== COMPILE DRONE-RUNNERS ======" \
 && cd /root/drone-runner-exec && go build -o /go/bin/drone-runner-exec

FROM nephatrine/alpine-s6:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apk add --no-cache git git-lfs sqlite

COPY --from=builder \
 /go/bin/drone-runner-exec \
 /go/bin/drone-server \
 /go/bin/drone /usr/bin/
COPY override /

EXPOSE 8080/tcp
