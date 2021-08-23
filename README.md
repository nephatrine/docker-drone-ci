[Git](https://code.nephatrine.net/nephatrine/docker-drone-ci/src/branch/master) |
[Docker](https://hub.docker.com/r/nephatrine/drone-ci/) |
[unRAID](https://code.nephatrine.net/nephatrine/unraid-containers)

[![Build Status](https://ci.nephatrine.net/api/badges/nephatrine/docker-drone-ci/status.svg?ref=refs/heads/master)](https://ci.nephatrine.net/nephatrine/docker-drone-ci)

# Drone CI/CD Server

This docker image contains a Drone server to self-host your own continuous
delivery platform.

**PLEASE READ AND UNDERSTAND THE [DRONE LICENSE](https://drone.io/enterprise/license/).
THIS IMAGE CONTAINS THE ENTERPRISE VERSION IS COMPILED WITH THE ``nolimit`` TAG
AND USE REQUIRES YOU MEET CERTAIN REQUIREMENTS AS LAID OUT IN THE
[LICENSING FAQ](https://discourse.drone.io/t/licensing-and-subscription-faq/3839).
IF YOU DO NOT MEET THOSE REQUIREMENTS YOU MUST EITHER USE THE COMMUNITY VERSION
INSTEAD OR PURCHASE A LICENSE.**

**YOU WILL NEED TO USE A SEPARATE REVERSE PROXY SERVER TO SECURE THIS SERVICE.
FOR INSTANCE, AN [NGINX](https://nginx.com/) REVERSE PROXY CONTAINER.**

- [Alpine Linux](https://alpinelinux.org/)
- [Skarnet Software](https://skarnet.org/software/)
- [S6 Overlay](https://github.com/just-containers/s6-overlay)
- [Drone](https://drone.io/)
- [SQLite](https://www.sqlite.org/)

This container includes a server, docker runner, and exec runner. This is not a
single-server configuration so you can easily add more agents and runners in
separate containers as needed. You can pass variable ``DRONE_DOCKER_DISABLED``
or ``DRONE_EXEC_DISABLED`` to disable one or both runners.

You can spin up a quick temporary test container like this:

~~~
docker run --rm -p 8080:8080 -v /var/run/docker.sock:/run/docker.sock -it nephatrine/drone-ci:latest /bin/bash
~~~

## Docker Tags

- **nephatrine/drone-server:testing**: Drone v1.x
- **nephatrine/drone-server:latest**: Drone v1.x

## Configuration Variables

You can set these parameters using the syntax ``-e "VARNAME=VALUE"`` on your
``docker run`` command. Some of these may only be used during initial
configuration and further changes may need to be made in the generated
configuration files.

- ``DRONE_DATABASE_SECRET``: Database Secret (**generated**)
- ``DRONE_GITEA_SERVER``: Gitea Server (*""*)
- ``DRONE_GITEA_CLIENT_ID``: Gitea OAuth2 ID (*""*)
- ``DRONE_GITEA_CLIENT_SECRET``: Gitea OAuth2 Secret (*""*)
- ``DRONE_GITHUB_SERVER``: Gitea Server (*""*)
- ``DRONE_GITHUB_CLIENT_ID``: Gitea OAuth2 ID (*""*)
- ``DRONE_GITHUB_CLIENT_SECRET``: Gitea OAuth2 Secret (*""*)
- ``DRONE_GITLAB_SERVER``: Gitlab Server (*""*)
- ``DRONE_GITLAB_CLIENT_ID``: Gitlab OAuth2 ID (*""*)
- ``DRONE_GITLAB_CLIENT_SECRET``: Gitlab OAuth2 Secret (*""*)
- ``DRONE_RPC_SECRET``: Server-Agent Secret (**generated**)
- ``DRONE_SERVER_HOST``: External Hostname (*localhost*)
- ``DRONE_SERVER_PROTO``: External Protocol (*http*)
- ``DRONE_USER_CREATE``: Initial Administative User (*""*)
- ``PUID``: Mount Owner UID (*1000*)
- ``PGID``: Mount Owner GID (*100*)
- ``TZ``: System Timezone (*America/New_York*)

The ``DRONE_USER_CREATE`` variable takes more than just a username. You should
pass in a string formatted like this ``username:<username>,admin:true``. This
can be done after initial login at any time to bootstrap the administrative
user. You will need to be an administative user to perform some tasks via the
drone cli, but it is not required for basic usage.

## Persistent Mounts

You can provide a persistent mountpoint using the ``-v /host/path:/container/path``
syntax. These mountpoints are intended to house important configuration files,
logs, and application state (e.g. databases) so they are not lost on image
update.

- ``/mnt/config``: Persistent Data.
- ``/run/docker.sock`: Docker Daemon Socket.

Do not share ``/mnt/config`` volumes between multiple containers as they may
interfere with the operation of one another.

You can perform some basic configuration of the container using the files and
directories listed below.

- ``/mnt/config/etc/crontabs/<user>``: User Crontabs. [*]
- ``/mnt/config/etc/drone-server/config``: Set Drone Envars. [*]
- ``/mnt/config/etc/logrotate.conf``: Logrotate Global Configuration.
- ``/mnt/config/etc/logrotate.d/``: Logrotate Additional Configuration.

**[*] Changes to some configuration files may require service restart to take
immediate effect.**

## Network Services

This container runs network services that are intended to be exposed outside
the container. You can map these to host ports using the ``-p HOST:CONTAINER``
or ``-p HOST:CONTAINER/PROTOCOL`` syntax.

- ``8080/tcp``: Drone Server. This is the server interface.
