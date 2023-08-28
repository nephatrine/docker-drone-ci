FROM nephatrine/nxbuilder:golang AS builder

ARG DRONE_VERSION=v2.20.0
ARG DRONE_CLI_VERSION=v1.7.0

RUN git -C /root clone -b "$DRONE_VERSION" --single-branch --depth=1 https://github.com/harness/drone
RUN git -C /root clone -b "$DRONE_CLI_VERSION" --single-branch --depth=1 https://github.com/harness/drone-cli

RUN echo "====== COMPILE DRONE ======" \
 && cd /root/drone \
 && go install -tags nolimit ./cmd/drone-server
RUN echo "====== COMPILE DRONE-CLI ======" \
 && cd /root/drone-cli \
 && go install ./...

FROM nephatrine/alpine-s6:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apk add --no-cache sqlite

COPY --from=builder \
 /go/bin/drone-server \
 /go/bin/drone /usr/bin/
COPY override /

EXPOSE 8080/tcp
