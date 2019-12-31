[Git](https://code.nephatrine.net/nephatrine/docker-drone-ci) |
[Docker](https://hub.docker.com/r/nephatrine/drone-ci/) |
[unRAID](https://code.nephatrine.net/nephatrine/unraid-containers)

# Drone CI/CD Server

This docker image contains the Drone server - a self-service CI/CD platform -
using a sqlite3 database.

**THIS IS COMPILED IN ENTERPRISE-MODE WITH THE ``nolimit`` TAG. PLEASE READ AND
UNDERSTAND THE [DRONE LICENSE](https://drone.io/enterprise/license/). TO USE
THIS VERSION YOU MUST MEET CERTAIN REQUIREMENTS AS OUTLINED IN THE
[FAQ](https://discourse.drone.io/t/licensing-and-subscription-faq/3839). IF YOU
DO NOT MEET THE REQUIREMENTS TO USE THE ENTERPRISE VERSION WITHOUT LIMITS,
PLEASE USE THE COMMUNITY VERSION OR LICENSE THE ENTERPRISE VERSION.**

- [Drone](https://drone.io/)
- [SQLite](https://www.sqlite.org/)

Both a drone server and agent are included so you can use this as a single
container if desired, but you can still add more agents down the line. To
disable the built-in agent, set an the ``DRONE_AGENT_DISABLED`` variable to
any value.

This container image includes [Certbot](https://certbot.eff.org/) and can be
configured to obtain SSL certificates, but it is suggested to instead put it
behind an [NGINX](https://nginx.com/) reverse proxy and use SSL there instead.

You can spin up a quick temporary test container like this:

~~~
docker run -rm -ti nephatrine/drone-server:latest /bin/bash
~~~

## Docker Tags

- **nephatrine/drone-server:testing**: Drone Development (*master*)
- **nephatrine/drone-server:latest**: Drone v1.6.3 (*v1.6.3*)

## Configuration Variables

You can set these parameters using the syntax ``-e "VARNAME=VALUE"`` on your
``docker run`` command. These are typically used during the container
initialization scripts to perform initial setup.

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
- ``PUID``: Mount Owner UID (*1000*)
- ``PGID``: Mount Owner GID (*100*)
- ``SSLDOMAINS``: Comma-Delimited Certbot Domains (*""*)
- ``SSLEMAIL``: Certbot Email (*""*)
- ``TZ``: System Timezone (*America/New_York*)

## Persistent Mounts

You can provide a persistent mountpoint using the ``-v /host/path:/container/path``
syntax. These mountpoints are intended important configuration files, logs,
and application state (e.g. databases) can be retained outside the container
image and are not lost on image updates.

- ``/mnt/config``: Configuration & Logs. Do not share with multiple containers.
- ``/run/docker.sock`: Docker Daemon Socket.

You can perform some basic configuration of the container using the files and
directories listed below.

- ``/mnt/config/etc/crontabs/<user>``: User Crontabs. [*]
- ``/mnt/config/etc/drone-server/config``: Set Drone Envars. [*]
- ``/mnt/config/etc/logrotate.conf``: Logrotate Global Configuration.
- ``/mnt/config/etc/logrotate.d/``: Logrotate Additional Configuration.

**[*] Changes to some configuration files may require service restart to take
immediate effect.**

Some configuration files are required for system operation and will be
recreated with their default settings if deleted.

## Network Services

This container runs network services that are intended to be exposed outside
the container. You can map these to host ports using the ``-p HOST:CONTAINER``
or ``-p HOST:CONTAINER/PROTOCOL`` syntax.

- ``8080/tcp``: Drone Server. This is the server interface.
- ``3000/tcp``: Drone Agent. If enabled, this is the agent interface.
