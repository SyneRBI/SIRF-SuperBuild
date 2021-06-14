# Extra information on the SIRF Docker set-up for developers

## `ccache`

`ccache` is used in the container to speed up rebuilding images from scratch.
The cache is pulled from the host machine via the `devel/.ccache` folder.
After building a container, you can optionally replace the cache on the host with the updated one from the container:

```bash
SIRF-SuperBuild/docker$ sudo rm -rf devel/.ccache/*
SIRF-SuperBuild/docker$ ./sirf-compose run --rm sirf \
  /bin/bash -c 'cp -a /opt/ccache/* /devel/.ccache/'
```
This way, the cache will be used when you update SIRF in the container, or when you build another container.

Note that this case is different from the "normal" `ccache` of your host. (If you are only doing SIRF development, you could decide to copy that to
`SIRF-SuperBuild/docker/devel/.ccache` but we will leave that up to you).

## Some information on how the set-up works

Clearly, you should read the Docker and `docker-compose` documentation. The following might help to understand the specifics used in this repo.

`Dockerfile` defines a sequences of images (base, `core`, `sirf`, `service`) that build on top of each-other. In various places, the file uses `ARG` variables can be overriden at build-time, see https://docs.docker.com/engine/reference/builder/#arg. These are set in the `docker-compose*.yml`.

We use the [`ENTRYPOINT` mechanism](https://docs.docker.com/engine/reference/builder/#entrypoint), setting the command that will be executed at container start-up to [entrypoint.sh](entrypoint.sh) which is passed a `CMD`, specified in the `Dockerfile` (`/bin/bash` for all except `service` which uses [service.sh](service.sh). (Both the `ENTRYPOINT` and `CMD` be overriden by passing relevant options to `docker run`).

The very first time the container is run, `entrypoint.sh` creates the `sirfuser` user, copies files in correct places, and takes care of file permissions (see below).

### Why the jovyan user?
The `NB_USER` (by default called `jovyan`) is a convention used by JupyterHub. It launches jupyter
notebooks under this user. Due to permission problems, it should not have `root` access.
We build all files as this user.

### File permissions

Quoting from https://blog.gougousis.net/file-permissions-the-painful-side-of-docker/.

    Let me remind you here that file permissions on bind mounts are shared between the host and the containers...Whenever we create a file on host using a user with UID x, this file will have x as owner UID inside the container.

(Note that this is for Linux. On Mac, Docker uses NFS and apparently this doesn't give UID problems, and Windows uses file sharing).

We handle this by creating the container `sirfuser` with the same `UID:GID` as the user who executes `sirf-compose*` (by passing `USER_ID` and `GROUP_ID` as environment variables), and execute processes in the container as `sirfuser`. (Note that often Docker containers run processes as `root`). Unfortunately, this means that `entrypoint.sh` also has to `chown` various files.

As `chown` can take quite some time when the container is created, we try to minimise this by adding both `jovyan` and `sirfuser` to the `users` group, and giving "group" `rw` access to the files created by `jovyan`. This way, `entrypoint.sh` needs to `chown` (or `chmod`) only the `sirfuser` home-directory and a few others.

## `sirf-compose*`

This is a sequence of convenience scripts that essentially calls `docker-compose` with relevant `.yml` files. These specify parameters for building the images and running the containers. Note that a `.yml` file can specify different "services", e.g. `sirf`, `core`, `gadgetron`. (There is an unfortunate name-clash with SIRF "service" images (which use the `sirf` "service"). Sorry about that.)
