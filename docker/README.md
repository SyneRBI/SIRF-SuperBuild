# SIRF Docker image

The image contains SIRF & all dependencies required by JupyterHub.

## Usage

1. [Install the latest docker version](https://docs.docker.com/engine/install/)
2. (optional) For GPU support (NVIDIA CUDA on Linux or Windows Subsystem for Linux 2 only)
   - [Install NVIDIA drivers](https://developer.nvidia.com/cuda-downloads)
   - [Install NVIDIA container toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

```sh
# CPU version
docker run --rm -it -p 9999:8888 ghcr.io/synerbi/sirf:latest
# GPU version
docker run --rm -it -p 9999:8888 --gpus all ghcr.io/synerbi/sirf:latest-gpu
```

> [!TIP]
> docker tag | CIL branch/tag
> :---|:---
> `latest`, `latest-gpu` | [latest tag `v*.*.*`](https://github.com/SyneRBI/SIRF-SuperBuild/releases/latest)
> `M`, `M.m`, `M.m.p`, `M-gpu`, `M.m-gpu`, `M.m.p-gpu` | tag `vM.m.p`
> `edge`, `edge-gpu` | `master`
> only build & test (no tag) | CI (current commit)
> `devel`, `devel-gpu` | `master` with `cmake -DDEVEL_BUILD=ON -DBUILD_CIL=ON`
>
> See [`ghcr.io/synerbi/sirf`](https://github.com/SyneRBI/SIRF-SuperBuild/pkgs/container/sirf) for a full list of tags.

The Jupyter notebook should be accessible at <http://localhost:9999>.

> [!WARNING]
> To sync the container user & host user permissions (useful when sharing folders), use `--user` and `--group-add`.
>
> ```sh
> docker run --rm -it -p 9999:8888 --user $(id -u) --group-add users \
>   -v ./devel:/home/jovyan/work \
>   ghcr.io/synerbi/sirf:latest
> ```

More config: <https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#user-related-configurations>.

> [!TIP]
> To pass arguments to [`SIRF-Exercises/scripts/download_data.sh`](https://github.com/SyneRBI/SIRF-Exercises/blob/master/scripts/download_data.sh), use the docker environment variable `SIRF_DOWNLOAD_DATA_ARGS`.
>
> ```sh
> docker run --rm -it -p 9999:8888 --user $(id -u) --group-add users \
>   -v /mnt/data:/share -e SIRF_DOWNLOAD_DATA_ARGS="-pm -D /share" \
>   ghcr.io/synerbi/sirf:latest
> ```

### Extending

You can build custom images on top of the SIRF ones, likely needing to switch between `root` and default user to install packages:

```Dockerfile
# CPU version
# FROM synerbi/sirf:latest
# GPU version
FROM synerbi/sirf:latest-gpu
USER root
RUN mamba install pytorch && fix-permissions "${CONDA_DIR}" /home/${NB_USER}
USER ${NB_UID}
```

> [!TIP]
> More config: <https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html>

## Build

To build and/or run with advanced config, it's recommended to use [Docker Compose](https://docs.docker.com/compose/).

We use an Ubuntu 22.04 base image (optionally with CUDA GPU support for [CIL](https://github.com/TomographicImaging/CIL) GPU features), build <https://github.com/jupyter/docker-stacks> `datascience-notebook` on top, and then install SIRF & its depdendencies.

The strategy is:

1. Use either `ubuntu:latest` or a recent Ubuntu CuDNN runtime image from <https://hub.docker.com/r/nvidia/cuda> as base
2. Build <https://github.com/jupyter/docker-stacks/tree/main/images/datascience-notebook> on top
3. Copy & run the SIRF `docker/build_*.sh` scripts
4. Clone the SIRF-SuperBuild & run `cmake`
5. Copy some example notebooks & startup scripts

### Docker Compose

All of this is done by [`compose.sh`](./compose.sh).

1. [Install the latest docker version](https://docs.docker.com/engine/install/)
2. Clone this repository and run the [`docker/compose.sh`](docker/compose.sh) script

   ```bash
   git clone https://github.com/SyneRBI/SIRF-SuperBuild
   ./SIRF-SuperBuild/docker/compose.sh -h  # prints help
   ```

> [!TIP]
> For example, to `-b`uild the `-d`evelopment (`master`) branches of SIRF and its dependencies, including `-g`pu support and skipping tests:
>
> ```bash
> compose.sh -bdg -- --build-arg RUN_CTEST=0
> ```
>
> Then to `-r`un the container:
>
> ```bash
> compose.sh -rdg
> ```

### More info

> [!TIP]
>
> ```bash
> compose.sh -h # prints help
> ```

#### Useful `--build-arg`s

CMake build arguments (e.g. for dependency version config) are (in increasing order of precedence) found in:

- [`../version_config.cmake`](../version_config.cmake)
- [`../Dockerfile`](../Dockerfile)
- docker-compose.*.yml files
- `compose.sh -- --build-arg` arguments

Useful `--build-arg`s:

You can determine which version of the `SIRF-SuperBuild` is built in the docker image:

```bash
compose.sh -b -- --build-arg SIRF_SB_TAG=<git ref>
```

By default, the CTests are run while building the docker image. Note that this takes a few minutes.
You can switch this off by setting `--build-arg  RUN_CTEST=0` before building the image.

#### `ccache`

`ccache` is used in the container to speed up rebuilding images from scratch.
The cache is pulled from the host machine via the `devel/.ccache` folder.

Building (`compose.sh -b`) automatically updates the cache.

To disable updating the cache, `-b`uild with `-U`.

To regenerate the cache, remove it and then `-b`uild with `-R`.

This way, the cache will be used when you update SIRF in the container, or when you build another container.

Note that this cache is different from the "normal" `ccache` of your host. (If you are only doing SIRF development, you could decide to copy that to
`SIRF-SuperBuild/docker/devel/.ccache` but we will leave that up to you).

#### `docker-stacks`

<https://github.com/jupyter/docker-stacks> is used to gradually build up images:

- `BASE_CONTAINER=nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04`
- `docker-stacks-foundation` -> `synerbi/jupyter:foundation`
- `base-notebook` -> `synerbi/jupyter:base`
- `minimal-notebook` -> `synerbi/jupyter:minimal`
- `scipy-notebook` -> `synerbi/jupyter:scipy`
- `datascience-notebook` -> `synerbi/jupyter:datascience`
- [`Dockerfile`](./Dockerfile) -> `synerbi/jupyter:sirf`
  + Copy & run the SIRF `build_{gadgetron,system}.sh` scripts
  + Copy `/opt/SIRF-SuperBuild/{INSTALL,sources/SIRF}` directories from the `synerbi/sirf:latest` image
  + Install [`requirements.yml`](requirements.yml)
  + Clone & setup <https://github.com/SyneRBI/SIRF-Exercises> & <https://github.com/TomographicImaging/CIL-Demos>
  + Set some environment variables (e.g. `PYTHONPATH=/opt/SIRF-SuperBuild/INSTALL/python`, `OMP_NUM_THREADS=$(( cpu_count/2 ))`)
