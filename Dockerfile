FROM nephatrine/alpine-s6:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ARG DRONE_VERSION=v1.6.3

RUN echo "====== INSTALL PACKAGES ======" \
 && apk add \
   docker \
   git \
   sqlite \
 && apk add --virtual .build-drone \
   build-base \
   go \
 \
 && echo "====== COMPILE DRONE ======" \
 && cd /usr/src \
 && git clone https://github.com/drone/drone && cd drone \
 && git fetch && git fetch --tags \
 && git checkout "$DRONE_VERSION" \
 && go install -ldflags='-w -s' -tags nolimit ./cmd/drone-server \
 && mv /root/go/bin/drone-server /usr/bin/ \
 && go install -ldflags='-w -s' ./cmd/drone-controller \
 && mv /root/go/bin/drone-controller /usr/bin/ \
 && go install -ldflags='-w -s' ./cmd/drone-agent \
 && mv /root/go/bin/drone-agent /usr/bin/ \
 && cd /usr/src \
 && git clone https://github.com/drone-runners/drone-runner-exec && cd drone-runner-exec \
 && go build -o /usr/bin/drone-runner-exec \
 \
 && echo "====== CLEANUP ======" \
 && apk del --purge .build-drone \
 && cd /usr/src && rm -rf /root/go /tmp/* /usr/src/* /var/cache/apk/*

EXPOSE 3000/tcp 8080/tcp
COPY override /
