# SIRF on Ubuntu 18.04 on Docker

Docker wrapper for CCP SyneRBI SIRF.

## TL;DR, I want a (Jupyter notebook) service NOW

1. Install [docker CE][docker-ce] and [`docker-compose`][docker-compose],
2. Run `./sirf-compose-server up -d sirf` (in this folder,
   `SIRF-SuperBuild/docker`)
3. Open a browser at <http://localhost:9999>. It may take a few seconds.
(Run `docker logs -f sirf` to see the container's progress -
eventually there should be a message stating the notebook has started.)
The password is `virtual`.
The directory is mounted at `/devel` in the docker container
from `./devel` (in this folder) on the host. The container will copy
[SIRF-Exercises] into this folder if not present.

[docker-ce]: https://docs.docker.com/install/
[docker-compose]: https://github.com/docker/compose/releases
[SIRF-Exercises]: https://github.com/SyneRBI/SIRF-Exercises

Note: If on Windows, `localhost` probably won't work.
Find out the service IP address using:
```
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sirf
```
and use the resultant IP instead of `localhost` (e.g.: `172.18.0.2:9999`).

## Tags

The repository is hosted at [hub.docker.com][dockerhub-SIRF].
To pull directly, use:

```sh
docker pull synerbi/sirf:<DOCKER_TAG>
```

| `<DOCKER_TAG>` | Service `<DOCKER_TAG>` | [SuperBuild] branch/tag |
|:--- |:--- |:--- |
| `release` | `release-service` | `<latest_tag>` |
| `<tag>` | `<tag>-service` | `<tag>` |
| `latest` | `service` | `master` |
| `devel` | `devel-service` | `master` with `cmake -DDEVEL_BUILD=ON` |

Service images are intended to be run in the background, and expose:

| Port(s) | Notes |
| --- | --- |
| 9999 | `Jupyter` (in folder `/devel`) |
| 8890-9 | `Jupyter` (in folder `/devel/SIRF-Exercises-<0-9>`) |
| 9002 | `Gadgetron` |

[dockerhub-SIRF]: https://hub.docker.com/r/synerbi/sirf/
[SuperBuild]: https://github.com/SyneRBI/SIRF-SuperBuild/

# Introduction

Docker is a low-overhead, container-based replacement for virtual machines (VMs).

This works best on a linux system due to:

1. Possibility to get CUDA support within the container
2. `X11` windows displayed natively without needing e.g. a `vnc` server or desktop in the container

This is probably the easiest way to directly use `SIRF` due to really short
installation instructions essentially consisting of:

```sh
docker-compose up --no-start sirf
docker start -ai sirf
```

This becomes even simpler if `SIRF` is only going to be used inside a
Jupyter notebook:

```sh
sirf-compose-server up -d sirf
firefox localhost:9999
```

## Summary

### CLI

After installing [docker CE][docker-ce] and [`docker-compose`][docker-compose],

```bash
git clone https://github.com/SyneRBI/SIRF-SuperBuild
cd SIRF-SuperBuild/docker
# if your host is linux:
./sirf-compose up --no-start sirf
# alternative if your host is windows:
docker-compose up --no-start sirf
```

Then it's just

```bash
docker start -ai sirf
```

every time you want to play with `SIRF`.

```bash
docker start -ai sirf
(pyvenv) sirf:~$ python /opt/SIRF-SuperBuild/sources/SIRF/examples/Python/PET/osem_reconstruction.py
```

### Jupyter

Alternatively, if you want a jupyter notebook server,

```bash
git clone https://github.com/SyneRBI/SIRF-SuperBuild
cd SIRF-SuperBuild/docker
./sirf-compose-server up -d sirf  # remove `./` if on windows
```

Then it's just

```bash
./sirf-compose-server up -d sirf  # start sirf
firefox localhost:9999  # open a browser pointing to the server
./sirf-compose-server down  # stop sirf server
```

every time you want to play with `SIRF`.

## Prerequisites

