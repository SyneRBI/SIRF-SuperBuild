# SIRF in Docker

Docker wrapper for CCP SyneRBI SIRF.

## TL;DR, I want a Jupyter notebook service NOW
These instructions assume you have a knowledge of Docker and Docker Compose. If you don't it is highly recommended you keep reading ahead to [Introduction](#introduction) and beyond.

1. Install [docker CE][docker-ce] and [`docker-compose`][docker-compose]. (If you are on a Mac, these are installed when you install [Docker Desktop](https://www.docker.com/products/docker-desktop)).
    - (optional) If you are on Linux/CentOS/similar and have a GPU,
install the [NVidia container runtime][NVidia-container-runtime]. Be sure to run the [Engine Setup](https://github.com/nvidia/nvidia-container-runtime#docker-engine-setup).
2. Download the SIRF-SuperBuild ([current master](https://github.com/SyneRBI/SIRF-SuperBuild/archive/master.zip), or
[latest release](https://github.com/SyneRBI/SIRF-SuperBuild/releases)) or
```
git clone https://github.com/SyneRBI/SIRF-SuperBuild.git
```
and change directory to this folder, `SIRF-SuperBuild/docker`.

3. Optionally pull the pre-built image with `docker pull synerbi/sirf:service` (or `docker pull synerbi/sirf:service-gpu`), otherwise
the next line will build it, resulting in a much smaller download but longer build time.
4. Run `./sirf-compose-server up -d sirf` (or `./sirf-compose-server-gpu up -d sirf`)
    - You can use a `--build` flag in this command, or `./sirf-compose-server[-gpu] build` to re-build your image if you have an old version.
5. Open a browser at <http://localhost:9999>.
Note that starting the container may take a few seconds the first
time, but will be very quick afterwards.
(Run `docker logs -f sirf` to see the container's progress -
eventually there should be a message stating the notebook has started.)
6. Stop the container (preserving its status) with `docker stop sirf`.
7. Next time, just do `docker start sirf`.

[docker-ce]: https://docs.docker.com/install/
[docker-compose]: https://github.com/docker/compose/releases
[NVidia-container-runtime]: https://github.com/nvidia/nvidia-container-runtime#installation
[SIRF-Exercises]: https://github.com/SyneRBI/SIRF-Exercises

### Important notes:
- The `Jupyter` password is `virtual`.
- The directory is mounted at `/devel` in the docker container
from `./devel` (in this folder) on the host. The container will copy
[SIRF-Exercises] into this folder if not present. This means that
files and notebooks in `./devel` will persist between sessions and
even docker-image upgrades.
- If on Windows, `localhost` probably won't work.
Find out the service IP address using:
```
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sirf
```
and use the resultant IP instead of `localhost` (e.g.: `172.18.0.2:9999`).

## Introduction

Docker is a low-overhead, container-based replacement for virtual machines (VMs).

This works on Unix-type systems, MacOS and Windows 10, but best on a linux host system due to:

1. Possibility to get CUDA support within the container
2. `X11` windows displayed natively without needing e.g. a `vnc` server or desktop in the container

This is probably the easiest way to directly use `SIRF` due to short
installation instructions.


## Prerequisites

- Docker
    + The free [Community Edition (CE)][docker-ce] is sufficient
        + If you are installing on Linux, you will also have to follow the steps to [enable managing docker as a non-root user](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user).
    + [`docker-compose`][docker-compose]
    + If you are on Linux/CentOS/similar and have a GPU, install the [NVidia container runtime][NVidia-container-runtime].
- The [`SIRF-SuperBuild` repository](https://github.com/SyneRBI/SIRF-SuperBuild)
    + download and unzip or `git clone` this locally

## Tags

The docker images are hosted at [hub.docker.com][dockerhub-SIRF]. We upload 2 types of images (see below for more information):
- Command Line Interface (CLI)-only
- "Service" images that will serve `Jupyter` notebooks

And additionally the Docker Tag can specify a given SuperBuild version.

To pull directly, use:

```sh
docker pull synerbi/sirf:<DOCKER_TAG>
```

| CLI-only `<DOCKER_TAG>` | Service (i.e. `Jupyter`) `<DOCKER_TAG>` | [SuperBuild] branch/tag |
|:--- |:--- |:--- |
| `release` | `release-service` | `<latest_tag>` |
| `<tag>` | `<tag>-service` | `<tag>` |
| `latest` | `service` and `service-gpu` | `master` |
| `devel` | `devel-service` | `master` with `cmake -DDEVEL_BUILD=ON` |

Service images are intended to be run in the background, and expose:

| Port(s) | Notes |
| --- | --- |
| 9999 | `Jupyter` (in folder `/devel`) |
| 8890-9 | `Jupyter` (in folder `/devel/SIRF-Exercises-<0-9>`) |
| 9002 | `Gadgetron` |

[dockerhub-SIRF]: https://hub.docker.com/r/synerbi/sirf/
[SuperBuild]: https://github.com/SyneRBI/SIRF-SuperBuild/

### Windows specific notes

Note that Docker for Windows uses the 
[Hyper-V backend][hyper-vbox]. Unfortunately, this conflicts with VirtualBox (last checked start 2021) so you would
have to en/disable Hyper-V and reboot.
You can use the older VirtualBox backend instead by using [Docker Machine].

You may want to consult [SIRF on Windows Subsystem for Linux][wiki-wsl]
regarding setting up Xserver/VNCserver and other UNIX-for-Windows-users tips.

[wiki-wsl]: https://github.com/SyneRBI/SIRF/wiki/SIRF-SuperBuild-on-Bash-on-Ubuntu-on-Windows-10
[hyper-vbox]: https://docs.docker.com/docker-for-windows/install/#what-to-know-before-you-install
[Docker Machine]: https://docs.docker.com/machine/overview/#whats-the-difference-between-docker-engine-and-docker-machine

## Glossary

A brief list of everything important to know for a basic working knowledge of docker.

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
    + each container has its own filesystem, but can share files, network connections, and devices with the host computer

*Images* are *built* or *pulled*. *Containers* are *created* from *images*:

- *Build*: typically refers to *pulling* a *base image*, then *building* all the *layers* necessary to form an *image*
    + usually one-off
- *Pull*: typically refers to downloading an *image* from the internet (which someone else *built*)
    + usually only required when there is no source code available to allow for *building* locally
- *Create*: typically refers to making a *container* from an *image*
    + often recreated for a semi-clean slate - especially if data is shared with the host computer so that no data is lost on disposal

[`docker-compose`][docker-compose] provides a way to create and launch images and containers, specifying port forwarding etc.
`docker-compose` is used to help with creating containers (and even building images). It should be added to your `PATH` or at least have the executable copied to `SIRF-SuperBuild/docker`.

## Creating and using SIRF containers

The docker images can be built from source or pulled using `SyneRBI/SIRF-SuperBuild`, and containers created, by following the steps below.

Please note that these instructions will mount the `SIRF-SuperBuild/docker/devel` folder on the host as `/devel` in the docker container.
The container will copy
[SIRF-Exercises] into this folder if not present. This means that
files and notebooks in `/devel` will be persistent between sessions and
even docker-image upgrades. You should therefore remove the contents of
`SIRF-SuperBuild/docker/devel` if you want to really start afresh.

### Creating a container providing a Linux *CLI* with SIRF
The default "CLI" images provide an Ubuntu environment with the SuperBuild built (see [Tags](#tags)) as a convenient environment.

#### Using a Linux or MacOS CLI
Build/pull the image:
```bash
# Either:
SIRF-SuperBuild/docker$ docker pull synerbi/sirf
# Or:
SIRF-SuperBuild/docker$ ./sirf-compose build core sirf
```

For easier file and window sharing, use the provided script, `sirf-compose`, which calls `docker-compose` but handles the host user's ID and some environment variables.

We can now create a container.

```bash
SIRF-SuperBuild/docker$ ./sirf-compose up --no-start sirf
```

Here, `--no-start` delays actually starting the container.
We can now use this interactively, by starting the containder with flags `-ai`.
```bash
SIRF-SuperBuild/docker$ docker start -ai sirf
(py2) sirf:~$ gadgetron >> /dev/null &  # launch Gadgetron as a "background" process
(py2) sirf:~$ python SIRF-SuperBuild/SIRF/examples/Python/MR/fully_sampled_recon.py  # run a SIRF demo
(py2) sirf:~$ exit
```

The first line starts the `sirf` docker container.
The second line starts `gadgetron` within the container as a background process (optional, but needed for using Gadgetron, i.e. most SIRF MR functionality).
We can then run an example (or you could start an interactive python session).
We then exit the container (which also stops it).

#### Using a Windows CLI

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

Using the container works in the same way as above.

### Creating a container providing a (Linux-based) Jupyter Server with SIRF
The "server" images build upon the CLI images and automatically start a Jupyter service when run. These are convenient if you use Notebooks in your experiments, or are learning and want to run the [SIRF Exercises](https://github.com/SyneRBI/SIRF-Exercises).

```bash
# Linux without GPU or MacOS:
SIRF-SuperBuild/docker$ ./sirf-compose-server up -d sirf
# Linux with GPU
SIRF-SuperBuild/docker$ ./sirf-compose-server-gpu up -d sirf
# Windows:
SIRF-SuperBuild/docker> sirf-compose-server up -d sirf
```
(You may with to use the `--build` flag before `-d sirf` on any of the above commands to re-build the image at any point)

This starts the `sirf` docker container, including `gadgetron` and
`jupyter` within the container as background processes.

Open your favourite web browser on your host OS, and go to
<http://localhost:9999>.
If the browser is giving you a connection error,
`docker logs -f sirf` will give you the current status of the server
(there should be an eventual message about Jupyter being started).

To stop the server and container, run `docker stop sirf`. If you also
want to remove the container, you can use instead `./sirf-compose-server down`,
see below.

Please note that you cannot start a second `gadgetron` in a `service` container, as you would experience port conflicts.

If you need a shell for any reason for your `service` container, you can ask the container to run Bash and drop into the shell using:

```
docker exec -w /devel -ti sirf /bin/bash
```

### sirf-compose information 
The `./sirf-compose*` scripts are simple wrappers around `docker-compose`.
(You could check the corresponding `.yml` files, or even edit them to change
names or add mounts etc.)

- For a service (Jupyter) container:
    + `./sirf-compose-server`
    + `./sirf-compose-server-gpu`
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



### More information on usage

You can use `docker exec` to execute commands in a container that is already running.
This could be useful for the `Jupyter server` container. For instance
```sh
# check what is running in the container
docker exec -w / ps aux
# start an interactive bash session (with working-directory /devel)
docker exec -w /devel -ti sirf /bin/bash
```
Note that `exec` logs in as `root`.

You can check which containers are running (or not) via
```sh
docker ps -a
```
and stop and even remove them
```sh
docker stop sirf
docker rm sirf
```
Note that `sirf-compose down` both stops and removes.

If you choose to remove the container,
next time you will start afresh (which might not be desirable of course).
Stopped containers do not use CPU time and only some additional disk-space. However, the images are quite large.
You can check which images you have with
```sh
docker image ls
```
(Note that this reports the "total" size, not taking into account any overlap between different layers).

If you decide you no longer need one, you can use
```sh
docker rmi <IMAGEID>
```

## Notes

- Tests can be run as follows:
```bash
(py2) sirf:~$ /devel/test.sh
```
- Currently all `compose` files call the container `sirf`. You could edit the `.yml` file if you
want to run different versions.
- "Cannot connect to display" errors are usually fixed by running `xhost +local:""` on the host linux system
- Non-linux users (e.g. Windows) will need to set up a desktop and vnc server in order to have a GUI
- On host systems with less than 16GB RAM, before `docker-compose up ...` you may want to edit `SIRF-SuperBuild/docker/user_sirf-ubuntu.sh`, changing the line `make -j...` to simply `make`. This increases build time and reduces build memory requirements

### Links

- [SIRF docker source]
- [Synergistic Image Reconstruction Framework (SIRF) project][SIRF]
    + [SIRF wiki]
- [Collaborative Computational Project in Synergistic Reconstruction for Biomedical Imaging (CCP SyneRBI)][CCP SyneRBI]

[SIRF docker source]: https://github.com/SyneRBI/SIRF-SuperBuild/tree/master/docker
[SIRF SuperBuild on Docker wiki]: https://github.com/SyneRBI/SIRF/wiki/SIRF-SuperBuild-on-Docker
[SIRF]: https://github.com/SyneRBI/SIRF
[SIRF wiki]: https://github.com/SyneRBI/SIRF/wiki
[CCP SyneRBI]: https://www.ccpsynerbi.ac.uk/

### Common errors

Problem: When trying to run `/sirf-compose-server-gpu up -d sirf` I get:
```
ERROR: for sirf  Cannot create container for service sirf: Unknown runtime specified nvidia
```
Solution:
Did you install the [NVidia container runtime][NVidia-container-runtime] and run the [Engine Setup](https://github.com/nvidia/nvidia-container-runtime#docker-engine-setup)?



Problem: When trying to run `/sirf-compose-server-gpu up -d sirf` I get:
```
ERROR: The Compose file './docker-compose.srv-gpu.yml' is invalid because:
Unsupported config option for services.gadgetron: 'runtime'
Unsupported config option for services.sirf: 'runtime'
```
Solution:
The most likely issue is that you have an old version of `docker-compose` (you need 1.19.0 or newer). Update your docker compose as (you may need root permissions). 
Note that if you have python 2 and python 3 installed you may need to use `pip` instead of `pip3`, as your docker-compose may be installed in a different python version. 

```
pip3 uninstall docker-compose
pip3 install docker-compose 
```
