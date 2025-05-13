<!--
SPDX-FileCopyrightText: 2019-2025 Daniel Wolf <nephatrine@gmail.com>
SPDX-License-Identifier: ISC
-->

# Drone CI Server

[![NephCode](https://img.shields.io/static/v1?label=Git&message=NephCode&color=teal)](https://code.nephatrine.net/NephNET/docker-drone-ci)
[![GitHub](https://img.shields.io/static/v1?label=Git&message=GitHub&color=teal)](https://github.com/nephatrine/docker-drone-ci)
[![Registry](https://img.shields.io/static/v1?label=OCI&message=NephCode&color=blue)](https://code.nephatrine.net/NephNET/-/packages/container/drone-ci/latest)
[![DockerHub](https://img.shields.io/static/v1?label=OCI&message=DockerHub&color=blue)](https://hub.docker.com/repository/docker/nephatrine/drone-ci/general)
[![unRAID](https://img.shields.io/static/v1?label=unRAID&message=template&color=orange)](https://code.nephatrine.net/NephNET/unraid-containers)

This is an Alpine-based container hosting the Drone continuous integration and
delivery platform.

To secure this service, we suggest a separate reverse proxy server, such as
[nephatrine/nginx-ssl](https://hub.docker.com/repository/docker/nephatrine/nginx-ssl/general).

To actually perform tasks, you will need one or more "runners", such as
[nephatrine/drone-runner](https://hub.docker.com/repository/docker/nephatrine/drone-runner/general).

**READ THROUGH THE [DRONE LICENSE](https://drone.io/enterprise/license/). This
image is not compiled with the `oss` tag which means you must meet certain
requirements as laid out in the [FAQ](https://docs.drone.io/enterprise/). If you
do not or cannot meet those requirements, you need to purchase a license or not
use this version.**

**WARNING: I have personally migrated to Gitea Actions and so this container is
not thoroughly tested anymore. I do suggest you find an alternative as I will
not maintain this indefinitely.**

## Supported Tags

- `drone-ci:2.26.0`: Drone 2.26.0

## Software

- [Alpine Linux](https://alpinelinux.org/)
- [Skarnet S6](https://skarnet.org/software/s6/)
- [s6-overlay](https://github.com/just-containers/s6-overlay)
- [Drone](https://www.drone.io/)

## Configuration

Set the `DRONE_USER_CREATE` variable to create the initial adminitrative user.
This can be done after initial login at any time to bootstrap the administrative
user. You will need to be an administative user to perform some tasks via the
drone cli, but it is not required for basic usage.

This is the only configuration file you will likely need to be aware of and
potentially customize.

- `/mnt/config/etc/drone-config`

This is a bash script that will be sourced by the startup routine to include
additional tweaks or setup you would like to perform. Modifications to these
files will require a service restart to pull in the changes made.

### Container Variables

- `TZ`: Time Zone (i.e. `America/New_York`)
- `PUID`: Mounted File Owner User ID
- `PGID`: Mounted File Owner Group ID
- `DRONE_DATABASE_SECRET`: Database Secret
- `DRONE_GITEA_SERVER`: Gitea Server
- `DRONE_GITEA_CLIENT_ID`: Gitea OAuth2 ID
- `DRONE_GITEA_CLIENT_SECRET`: Gitea OAuth2 Secret
- `DRONE_GITHUB_SERVER`: Gitea Server
- `DRONE_GITHUB_CLIENT_ID`: Gitea OAuth2 ID
- `DRONE_GITHUB_CLIENT_SECRET`: Gitea OAuth2 Secret
- `DRONE_GITLAB_SERVER`: Gitlab Server
- `DRONE_GITLAB_CLIENT_ID`: Gitlab OAuth2 ID
- `DRONE_GITLAB_CLIENT_SECRET`: Gitlab OAuth2 Secret
- `DRONE_RPC_SECRET`: Server-Agent Secret
- `DRONE_SERVER_HOST`: External Hostname
- `DRONE_SERVER_PROTO`: External Protocol
- `DRONE_USER_CREATE`: Initial Administative User (i.e. `username:myuser,admin:true`)

## Testing

### docker-compose

```yaml
services:
  drone-ci:
    image: nephatrine/drone-ci:latest
    container_name: drone-ci
    environment:
      TZ: America/New_York
      PUID: 1000
      PGID: 1000
      DRONE_SERVER_HOST: drone.example.net
      DRONE_SERVER_PROTO: https
      DRONE_GITEA_SERVER: https://gitea.example.net"
      DRONE_GITEA_CLIENT_ID:
      DRONE_GITEA_CLIENT_SECRET:
    ports:
      - "8080:8080/tcp"
    volumes:
      - /mnt/containers/drone-ci:/mnt/config
```

### docker run

```bash
docker run --rm -ti code.nephatrine.net/nephnet/drone-ci:latest /bin/bash
```