- Docker
    + The free [Community Edition (CE)][docker-ce] is sufficient
    + [`docker-compose`][docker-compose]
- The [`SIRF-SuperBuild` repository](https://github.com/SyneRBI/SIRF-SuperBuild)
    + download and unzip or `git clone` this locally

## Glossary

A wonderfully tiny list of everything important to know for a basic working knowledge of docker.

- *Base image*: the starting point for building a Docker image
    + analogous to a clean OS (in this case `ubuntu:18.04`)
- *Layer*: a single build step
    + usually represented by a single line in a `Dockerfile` (e.g. `apt-get install cmake`)
- *Image*: a sequence of *layers* (applied on top of a *base image*)
    + analogous to a clean OS with `SIRF` installed (in this case *tagged* `synerbi/sirf`)
- *Container*: a sandboxed workspace derived from an *image*
    + analogous to a running virtual machine (in this case named `sirf`)
    + easily stoppable, restartable, disposable
    + can be thought of as end-user-created *layers* which would never be formally part of a redistributable *image*
    + can share files, network connections, and devices with the host computer

*Images* are *built* or *pulled*. *Containers* are *created* from them:

- *Build*: typically refers to *pulling* a *base image*, then *building* all the *layers* necessary to form an *image*
    + usually once-off
- *Pull*: typically refers to downloading an *image* from the internet (which someone else *built*)
    + usually only required when there is no source code available to allow for *building* locally
- *Create*: typically refers to making a *container* from an *image*
    + often recreated for a semi-clean slate - especially if data is shared with the host computer so that no data is lost on disposal

## SIRF Image Building and Container Creation

The docker image can be built from source using `SyneRBI/SIRF-SuperBuild` by following the steps below. Alternatively, simply run `docker pull synerbi/sirf` to download a pre-built image.

`docker-compose` is used to help with creating containers (and even building images). It should be added to your `PATH` or at least have the executable copied to `SIRF-SuperBuild/docker`.

### Linux CLI

```bash
# Either:
SIRF-SuperBuild/docker$ docker pull synerbi/sirf
# Or:
SIRF-SuperBuild/docker$ docker-compose build core sirf
```

After this a container called `sirf` is created:
For easier file and window sharing, the `sirf` container should be started using the host user's ID and some environment variables:

```bash
SIRF-SuperBuild/docker$ ./sirf-compose up --no-start sirf
```

### Windows CLI

```
Either:
SIRF-SuperBuild/docker> docker pull synerbi/sirf
Or:
SIRF-SuperBuild/docker> docker-compose build core sirf
```

Instead of passing user IDs, Windows requires that
[file sharing is enabled](https://docs.docker.com/docker-for-windows/#shared-drives). Then:

```
SIRF-SuperBuild/docker> docker-compose up --no-start sirf
```

You may want to consult [SIRF on Windows Subsystem for Linux][wiki-wsl]
regarding setting up Xserver/VNCserver and other UNIX-for-Windows-users tips.

Note that Docker for Windows uses the newer
[Hyper-V backend which can't be enabled if you have VirtualBox][hyper-vbox].
You can use the older VirtualBox backend instead by using [Docker Machine].

[wiki-wsl]: https://github.com/SyneRBI/SIRF/wiki/SIRF-SuperBuild-on-Bash-on-Ubuntu-on-Windows-10
[hyper-vbox]: https://docs.docker.com/docker-for-windows/install/#what-to-know-before-you-install
[Docker Machine]: https://docs.docker.com/machine/overview/#whats-the-difference-between-docker-engine-and-docker-machine

### Linux/Windows Jupyter Server

Alternatively, if you want a jupyter notebook server,

```bash
# Linux:
SIRF-SuperBuild/docker$ ./sirf-compose-server up -d sirf
# Windows:
SIRF-SuperBuild/docker> sirf-compose-server up -d sirf
```

Open your favourite web browser on your host OS, and go to
<http://localhost:9999>.
If the browser is giving you a connection error,
`docker logs -f sirf` will give you the current status of the server
(there should be an eventual message about Jupyter being started).

To stop the server, run `sirf-compose-server down`.

### Developers

`ccache` is used in the container to speed up rebuilding images from scratch.
The cache is pulled from the host machine via the `devel/.ccache` folder.
To replace the host's cache with the updated one from the container, run:

```bash
SIRF-SuperBuild/docker$ sudo rm -rf devel/.ccache/*
SIRF-SuperBuild/docker$ ./sirf-compose run --rm sirf \
  /bin/bash -c 'sudo cp -a /opt/ccache/* /devel/.ccache/'
```

Note that `./sirf-compose*` are simple wrappers around `docker-compose`.

- For a service (Jupyter) container:
    + `./sirf-compose-server`
- For a container hosting 10 Jupyter servers:
    + `./sirf-compose-server-multi`
- For a basic interactive container:
    + on Linux: `./sirf-compose`
    + on Windows: `docker-compose`

Run any of the above commands without arguments for help.

For example, to host multiple Jupyter servers in one container, simply:
```
./sirf-compose-server-multi up -d sirf  # start 10 jupyter servers
./sirf-compose-server-multi ps # print out exposed ports
./sirf-compose-server-multi stop  # stop and remove the container
```

Note that the `devel/SIRF-Exercises*` shared folders created in the above steps
will persist across container (and indeed host) restarts.

## Usage

Well, that was easy. The container can be run interactively for daily use.
Note that the `devel` folder in the host's `SIRF-SuperBuild/docker` directory
is mounted to `/devel` in the container.

### CLI

```bash
SIRF-SuperBuild/docker$ docker start -ai sirf
(py2) sirf:~$ gadgetron >> /dev/null &
(py2) sirf:~$ python SIRF-SuperBuild/SIRF/examples/Python/MR/fully_sampled_recon.py
```

The first line starts the `sirf` docker container.
The second line starts `gadgetron` within the container as a background process.
Finally, we can then run an example.

### Jupyter

```bash
SIRF-SuperBuild/docker$ ./sirf-compose-server up -d sirf
SIRF-SuperBuild/docker$ firefox localhost:9999
SIRF-SuperBuild/docker$ ./sirf-compose-server down
```

The first line starts the `sirf` docker container, including `gadgetron` and
`jupyter` within the container as background processes.
The second line open the notebook in a browser.
Finally, after finishing our work, we can stop the container.

# Notes

- Tests can be run as follows:
```bash
(py2) sirf:~$ /devel/test.sh
```
- "Cannot connect to display" errors are usually fixed by running `xhost +local:""` on the host linux system
- Non-linux users (e.g. Windows) will need to set up a desktop and vnc server in order to have a GUI (docker files coming soon)
- On host systems with less than 16GB RAM, before `docker-compose up ...` you may want to edit `SIRF-SuperBuild/docker/user_sirf-ubuntu.sh`, changing the line `make -j...` to simply `make`. This increases build time and reduces build memory requirements
- `localhost` probably won't work on Windows. The service IP address is instead:
`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sirf`
- `docker logs -f sirf` and `docker ps -a` are useful commands for debugging

### Links

- [SIRF docker source]
    + See also: [SIRF SuperBuild on Docker wiki]
- [Synergistic Image Reconstruction Framework (SIRF) project][SIRF]
    + [SIRF wiki]
- [Collaborative Computational Project in Positron Emission Tomography and Magnetic Resonance imaging (CCP SyneRBI)][CCP SyneRBI]

[SIRF docker source]: https://github.com/SyneRBI/SIRF-SuperBuild/tree/master/docker
[SIRF SuperBuild on Docker wiki]: https://github.com/SyneRBI/SIRF/wiki/SIRF-SuperBuild-on-Docker
[SIRF]: https://github.com/SyneRBI/SIRF
[SIRF wiki]: https://github.com/SyneRBI/SIRF/wiki
[CCP SyneRBI]: https://www.ccpsynerbi.ac.uk/
