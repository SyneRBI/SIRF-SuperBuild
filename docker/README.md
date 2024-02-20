# SIRF Docker image

The image contains SIRF & all dependencies required by JupyterHub.

## Usage

> [!WARNING]
> The easiest way to run [SIRF](https://github.com/SyneRBI/SIRF) & all its dependencies is to use Docker. See [../README.md](../README.md#running-sirf-on-docker) instead.

### Extending

You can build custom images on top of the SIRF ones, likely needing to switch between `root` and default user to install packages:

```Dockerfile
# CPU version
# FROM synerbi/sirf:jupyter
# GPU version
FROM synerbi/sirf:jupyter-gpu
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

CMake build arguments (e.g. for dependency version config) are (in increasing order of precedence) found in:

- [`../version_config.cmake`](../version_config.cmake)
- [`../Dockerfile`](../Dockerfile)
- docker-compose.*.yml files
- `compose.sh -- --build-arg` arguments

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
