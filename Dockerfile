# SPDX-FileCopyrightText: 2019 - 2025 Daniel Wolf <nephatrine@gmail.com>
#
# SPDX-License-Identifier: ISC

FROM code.nephatrine.net/nephnet/nxb-alpine:golang AS builder

ARG DRONE_VERSION=v2.26.0
ARG DRONE_CLI_VERSION=v1.8.0

RUN git -C /root clone -b "$DRONE_VERSION" --single-branch --depth=1 https://github.com/harness/harness
RUN git -C /root clone -b "$DRONE_CLI_VERSION" --single-branch --depth=1 https://github.com/harness/drone-cli

RUN echo "====== COMPILE DRONE ======" \
 && cd /root/harness \
 && go install -tags nolimit ./cmd/drone-server
RUN echo "====== COMPILE DRONE-CLI ======" \
 && cd /root/drone-cli \
 && go install ./...

FROM code.nephatrine.net/nephnet/alpine-s6:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apk add --no-cache sqlite

COPY --from=builder \
 /go/bin/drone-server \
 /go/bin/drone /usr/bin/
COPY override /

EXPOSE 8080/tcp
