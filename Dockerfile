# SPDX-FileCopyrightText: 2019-2025 Daniel Wolf <nephatrine@gmail.com>
# SPDX-License-Identifier: ISC

# hadolint global ignore=DL3007,DL3018

FROM code.nephatrine.net/nephnet/nxb-golang:latest AS builder

ARG DRONE_VERSION=v2.26.0
ARG DRONE_CLI_VERSION=v1.8.0

RUN git -C /root clone -b "$DRONE_VERSION" --single-branch --depth=1 https://github.com/harness/harness && git -C /root clone -b "$DRONE_CLI_VERSION" --single-branch --depth=1 https://github.com/harness/drone-cli
WORKDIR /root/harness
RUN go install -tags nolimit ./cmd/drone-server
WORKDIR /root/drone-cli
RUN go install ./...

FROM code.nephatrine.net/nephnet/alpine-s6:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN apk add --no-cache sqlite && rm -rf /tmp/* /var/tmp/*

COPY --from=builder /go/bin/drone-server /go/bin/drone /usr/bin/
COPY override /

EXPOSE 8080/tcp
